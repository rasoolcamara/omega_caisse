import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:ordering_services/constants/app_api.dart';

class WaveService {
  Future<bool> payment() async {
    final response = await http.post(
      Uri.parse('https://api.wave.com/v1/checkout/sessions'),
      body: jsonEncode({
        "amount": amountToPay,
        "currency": "XOF",
        "error_url": playStoreUrl,
        "success_url": playStoreUrl
      }),
      headers: <String, String>{
        "Content-Type": "application/json",
        'Authorization': 'Bearer $waveAPIKEY',
      },
    );

    var body = jsonDecode(response.body);

    print("Payment par WAVE");
    print(body);

    if (body['wave_launch_url'] != null) {
      // await this.payout(transaction);
      waveLaunchUrl = body['wave_launch_url'];

      return true;
    } else {
      return false;
    }
  }
}
