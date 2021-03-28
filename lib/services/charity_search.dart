import 'dart:convert';
import 'package:http/http.dart' as http;
//
import 'package:fruitfairy/api_keys.dart';

class CharitySearch {
  static const String kEIN = 'ein';
  static const String kName = 'name';
  static const String kWebsite = 'website';

  CharitySearch._();

  static Future<Map<String, String>> info(String ein) async {
    String requestURL = 'http://data.orghunter.com/v1/charitysearch?';
    requestURL += 'user_key=$CHARITY_API_KEY';
    requestURL += '&ein=$ein';
    http.Response response = await http.get(requestURL);
    Map<String, String> result = {};
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      if (data['code'] == '200') {
        Map<String, dynamic> info = data['data'].first;
        result[kEIN] = info['ein'];
        result[kName] = info['charityName'];
        result[kWebsite] = info['website'];
      }
    } else {
      print(response.statusCode);
    }
    return result;
  }
}
