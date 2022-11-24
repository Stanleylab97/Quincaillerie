import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkHandler {
  static String baseurl = "http://173.249.38.148:9094";
  var log = Logger();

  Future<http.Response> get(String url) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token").toString();

    url = formater(url);
    return await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }

  Future<http.Response> post(
      String url, String token, Map<String, dynamic> body) async {
    print(json.encode(body));
    //url = formater(url);
    var response = await http.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    return response;
  }

  Future<http.Response> authenticateUser(
      String url, Map<String, String> body) async {
    url = formater(url);
    var response = await http.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: {"Content-type": "application/json"},
    );
    return response;
  }

  Future<http.Response?>? sendSinistre(
      String url, String filepath, Map<String, String> data) async {
    url = formater(url);

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath("imageUrl", filepath));
    request.fields['lon'] = data['lon']!;
    request.fields['lat'] = data['lat']!;
    request.fields['typeSin'] = data['typeSin']!;
    request.headers.addAll({
      "Content-type": "multipart/form-data",
      //"Authorization": "Bearer $token"
    });

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }

  String formater(String url) {
    return baseurl + url;
  }

  NetworkImage getImage(String username) {
    String url = formater("/uploads//$username.jpg");
    return NetworkImage(url);
  }
}
