import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/models/order.dart';

class ReceiptPrinter {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  Order order;
  String date = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

  printing(String pathImage) async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT

//     var response = await http.get("IMAGE_URL");
//     Uint8List bytes = response.bodyBytes;
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printCustom("RECU DE CAISSE", 3, 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight(userName, "", 1);
        bluetooth.printLeftRight(userAddress, "", 1);
        bluetooth.printLeftRight(userPhone, "", 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight(date, "", 1);
        bluetooth.printCustom("================", 2, 0);
        bluetooth.printNewLine();
        bluetooth.printLeftRight("Description", "Prix (fcfa)", 1,
            format: "%-15s %15s %n");
        bluetooth.printNewLine();
        for (int i = 0; i < order.products.length; i++) {
          var name = order.products[i]["name"].toString().length > 14
              ? order.products[i]["name"].toString().substring(0, 14)
              : order.products[i]["name"].toString();
          bluetooth.printLeftRight("${order.products[i]["quantity"]}x$name",
              "${order.products[i]["price"]}", 1);
        }
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printLeftRight("TOTAL", "${order.totalAmount} fcfa", 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("================", 2, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("MERCI POUR VOTRE CONFIANCE", 2, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom(
            "OMEGA CAISSE +221 78 634 23 70 / +221 76 193 71 05", 0, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }
}
