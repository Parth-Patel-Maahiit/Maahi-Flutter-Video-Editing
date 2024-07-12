import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:video_editing_app/API/api.dart';

class CommonApiCall {
  static Future<dynamic> getApiData({required String action, body}) async {
    var response;
    final url = Uri.parse(
      '${Api.base_url}$action',
    );
    try {
      print('$action ===> $url');
      response = await http.post(url, body: body);
      print('$action response.body ===> ${response.body}');
    } catch (e) {
      print('error catch: $e');
    }
    return response;
  }

  // static Future<dynamic> postApiCall(
  //     {String? action, Object? body, headers}) async {
  //   var response;
  //   final url = Uri.parse(
  //     '${Api.base_url}$action',
  //   );
  //   try {
  //     print('$action request ===> $body');
  //     print('$action ===> $url');
  //     response = await http.post(url, body: body, headers: headers);
  //     print("response.body $action ==== > ${response.body}");
  //   } catch (e) {
  //     print('error api: $e');
  //   }
  //   return response;
  // }
  static Future<http.Response?> postApiCall(
      {String? action, Map<String, dynamic>? body}) async {
    var response;
    final url = Uri.parse('${Api.base_url}?action=$action');
    try {
      print('$action request ===> $body');
      print('$action ===> $url');
      response = await http.post(
        url,
        body: body != null ? jsonEncode(body) : null,
        headers: {
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      );
      print("response.body $action ==== > ${response.body}");
    } catch (e) {
      print('error api: $e');
    }
    return response;
  }
}
