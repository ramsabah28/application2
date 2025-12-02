const functions = require('firebase-functions');
const admin = require('firebase-admin');
// Node 18+ provides a global `fetch` implementation. Avoid requiring `node-fetch` (v3 is ESM-only)
// to prevent CommonJS/ESM issues during deploy/runtime. Use the global fetch instead.

admin.initializeApp();

// Read PayPal configuration from Firebase functions config (recommended) with fallbacks to env vars
// To set in your project run:
// firebase functions:config:set paypal.client_id="YOUR_CLIENT_ID" paypal.secret="YOUR_SECRET" paypal.base="https://api-m.sandbox.paypal.com" paypal.return_url="https://example.com/paypal-return" paypal.cancel_url="https://example.com/paypal-cancel" --project YOUR_PROJECT_ID
const paypalConfig = (functions.config && functions.config().paypal) ? functions.config().paypal : {};

const PAYPAL_CLIENT_ID = paypalConfig.client_id || process.env.PAYPAL_CLIENT_ID || 'PLACEHOLDER';
const PAYPAL_SECRET = paypalConfig.secret || process.env.PAYPAL_SECRET || 'PLACEHOLDER';

const PAYPAL_BASE = paypalConfig.base || process.env.PAYPAL_BASE || 'https://api-m.sandbox.paypal.com';

// Return/cancel URLs should be reachable by the browser. For in-app WebView you can detect approvals by query params
const RETURN_URL = paypalConfig.return_url || process.env.PAYPAL_RETURN_URL || 'https://example.com/paypal-return';
const CANCEL_URL = paypalConfig.cancel_url || process.env.PAYPAL_CANCEL_URL || 'https://example.com/paypal-cancel';

async function getAccessToken() {
  const auth = Buffer.from(`${PAYPAL_CLIENT_ID}:${PAYPAL_SECRET}`).toString('base64');
  const res = await fetch(`${PAYPAL_BASE}/v1/oauth2/token`, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${auth}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: 'grant_type=client_credentials'
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Failed to fetch token: ${res.status} ${text}`);
  }
  const json = await res.json();
  return json.access_token;
}

exports.createOrder = functions.https.onCall(async (data, context) => {
  const amount = data.amount; // string like '12.34'
  const currency = data.currency || 'EUR';
  if (!amount) {
    throw new functions.https.HttpsError('invalid-argument', 'Amount is required');
  }

  try {
    const token = await getAccessToken();
    const body = {
      intent: 'CAPTURE',
      purchase_units: [
        {
          amount: {
            currency_code: currency,
            value: amount
          }
        }
      ],
      application_context: {
        return_url: RETURN_URL,
        cancel_url: CANCEL_URL
      }
    };

    const res = await fetch(`${PAYPAL_BASE}/v2/checkout/orders`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(body)
    });

    if (!res.ok) {
      const text = await res.text();
      throw new Error(`Failed to create order: ${res.status} ${text}`);
    }

    const json = await res.json();
    const orderId = json.id;
    const approveLink = (json.links || []).find(l => l.rel === 'approve');
    const approvalUrl = approveLink ? approveLink.href : null;
    return { orderId, approvalUrl, raw: json };
  } catch (err) {
    console.error(err);
    throw new functions.https.HttpsError('internal', err.message || String(err));
  }
});

exports.captureOrder = functions.https.onCall(async (data, context) => {
  const orderId = data.orderId;
  if (!orderId) {
    throw new functions.https.HttpsError('invalid-argument', 'orderId is required');
  }

  try {
    const token = await getAccessToken();
    const res = await fetch(`${PAYPAL_BASE}/v2/checkout/orders/${orderId}/capture`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    });

    if (!res.ok) {
      const text = await res.text();
      throw new Error(`Failed to capture order: ${res.status} ${text}`);
    }

    const json = await res.json();
    // You should validate json.status and amounts here and persist in your DB
    return { status: json.status, capture: json };
  } catch (err) {
    console.error(err);
    throw new functions.https.HttpsError('internal', err.message || String(err));
  }
});
