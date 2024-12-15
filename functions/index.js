// **
// * Import function triggers from their respective submodules:
// *
// * const {onCall} = require("firebase-functions/v2/https");
// * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
// *
// * See a full list of supported triggers at https://firebase.google.com/docs/functions
// */
//
// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");
//
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started
//
// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//  response.send("Hello from Firebase!");
// });


//const functions = require('firebase-functions');
//const admin = require('firebase-admin');
//admin.initializeApp();
//
//exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
//});

const functions = require('firebase-functions'); // Import Firebase Functions SDK
const admin = require('firebase-admin'); // Import Firebase Admin SDK

// Initialize Firebase Admin SDK
admin.initializeApp();

// Firestore Trigger for Pledge Notifications
exports.sendPledgeNotification = functions.firestore
  .document('pledges/{pledgeId}')
  .onCreate(async (snapshot, context) => {
    try {
      // Extract pledge data
      const pledgeData = snapshot.data();
      const { pledgedByUserId, pledgedToUserId, giftName } = pledgeData;

      // Fetch the FCM token of the user being pledged to
      const userDoc = await admin.firestore().collection('users').doc(pledgedToUserId).get();
      const fcmToken = userDoc.data()?.fcmToken;

      // Check if FCM token exists
      if (fcmToken) {
        const payload = {
          notification: {
            title: 'Gift Pledged!',
            body: `User ${pledgedByUserId} pledged "${giftName}" to you.`,
          },
        };

        // Send notification
        await admin.messaging().sendToDevice(fcmToken, payload);
        console.log('Notification sent successfully');
      } else {
        console.log('FCM token not found for user:', pledgedToUserId);
      }
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });

  console.log('Pledge data:', pledgeData);
  console.log('User document fetched:', userDoc.data());
