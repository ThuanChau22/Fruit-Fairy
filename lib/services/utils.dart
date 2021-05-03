import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
//
import 'package:fruitfairy/services/firestore_service.dart';

class Utils {
  Utils._();

  static List<List<E>> decompose<E>(List<E> list, size) {
    List<List<E>> results = [];
    int index = 0;
    while (index < list.length) {
      results.add([]);
      for (int i = 0; i < size && index < list.length; i++) {
        results.last.add(list[index++]);
      }
    }
    return results;
  }

  static void createTestCharities(
    FireStoreService fireStore, {
    int from,
    int to,
  }) async {
    List<Map<String, String>> addresses = [
      {
        FireStoreService.kAddressStreet: '1299 San Tomas Aquino Rd',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95117',
      },
      {
        FireStoreService.kAddressStreet: '1055 N Capitol Ave',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95133',
      },
      {
        FireStoreService.kAddressStreet: '110 Magellan Ave',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95116',
      },
      {
        FireStoreService.kAddressStreet: '408 S 5th St',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95112',
      },
      {
        FireStoreService.kAddressStreet: '4191 Ridgebrook Way',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95111',
      },
      {
        FireStoreService.kAddressStreet: '324 Endmoor Ct',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95119',
      },
      {
        FireStoreService.kAddressStreet: '3345 Lindenoaks Dr',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95117',
      },
      {
        FireStoreService.kAddressStreet: '3476 Ramstad Dr',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95127',
      },
      {
        FireStoreService.kAddressStreet: '3500 Telegraph Dr',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95132',
      },
      {
        FireStoreService.kAddressStreet: '360 Roma Vista Way',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95136',
      },
      {
        FireStoreService.kAddressStreet: '280 Cresta Vista Way',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95119',
      },
      {
        FireStoreService.kAddressStreet: '310 Crescent Village Cir',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95134',
      },
      {
        FireStoreService.kAddressStreet: '7510 Tierra Sombra Ct',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95120',
      },
      {
        FireStoreService.kAddressStreet: '783 Regent Park Dr',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95123',
      },
      {
        FireStoreService.kAddressStreet: '5649 Lilac Blossom Ln',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95124',
      },
      {
        FireStoreService.kAddressStreet: '5737 Indian Ave',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95123',
      },
      {
        FireStoreService.kAddressStreet: '576 Jesse James Dr',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95123',
      },
      {
        FireStoreService.kAddressStreet: '593 Edelweiss Dr',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95136',
      },
      {
        FireStoreService.kAddressStreet: '6351 Whaley Dr',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95135',
      },
      {
        FireStoreService.kAddressStreet: '954 Walglen Ct',
        FireStoreService.kAddressCity: 'San Jose',
        FireStoreService.kAddressState: 'California',
        FireStoreService.kAddressZip: '95136',
      },
    ];
    List<String> produce = [];
    CollectionReference produceDB =
        fireStore.instance.collection(FireStoreService.kProduce);
    QuerySnapshot snapshot = await produceDB.get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      produce.add(doc.id);
    }
    String currentUID = fireStore.uid;
    Random rand = Random();
    for (int i = from; i <= to; i++) {
      Map<String, String> address = addresses[(i - 1) % addresses.length];
      String testUID = 'TestCharity$i';
      fireStore.setUID(testUID);
      await fireStore.addCharityAccount(
        charityName: testUID,
        street: address[FireStoreService.kAddressStreet],
        city: address[FireStoreService.kAddressCity],
        state: address[FireStoreService.kAddressState],
        zip: address[FireStoreService.kAddressZip],
        ein: 'N/A',
        email: 'N/A',
      );

      Set<String> wishlist = {};
      int len = 1 + rand.nextInt(produce.length);
      for (int i = 0; i < len; i++) {
        int produceIndex;
        do {
          produceIndex = rand.nextInt(produce.length);
        } while (wishlist.contains(produce[produceIndex]));
        wishlist.add(produce[produceIndex]);
      }
      await fireStore.updateWishList(wishlist.toList());
    }
    fireStore.setUID(currentUID);
  }

  static void deleteTestCharities(
    FireStoreService fireStore, {
    int from,
    int to,
  }) {
    String currentUID = fireStore.uid;
    for (int i = from; i <= to; i++) {
      fireStore.setUID('TestCharity$i');
      fireStore.deleteAccount();
    }
    fireStore.setUID(currentUID);
  }
}
