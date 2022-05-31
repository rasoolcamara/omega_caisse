import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<int> getBalance(
    int id, {
    String startDay,
    String endDay,
  }) async {
    if (startDay != null && endDay != null) {
      http.Response res = await http.get(
        Uri.parse(baseURL + 'user/$id/balance/$startDay/$endDay'),
        headers: <String, String>{
          "Content-Type": "application/json",
          "X-Requested-With": "XMLHttpRequest",
          "Authorization": "Bearer $activeToken",
        },
      );

      print(jsonDecode(res.body));
      var body = jsonDecode(res.body);
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      await _prefs.setInt("currentBalance", body['balance']);

      return body['balance'];
    } else {
      var day = _formatDate(DateTime.now());
      TimeOfDay now = TimeOfDay.now();
      print(now.hour < 4);
      TimeOfDay releaseTime = TimeOfDay(hour: 4, minute: 59);

      var endDate = "$day ${now.hour}:${now.minute}:59";
      var startDate = '';
      if (now.hour < 4) {
        var day1 = _formatDate(DateTime.now().subtract(Duration(days: 1)));
        startDate = "$day1 ${releaseTime.hour}:${releaseTime.minute}:59";
      } else {
        startDate = "$day ${releaseTime.hour}:${releaseTime.minute}:59";
      }
      print(startDate);
      print(endDate);

      http.Response res = await http.get(
        Uri.parse(baseURL + 'user/$id/balance/$startDate/$endDate'),
        headers: <String, String>{
          "Content-Type": "application/json",
          "X-Requested-With": "XMLHttpRequest",
          "Authorization": "Bearer $activeToken",
        },
      );

      print(jsonDecode(res.body));
      var body = jsonDecode(res.body);
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      await _prefs.setInt("currentBalance", body['balance']);

      return body['balance'];
    }
  }

  Future<User> login(String phone, String code) async {
    http.Response res = await http.post(
      Uri.parse(baseURL + 'login'),
      body: jsonEncode({
        "phone": phone,
        "password": code,
      }),
      headers: <String, String>{
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
      },
    );

    var body = jsonDecode(res.body);
    print("3RESPONCES");
    print(body);
    if (body['success'] == true) {
      var usr = body['data'];
      activeToken = usr['token'];
      print(usr['data']);

      SharedPreferences _prefs = await SharedPreferences.getInstance();

      User user = User.fromJson(usr);
      activeUser = user;
      userId = user.id;
      userPhone = user.phone;
      userProfile = user.profileId;
      userName = user.name;
      userAddress = user.address;
      userSubscription = user.suscription;
      await getBalance(user.id);

      await _prefs.setString("activeToken", activeToken);
      await _prefs.setBool("isLoggedIn", true);
      await _prefs.setInt("userId", user.id);
      await _prefs.setInt("profileId", user.profileId);
      await _prefs.setString("userPhone", user.phone);
      await _prefs.setString("userName", user.name);
      await _prefs.setString("userAddress", user.address);
      await _prefs.setInt("userSubscription", user.suscription);

      await _prefs.setString("code", code);

      // user.setting = onlineSetting;

      return user;
    } else {
      return null;
    }
  }

  Future<bool> verifyOTPCode(String code) async {
    http.Response res = await http.post(
      Uri.parse(baseURL + 'user/${activeUser.id}/verify/password'),
      body: jsonEncode({
        "old_password": code,
      }),
      headers: <String, String>{
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "Authorization": "Bearer $activeToken",
      },
    );

    print(jsonDecode(res.body));
    var body = jsonDecode(res.body);
    return body['success'];
  }

  Future<bool> updateOTPCode(String code) async {
    http.Response res = await http.post(
      Uri.parse(baseURL + 'user/${activeUser.id}/reset/password'),
      body: jsonEncode({
        "new_password": code,
        "confirm_password": code,
      }),
      headers: <String, String>{
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "Authorization": "Bearer $activeToken",
      },
    );

    print(jsonDecode(res.body));
    var body = jsonDecode(res.body);
    return body['success'];
  }

  Future<List<User>> getUsers() async {
    http.Response res = await http.get(
      Uri.parse(baseURL + 'team/users'),
      headers: <String, String>{
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "Authorization": "Bearer $activeToken",
      },
    );

    var body = jsonDecode(res.body);
    if (body['success'] == true) {
      List<dynamic> productsBody = body['data'];

      List<User> users = productsBody.map(
        (dynamic item) {
          User user = User.fromJson(item);

          return user;
        },
      ).toList();

      return users;
    } else {
      return null;
    }
  }
}

String _formatDate(DateTime date) {
  final format = DateFormat('yyyy-MM-dd');
  return format.format(date);
}
