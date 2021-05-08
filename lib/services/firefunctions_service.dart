import 'package:cloud_functions/cloud_functions.dart';

class FireFunctionsService {
  FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> myFunction() async {
    try {
      HttpsCallable callable = _functions.httpsCallable('myFunction');
      await callable();
      print('Check DB');
    } catch (e) {
      print(e);
    }
  }
}
