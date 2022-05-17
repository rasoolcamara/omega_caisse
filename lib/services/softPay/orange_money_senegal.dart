import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/pages/home/home.dart';
import 'package:ordering_services/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OMSNService {
  Future<bool> payment(String phone, String code) async {
    final response = await http.post(
      Uri.parse('https://app.paydunya.com/api/v1/softpay/orange-money-senegal'),
      body: jsonEncode({
        "customer_name": "Omega Caisse",
        "customer_email": "omegacaisse@omegacaisse.com",
        "phone_number": phone,
        'authorization_code': code,
        'invoice_token': invoiceToken,
      }),
      headers: <String, String>{
        "Content-Type": "application/json",
      },
    );

    var body = jsonDecode(response.body);

    print("Payment par OMSN");
    print(body);

    if (body['success'] == true) {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var code = _prefs.getString('code');
      AuthService authService = AuthService();

      final user = await authService.login(
        userPhone,
        code,
      );

      return body['success'];
    } else {
      // return body['message'];
      return body['success'];
    }
  }
}
