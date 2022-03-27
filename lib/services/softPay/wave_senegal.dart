import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ordering_services/constants/app_api.dart';

class WaveService {
  Future<bool> payment(
    String phone,
  ) async {
    final response = await http.post(
      Uri.parse('https://app.paydunya.com/api/v1/softpay/wave-senegal'),
      body: jsonEncode({
        "wave_senegal_fullName": "Omega Caisse",
        "wave_senegal_email": "box@box.com",
        "wave_senegal_phone": phone,
        'wave_senegal_payment_token': invoiceToken,
      }),
      headers: <String, String>{
        "Content-Type": "application/json",
      },
    );

    var body = jsonDecode(response.body);

    print("Payment par WAVE");
    print(body);

    if (body['success'] == true) {
      // await transactionService.newTransaction(
      //     activeToken, customer, transaction);
      return body['success'];
    } else {
      return body['success'];
    }
  }
}
