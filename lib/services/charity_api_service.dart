import 'dart:convert';
import 'package:http/http.dart' as http;
//
import 'package:fruitfairy/api_keys.dart';

class CharityAPI {
  static const String kEIN = 'ein';
  static const String kName = 'name';
  static const String kStreet = 'street';
  static const String kCity = 'city';
  static const String kState = 'state';
  static const String kZip = 'zip';

  CharityAPI._();

  static Future<String> webDomain(String ein) async {
    String requestURL = 'http://data.orghunter.com/v1/charitysearch?';
    requestURL += 'user_key=$CHARITY_API_KEY';
    requestURL += '&ein=$ein';
    http.Response response = await http.get(requestURL);
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      List<dynamic> resultList = data['data'];
      if (resultList != null) {
        String website = resultList.first['website'];
        return website.substring(website.indexOf('.') + 1);
      }
    } else {
      print(response.statusCode);
    }
    throw 'Charity not found. Please check your EIN and try again!';
  }

  static Future<Map<String, String>> details(String ein) async {
    String requestURL = 'http://data.orghunter.com/v1/charitybasic?';
    requestURL += 'user_key=$CHARITY_API_KEY';
    requestURL += '&ein=$ein';
    http.Response response = await http.get(requestURL);
    Map<String, String> result = {};
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      Map<String, dynamic> charity = data['data'];
      if (charity != null) {
        result[kEIN] = charity['ein'];
        result[kName] = charity['name'];
        result[kStreet] = charity['street'];
        result[kCity] = charity['city'];
        result[kState] = charity['state'];
        result[kZip] = charity['zipCode'];
      }
    } else {
      print(response.statusCode);
    }
    return result;
  }
}
