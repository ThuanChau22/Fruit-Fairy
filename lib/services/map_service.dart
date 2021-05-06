import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
//
import 'package:fruitfairy/api_keys.dart';
import 'package:fruitfairy/services/utils.dart';

/// A class that performs map related operations such as look up addresses
/// or calulate distances by utilizing Google Map API
class MapService {
  static const double MeterPerMile = 1609.344;
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
    List<Map<String, String>> results = [];
    String requestURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?';
    requestURL += 'input=$input';
    requestURL += '&types=address';
    requestURL += '&components=country:us';
    requestURL += '&key=$PLACES_API_KEY';
    requestURL += sessionToken != null ? '&sessiontoken=$sessionToken' : '';
    try {
      http.Response response = await http.get(requestURL);
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
    } catch (e) {
      print(e);
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
    Map<String, String> results = {};
    String requestURL =
        'https://maps.googleapis.com/maps/api/place/details/json?';
    requestURL += 'place_id=$placeId';
    requestURL += '&fields=address_component';
    requestURL += '&key=$PLACES_API_KEY';
    requestURL += sessionToken != null ? '&sessiontoken=$sessionToken' : '';
    try {
      http.Response response = await http.get(requestURL);
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
                  results[kState] = details['long_name'];
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
    } catch (e) {
      print(e);
    }
    return results;
  }

  /// Return a list of double values in mile that indicates
  /// distances between [origin] with a list of [destinations]
  static Future<List<double>> getDistances({
    @required String origin,
    @required List<String> destinations,
  }) async {
    List<double> results = [];
    try {
      // Break number of destinations into groups of 25 each request
      List<List<String>> lists = Utils.decompose(destinations, 25);

      // Execute all API calls at the same time and wait for responses
      List<http.Response> responses = await Future.wait(
        lists.map((destinationList) {
          String requestURL =
              'https://maps.googleapis.com/maps/api/distancematrix/json?';
          requestURL += 'origins=$origin';
          requestURL += '&destinations=';
          for (String destination in destinationList) {
            requestURL += '$destination|';
          }
          requestURL += '&units=imperial';
          requestURL += '&key=$PLACES_API_KEY';
          return http.get(requestURL);
        }),
      );
      // Parse each response into results list
      for (http.Response response in responses) {
        if (response.statusCode == 200) {
          dynamic data = jsonDecode(response.body);
          for (Map<String, dynamic> element in data['rows'].first['elements']) {
            results.add(element['status'] == 'OK'
                ? element['distance']['value'] / MeterPerMile
                : double.negativeInfinity);
          }
        } else {
          print(response.statusCode);
        }
      }
    } catch (e) {
      print(e);
    }
    return results;
  }
}
