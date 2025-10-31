# Firebase Firestore Indexes Deployment

This file contains the required Firestore indexes for the application's order management system.

## Required Indexes

### 1. Orders by User with CreatedAt Ordering
- **Collection**: orders
- **Fields**: 
  - `UID` (Ascending)
  - `createdAt` (Descending)
- **Purpose**: Enables querying user-specific orders sorted by creation date

### 2. Undelivered Orders with CreatedAt Ordering
- **Collection**: orders  
- **Fields**:
  - `delivered` (Ascending)
  - `createdAt` (Descending)
- **Purpose**: Enables querying undelivered orders sorted by creation date

## Deployment Methods

### Method 1: Firebase CLI (Recommended for Developers)
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize project: `firebase init firestore` (if not done already)
4. Deploy indexes: `firebase deploy --only firestore:indexes`

### Method 2: Firebase Console (Easiest)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `application-b436a`
3. Navigate to Firestore Database → Indexes
4. Click "Create Index" and configure each index manually

### Method 3: Direct Link (Quickest)
Use the direct link provided in the error message:
```
https://console.firebase.google.com/v1/r/project/application-b436a/firestore/indexes?create_composite=ClBwcm9qZWN0cy9hcHBsaWNhdGlvbi1iNDM2YS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvb3JkZXJzL2luZGV4ZXMvXxABGgcKA1VJRBABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI
```

## Note
Index creation can take several minutes to complete. You'll receive an email notification when the indexes are ready for use.

## Verification
After deployment, you can verify the indexes in the Firebase Console under Firestore Database → Indexes.