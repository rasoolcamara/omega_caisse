import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/models/order.dart';

class ReceiptPrinter {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  Order order;
  String date = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

  printing(String pathImage) async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printCustom("RECU DE CAISSE", 2, 1);
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
        bluetooth.printCustom("================", 2, 0);
        bluetooth.printLeftRight("TOTAL", "${order.totalAmount} fcfa", 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();

        bluetooth.paperCut();
      }
    });
  }
}
