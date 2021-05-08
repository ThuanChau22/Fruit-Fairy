import * as functions from "firebase-functions";
import * as admin from 'firebase-admin';
admin.initializeApp();

const db = admin.firestore();
// const fcm = admin.messaging();

export const myFunction = functions.https.onCall(async (data, context) => {
  try {
    const doc = await db.collection('test').add({
      brook: 'Yohohohoho'
    });
    console.log('Id: ', doc.id);
  } catch (error) {
    console.log('Error: ', error);
  }
});