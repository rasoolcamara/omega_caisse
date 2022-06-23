// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/models/order.dart';
import 'package:ordering_services/models/products.dart';
import 'package:ordering_services/widget/button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:ordering_services/widget/printing_widget.dart';
import 'package:path_provider/path_provider.dart';

class OrderPage extends StatefulWidget {
  OrderPage({
    Key key,
    this.order,
  }) : super(key: key);
  Order order;

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;
  String pathImage;
  ReceiptPrinter receiptPrinter;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initSavetoPath();
    receiptPrinter = ReceiptPrinter();
  }

  initSavetoPath() async {
    //read and write
    //image max 300px X 300px
    final filename = 'omega.png';
    var bytes = await rootBundle.load("assets/omega.png");
    String dir = (await getApplicationDocumentsDirectory()).path;
    writeToFile(bytes, '$dir/$filename');
    setState(() {
      pathImage = '$dir/$filename';
    });
  }

  Future<void> initPlatformState() async {
    bool isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      print("On a des divices");
      print(devices.length);
      print(devices.first.name);
      print(devices.last.name);

      _device = devices.first;
      _devices = devices;
    });

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  final TextEditingController _searchController = TextEditingController();

  final List<String> errors = [];
  String _countryCode = "+221";

  bool _loading = false;

  final spinkit = SpinKitRing(
    color: AppColors.greenDark.withOpacity(0.5),
    lineWidth: 10.0,
    size: 100.0,
  );

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.greenDark,
        title: Text(
          "Reçu",
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
        elevation: 0.0,
      ),
      body: _loading
          ? spinkit
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: _height,
                    width: double.infinity,
                    // padding: const EdgeInsets.only(bottom: 100.0),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        // Montant
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            top: 16.0,
                          ),
                          child: Text(
                            widget.order.ref,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // Date
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 5.0,
                            right: 5.0,
                            top: 16.0,
                          ),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                "Date ",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              _formatDate(DateTime.parse(widget.order.date)),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            left: 22.0,
                            right: 22.0,
                            top: 16.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Description",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "Montant",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 24.0,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: widget.order.products.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Map<String, dynamic> product =
                                      widget.order.products[index];
                                  print('The product');
                                  // print(widget.order.products["username"]);
                                  print(product);
                                  return buildList(
                                    context,
                                    product,
                                    index == widget.order.products.length - 1,
                                  );
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(widget.order.totalAmount),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 50.0,
                              ),
                              Center(
                                child: SizedBox(
                                  width: 280,
                                  height: 50,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    color: AppColors.greenDark,
                                    onPressed: () {
                                      if (_connected) {
                                        receiptPrinter.order = widget.order;
                                        receiptPrinter.printing(pathImage);
                                      } else {
                                        print("Printer don't _connected");
                                        _connect();
                                        receiptPrinter.order = widget.order;
                                        receiptPrinter.printing(pathImage);
                                      }
                                    },
                                    child: Text(
                                      "Imprimer le reçu",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() {
    if (_device == null) {
      show(
        "Aucune imprimante trouvée !",
        duration: Duration(seconds: 8),
      );
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetooth.connect(_device).catchError((error) {
            setState(
              () => _connected = false,
            );
          });
          setState(
            () => _connected = true,
          );
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = false);
  }

//write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        backgroundColor: AppColors.greenDark,
        content: Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        duration: duration,
      ),
    );
  }

  // History
  Widget buildList(
    BuildContext context,
    Map<String, dynamic> product,
    bool isTheLast,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: 1,
        // bottom: 10,
        // left: 10,
        // right: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
          topLeft: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
      ),
      child: Column(
        children: <Widget>[
          _historyItem(context, product),
          !isTheLast
              ? Divider(
                  color: Colors.black38,
                )
              : Divider(
                  color: Colors.white,
                ),
        ],
      ),
    );
  }

  Widget _historyItem(BuildContext context, Map<String, dynamic> product) {
    return Container(
      height: 40,
      padding: EdgeInsets.only(
        top: 1,
        bottom: 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            product['name'],
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(
            product["quantity"].toString() +
                " x " +
                _formatCurrencyForList(product['price']),
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final format = DateFormat('dd/MM/yyyy HH:mm:ss');
  return format.format(date);
}

String _formatCurrencyForList(num amount) {
  var f =
      NumberFormat.currency(locale: "fr-FR", symbol: "FCFA", decimalDigits: 0);
  return f.format(amount);
}

String _formatCurrency(num amount) {
  var f =
      NumberFormat.currency(locale: "fr-FR", symbol: "Fcfa", decimalDigits: 0);
  return f.format(amount);
}
