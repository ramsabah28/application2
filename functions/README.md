This folder contains Firebase Cloud Functions for PayPal Orders integration.

Important:
- Replace placeholders `YOUR_PAYPAL_CLIENT_ID` and `YOUR_PAYPAL_SECRET` with your sandbox or live credentials.
- Recommended: set credentials via Firebase functions config:

- Replace placeholders `YOUR_PAYPAL_CLIENT_ID` and `YOUR_PAYPAL_SECRET` with your sandbox or live credentials.
- Recommended: set credentials via Firebase functions config so secrets are not stored in source code.

  Example (replace with your values and project id):

  firebase functions:config:set \
    paypal.client_id="YOUR_CLIENT_ID" \
    paypal.secret="YOUR_SECRET" \
    paypal.base="https://api-m.sandbox.paypal.com" \
    paypal.return_url="https://example.com/paypal-return" \
    paypal.cancel_url="https://example.com/paypal-cancel" \
    --project YOUR_PROJECT_ID

  The functions code reads these via `functions.config().paypal` with env var fallbacks.

To deploy:
- Install dependencies: `cd functions && npm install`
- Deploy functions: `firebase deploy --only functions`

Notes:
- This implementation uses the PayPal Orders API to create an order and to capture it after approval.
- Keep client secrets on the server — do not embed them in the Flutter app.
- The return and cancel URLs are placeholders; set them to URLs reachable by the WebView or to your app's deep link.
