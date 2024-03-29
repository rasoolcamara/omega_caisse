import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ordering_services/constants/app_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaydunyaService {
  Future<String> checkoutInvoice(
    num totalAmount,
  ) async {
    final invoice = {
      "invoice": {
        "total_amount": totalAmount,
        "description":
            "Paiment de $totalAmount dépuis d'abonnement Omega Caisse",
      },
      "store": {
        "name": "Omega Caisse",
        "phone": "+221786342370",
      },
      "custom_data": {
        "phone": userPhone,
      },
      "actions": {
        "callback_url": "https://omega.dohappit.com/api/call-back",
      }
    };

    print("Génération du checkout invoice");
    print(invoice);

    final response = await http.post(
      Uri.parse('https://app.paydunya.com/api/v1/checkout-invoice/create'),
      body: jsonEncode(invoice),
      headers: <String, String>{
        "Content-Type": "application/json",
        "PAYDUNYA-MASTER-KEY": "paydunyaMasterKey",
        "PAYDUNYA-PRIVATE-KEY": "paydunyaPrivateKey",
        'PAYDUNYA-TOKEN': "paydunyaToken"
      },
    );

    var body = jsonDecode(response.body);

    print("Génération du checkout invoice");
    print(body);
    print(body['response_code'].runtimeType);
    if (body['response_code'] == '00') {
      invoiceToken = body['token'];
      invoiceUrl = body['response_text'];
      print("le nouveau checkout invoice token\n");
      print(invoiceToken);
      print(invoiceUrl);

      return body['token'];
    } else {
      return null;
    }
  }
}
