import * as functions from "firebase-functions";
import * as admin from 'firebase-admin';

/// Database fields
/// donations
const kDonations = 'donations';
const kDonor = 'donor';
const kUserId = 'userId';
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
      const donationData = change.after.data();
      const donorId = donationData[kDonor][kUserId];
      const userData = (await db.collection('users').doc(donorId).get()).data();

      // Declined
      if (donationData[kStatus] == 1 && donationData[kSubStatus] == 0) {
        if (donationData![kSelectedCharities][0]) {
          donationRounting(change.after);
        } else {
          // Notify donor
          const tokens = userData![kDeviceTokens];
          if (tokens?.length > 0) {
            await sendNotification(
              await validatedTokens(donorId, tokens),
              'Your donation was not accepted at this time',
              { id: change.after.id },
            );
          }
        }
      }

      // Accept
      if (donationData[kStatus] == 0 && donationData[kSubStatus] == 1) {
        const tokens = userData![kDeviceTokens];
        if (tokens?.length > 0){
          await sendNotification(
            await validatedTokens(donorId, tokens),
            'Your donation was accepted',
            { id: change.after.id },
          );
        }
      }

      // Completed
      if (donationData[kStatus] == 1 && donationData[kSubStatus] == 1) {
        const tokens = userData![kDeviceTokens];
        if (tokens?.length > 0) {
          await sendNotification(
            await validatedTokens(donorId, tokens),
            'Your donation was collected',
            { id: change.after.id },
          );
        }

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
  const tokens = userData![kDeviceTokens];
  if (tokens?.length > 0) {
    await sendNotification(
      await validatedTokens(charityId, tokens),
      'You have a new donation request',
      { id: snapshot.id },
    );
  }
}

async function sendNotification(
  tokens: string[],
  message: string,
  data: admin.messaging.DataMessagePayload,
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
    if (badTokens.length > 0) {
      db.collection(kUsers).doc(userId).update({
        deviceTokens: admin.firestore.FieldValue.arrayRemove(...badTokens),
      });
    }
    for (const token of badTokens) {
      tokens = listRemove(tokens, token);
    }
  } catch (error) {
    console.log('Error: ', error);
  }
  return tokens;
}

function listRemove(list: string[], item: string) {
  return list.filter(function (i) {
    return i != item;
  });
}