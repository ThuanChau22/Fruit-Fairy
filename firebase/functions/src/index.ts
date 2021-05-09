import * as functions from "firebase-functions";
import * as admin from 'firebase-admin';

/// Database fields
/// donations
const kDonations = 'donations';
const kDonor = 'donor';
const kCharity = 'charity';
const kUserId = 'userId';
const kUserName = 'userName';
const kSelectedCharities = 'selectedCharities';
const kStatus = 'status';
const kSubStatus = 'subStatus';

/// users
const kUsers = 'users';
const kCharityName = 'charityName';
const kDeviceTokens = 'deviceTokens';
///////////////

admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();

export const donationCreate = functions.firestore
  .document(`${kDonations}/{id}`)
  .onCreate(async (snapshot, context) => {
    try {
      donationRounting(snapshot);
    } catch (error) {
      console.log('Error: ', error);
    }
  });

export const donationUpdate = functions.firestore
  .document(`${kDonations}/{id}`)
  .onUpdate(async (change, context) => {
    try {
      let message = '';
      const donationData = change.after.data();

      // Declined
      if (donationData[kStatus] == 1 && donationData[kSubStatus] == 0) {
        message = `Your donation has been declined`;
        if (donationData![kSelectedCharities][0]) {
          donationRounting(change.after);
          return;
        }
      }

      const charityName = donationData[kCharity][kUserName];
      // Accept
      if (donationData[kStatus] == 0 && donationData[kSubStatus] == 1) {
        message = `${charityName} has accepted your donation`;
      }

      // Completed
      if (donationData[kStatus] == 1 && donationData[kSubStatus] == 1) {
        message = `${charityName} has completed your donation`;
      }

      const donorId = donationData[kDonor][kUserId];
      const userData = (await db.collection('users').doc(donorId).get()).data();

      // Notify donor
      if (message) {
        await sendNotification(
          message,
          { id: change.after.id },
          await validatedTokens(donorId, userData![kDeviceTokens]),
        );
      }
    } catch (error) {
      console.log('Error: ', error);
    }
  });

async function donationRounting(
  snapshot: functions.firestore.QueryDocumentSnapshot,
) {
  const charityId = snapshot.data()![kSelectedCharities][0];
  const userData = (await db.collection(kUsers).doc(charityId).get()).data();
  await db.doc(`${kDonations}/${snapshot.id}`).update({
    requestedCharities: admin.firestore.FieldValue.arrayUnion(charityId),
    selectedCharities: admin.firestore.FieldValue.arrayRemove(charityId),
    charity: { userId: charityId, userName: userData![kCharityName] },
    status: 0,
    subStatus: 0,
  });

  // Notify requested charity
  await sendNotification(
    'You have a new donation request',
    { id: snapshot.id },
    await validatedTokens(charityId, userData![kDeviceTokens]),
  );
}

async function sendNotification(
  message: string,
  data: admin.messaging.DataMessagePayload,
  tokens: string[],
) {
  try {
    await fcm.sendToDevice(
      tokens,
      {
        notification: {
          body: message,
        },
        data: data,
      },
      {
        contentAvailable: true,
        priority: 'high',
      },
    );
  } catch (error) {
    console.log('Error: ', error);
  }
}

async function validatedTokens(
  userId: string,
  tokens: string[],
) {
  try {
    const badTokens: string[] = [];
    for (const token of tokens) {
      try {
        await fcm.send({ token }, true);
      } catch (error) {
        if (error.code === 'messaging/registration-token-not-registered' ||
          error.code === 'messaging/invalid-argument') {
          badTokens.push(token);
        }
      }
    }
    for (const token of badTokens) {
      tokens.splice(tokens.indexOf(token, 1));
    }
    if (badTokens.length > 0) {
      await db.collection('users').doc(userId).update({
        deviceTokens: admin.firestore.FieldValue.arrayRemove(...badTokens),
      });
    }
  } catch (error) {
    console.log('Error: ', error);
  }
  return tokens;
}