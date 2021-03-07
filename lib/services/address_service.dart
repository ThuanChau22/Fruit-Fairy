import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:fruitfairy/api_keys.dart';

class AddressService {
  static const String placeId = 'placeId';
  static const String description = 'description';
  static const String street = 'street';
  static const String city = 'city';
  static const String state = 'state';
  static const String zipCode = 'zipCode';

  AddressService._();

  static Future<List<Map<String, String>>> getSuggestions(
    String input, {
    String sessionToken,
  }) async {
    String requestURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    requestURL += '?input=$input';
    requestURL += '&types=address';
    requestURL += '&components=country:us';
    requestURL += '&key=$PLACES_API_KEY';
    requestURL += sessionToken != null ? '&sessiontoken=$sessionToken' : '';
    http.Response response = await http.get(requestURL);
    List<Map<String, String>> results = [];
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      for (Map<String, dynamic> address in data['predictions']) {
        if (address['terms'].length >= 5) {
          results.add({
            placeId: address['place_id'],
            description: address['description'],
          });
        }
      }
    } else {
      print(response.statusCode);
    }
    return results;
  }

  static Future<Map<String, String>> getDetails(
    String placeId, {
    String sessionToken,
  }) async {
    String requestURL =
        'https://maps.googleapis.com/maps/api/place/details/json';
    requestURL += '?place_id=$placeId';
    requestURL += '&fields=address_component';
    requestURL += '&key=$PLACES_API_KEY';
    requestURL += sessionToken != null ? '&sessiontoken=$sessionToken' : '';
    http.Response response = await http.get(requestURL);
    Map<String, String> results = {};
    if (response.statusCode == 200) {
      dynamic result = jsonDecode(response.body)['result'];
      if (result != null && result['address_components'] != null) {
        for (Map<String, dynamic> details in result['address_components']) {
          for (String type in details['types']) {
            switch (type) {
              case 'street_number':
                String number = details['long_name'];
                String route = results[street];
                results[street] = route != null ? '$number $route' : number;
                break;
              case 'route':
                String route = details['long_name'];
                String number = results[street];
                results[street] = number != null ? '$number $route' : route;
                break;

              case 'locality':
                results[city] = details['long_name'];
                break;

              case 'administrative_area_level_1':
                results[state] = details['long_name'];
                break;

              case 'postal_code':
                results[zipCode] = details['long_name'];
                break;
              default:
            }
          }
        }
      }
    } else {
      print(response.statusCode);
    }
    return results;
  }
}
