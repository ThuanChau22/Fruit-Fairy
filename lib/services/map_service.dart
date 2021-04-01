import 'dart:convert';
import 'package:http/http.dart' as http;
//
import 'package:fruitfairy/api_keys.dart';

/// A class that performs map related operations such as look up addresses
/// or calulate distances by utilizing Google Map API
class MapService {
  static const String kPlaceId = 'placeId';
  static const String kDescription = 'description';
  static const String kStreet = 'street';
  static const String kCity = 'city';
  static const String kState = 'state';
  static const String kZipCode = 'zipCode';

  /// Private constructor to prevent instantiation
  MapService._();

  /// Return a list of suggested address based on [input]
  /// [sessionToken] is used to keep API call within a session
  static Future<List<Map<String, String>>> addressSuggestions(
    String input, {
    String sessionToken,
  }) async {
    String requestURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?';
    requestURL += 'input=$input';
    requestURL += '&types=address';
    requestURL += '&components=country:us';
    requestURL += '&key=$PLACES_API_KEY';
    requestURL += sessionToken != null ? '&sessiontoken=$sessionToken' : '';
    http.Response response = await http.get(requestURL);
    List<Map<String, String>> results = [];
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      for (Map<String, dynamic> address in data['predictions']) {
        for (String type in address['types']) {
          if (type == 'premise' || type == 'street_address') {
            results.add({
              kPlaceId: address['place_id'],
              kDescription: address['description'],
            });
          }
        }
      }
    } else {
      print(response.statusCode);
    }
    return results;
  }

  /// Return details information of an address from [placeId]
  /// retrieved from one of [addressSuggestions] result
  /// [sessionToken] is used to keep API call within a session
  /// Countd as one call if used with [addressSuggestions]
  static Future<Map<String, String>> addressDetails(
    String placeId, {
    String sessionToken,
  }) async {
    String requestURL =
        'https://maps.googleapis.com/maps/api/place/details/json?';
    requestURL += 'place_id=$placeId';
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
                String route = results[kStreet];
                results[kStreet] = route != null ? '$number $route' : number;
                break;
              case 'route':
                String route = details['long_name'];
                String number = results[kStreet];
                results[kStreet] = number != null ? '$number $route' : route;
                break;

              case 'locality':
                results[kCity] = details['long_name'];
                break;

              case 'administrative_area_level_1':
                results[kState] = details['short_name'];
                break;

              case 'postal_code':
                results[kZipCode] = details['long_name'];
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
