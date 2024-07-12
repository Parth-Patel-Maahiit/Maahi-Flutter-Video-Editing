import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> setStringData(key, value) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString(key, value);
}

Future<String> getStringData(key) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getString(key) == null) {
    return "";
  }
  String? stringData = sharedPreferences.getString(key);
  return stringData!;
}

Future<void> clearAllSharedPreferencesData() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.clear();
}

Future<void> removeSharedPreferencesData(key) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.remove(key);
}

Future<void> setStoreApidata(key, value) async {
  final valueJson = value?.toJson();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString(key, jsonEncode(valueJson));
}

Future<dynamic> getStoreApidata(key) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final storedDataJson = sharedPreferences.getString(key);
  if (storedDataJson != null) {
    return jsonDecode(storedDataJson);
  }
  return null;
}

Future<void> setStoreApiListdata(key, List<Map<String, dynamic>> value) async {
  if (value != []) {
    final List<Map<String, dynamic>> valueJsonList =
        value.map((status) => status).toList();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, jsonEncode(valueJsonList));
  }
}

Future<dynamic> getStoredApiListdata(String key) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? jsonString = sharedPreferences.getString(key);
  if (jsonString != null) {
    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList;
  } else {
    return [];
  }
}

