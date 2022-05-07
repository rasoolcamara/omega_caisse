// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/constants/app_text.dart';
import 'package:ordering_services/database/database_helper.dart';
import 'package:ordering_services/models/order.dart';
import 'package:ordering_services/models/products.dart';
import 'package:ordering_services/models/user.dart';
import 'package:ordering_services/pages/history/transaction.dart';
import 'package:ordering_services/services/auth/auth_service.dart';
import 'package:ordering_services/services/order_service/order_service.dart';
import 'package:ordering_services/utils/next_screen.dart';
import 'package:ordering_services/widget/button.dart';
import 'package:url_launcher/url_launcher.dart';

class UserHistoryPage extends StatefulWidget {
  UserHistoryPage({
    Key key,
    this.user,
  }) : super(key: key);

  User user;
  @override
  _UserHistoryPageState createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  OrderService orderService = OrderService();
  // List<Order> orders = [];
  DateTime selectedDate = DateTime(2022);
  final List<String> errors = [];
  String _countryCode = "+221";
  bool hideBalance = true;
  int currentBalance = 1000;
  bool _loading = false;
  bool _searching = false;

  bool _startDateSelected = false;
  bool _endDateSelected = false;

  String _startDate = 'Debut';
  String _endDate = 'Fin';

  List<Order> searchingTransactions = [];

  final spinkit = SpinKitRing(
    color: AppColors.greenDark.withOpacity(0.5),
    lineWidth: 10.0,
    size: 100.0,
  );
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  List<Order> _orderList = [];

  Future<void> _initOrdersData;

  void initState() {
    super.initState();
    _initOrdersData = _initOrders();
    super.initState();
  }

  Padding _balanceWidget(context) {
    return Padding(
      padding: EdgeInsets.only(
        right: 16.0,
        left: 16.0,
        top: 16.0,
      ),
      child: Container(
        // width: 220,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          // image: DecorationImage(image: AssetImage(paymentMethod.logo)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFABABAB).withOpacity(0.2),
              blurRadius: 4.0,
              spreadRadius: 3.0,
            ),
          ],
        ),
        padding: EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Solde",
                    style: regularLightTextStyle(
                      AppColors.greenDark,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hideBalance
                            ? '••••••'
                            : "${_formatCurrency(currentBalance)}",
                        style: bigBoldTextStyle(
                          AppColors.greenDark,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              hideBalance = !hideBalance;
                            });
                          },
                          child: Icon(
                            !hideBalance
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 26.0,
                            color: AppColors.greenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          widget.user.name,
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
          : FutureBuilder(
              future: _initOrdersData,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // List<Order> orders = snapshot.data;

                  return RefreshIndicator(
                    key: refreshkey,
                    backgroundColor: Colors.white,
                    // color: darkGreen,
                    onRefresh: () => _refreshOrders(context),
                    child: _loading
                        ? spinkit
                        : ListView(
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(5.0),
                                    // height: _height,
                                    width: double.infinity,
                                    decoration:
                                        BoxDecoration(color: Colors.white),
                                    child: Column(
                                      children: <Widget>[
                                        _balanceWidget(context),
                                        SizedBox(
                                          height: 24,
                                        ),
                                        _filter(context, _orderList),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        _latestTransactions(
                                          context,
                                          _searching
                                              ? searchingTransactions
                                              : _orderList,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  );
                } else {
                  return Center(
                    child: spinkit,
                  );
                }
              },
            ),
    );
  }

  Future<void> _initOrders() async {
    final orders = await orderService.getOrders(widget.user.id);

    // setState(() {
    // });
    _orderList = orders;
    getTotal(_orderList);
  }

  Future<void> _refreshOrders(BuildContext context) async {
    print("Here");
    final orders = await orderService.getOrders(widget.user.id);

    setState(() {
      _orderList = orders;
      getTotal(_orderList);
      _loading = false;
      _startDate = 'Date de debut';
      _endDate = 'Date de fin';
      _startDateSelected = false;
      _endDateSelected = false;
    });
  }

  void getTotal(List<Order> orders) async {
    var balance = 0;

    orders.forEach((order) {
      balance += order.totalAmount;
    });

    setState(() {
      currentBalance = balance;
    });
  }

  Future<List<Order>> _readAll() async {
    DatabaseHelper helper = DatabaseHelper.instance;

    List<Order> orders = await helper.queryAllOrders();
    if (orders == null) {
      print('read row $orders: empty');
      return [];
    } else {
      print('read row: ${orders.length}');
      return orders;
    }
  }

  /// Item TextFromField Search
  Padding _filter(BuildContext context, List<Order> orders) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        right: 20.0,
        left: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FittedBox(
            fit: BoxFit.fill,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Période: ",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 110,
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 25.5,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              width: 1.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _startDateSelected = true;
                              _endDateSelected = false;
                            });
                            _selectDate(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Text(
                              _startDate,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Container(
                        height: 25.5,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              width: 1.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _startDateSelected = false;
                              _endDateSelected = true;
                            });
                            _selectDate(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Text(
                              _endDate,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                /* Align(
            alignment: Alignment.topRight,
            child: Container(
              height: 50.0,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(2.0),
                ),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.filter_list_rounded,
                  size: 30.0,
                  color: AppColors.greenDark,
                ),
                onPressed: () async {
                  _selectDate(context);
                },
              ),
            ),
          ), */
              ],
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Center(
            child: SizedBox(
              width: 170,
              child: DefaultButton(
                text: "Filtrer",
                press: () async {
                  setState(() {
                    _searching = true;
                    var startDay = DateTime.parse(_startDate);
                    var endDay = DateTime.parse(_endDate);
                    print(startDay);
                    print(endDay);
                    AuthService()
                        .getBalance(
                      widget.user.id,
                      startDay: _startDate,
                      endDay: _endDate,
                    )
                        .then((value) {
                      setState(() {
                        currentBalance = value;
                      });
                    });
                    // orderService
                    //     .getOrders(
                    //   widget.user.id,
                    //   startDay: _startDate,
                    //   endDay: _endDate,
                    // )
                    //     .then((value) {
                    //   setState(() {
                    //     searchingTransactions = value;
                    //   });
                    // });
                    /* if (orders.isEmpty) {
                      var startDay = DateTime.parse(_startDate);
                      var endDay = DateTime.parse(_endDate);
                      print(startDay);
                      print(endDay);
                      orderService
                          .getOrders(
                            widget.user.id,
                            startDay: _startDate,
                            endDay: _endDate,
                          )
                          .then(
                            (value) => searchingTransactions = value,
                          );
                    } else {
                      searchingTransactions = orders.where((Order order) {
                        var date = DateTime.parse(order.date);
                        print(order.date);
                        print(date);
                        print(_startDate);
                        print(_endDate);

                        var startDay = DateTime.parse(_startDate);
                        var endDay = DateTime.parse(_endDate);
                        print(startDay);
                        print(endDay);

                        return order.date.contains(_startDate);
                      }).toList();
                    } */
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Padding _latestTransactions(BuildContext context, List<Order> orders) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      child: orders.isEmpty
          ? Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 8,
                right: 8,
              ),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 25.0, // soften the shadow
                    spreadRadius: 5.0, //extend the shadow
                    offset: Offset(
                      0.0, // Move to right 10  horizontally
                      1.0, // Move to bottom 10 Vertically
                    ),
                  )
                ],
                color: Colors.white,
              ),
              width: double.infinity,
              child: Center(
                child: Text(
                  "Aucune transaction",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    // color: gray.withOpacity(0.4),
                  ),
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 8,
                right: 8,
              ),
              // height: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 25.0, // soften the shadow
                    spreadRadius: 5.0, //extend the shadow
                    offset: Offset(
                      0.0, // Move to right 10  horizontally
                      1.0, // Move to bottom 10 Vertically
                    ),
                  )
                ],
                color: Colors.white,
              ),
              width: double.infinity,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (BuildContext context, int index) {
                  Order order = orders[index];
                  return buildList(
                    context,
                    order,
                    index == orders.length - 1,
                  );
                },
              ),
            ),
    );
  }

  // History
  Widget buildList(
    BuildContext context,
    Order order,
    bool isTheLast,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
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
          _historyItem(context, order),
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

  Widget _historyItem(BuildContext context, Order order) {
    return InkWell(
      onTap: () async {
        nextScreenPopup(
          context,
          OrderPage(
            order: order,
          ),
        );
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.only(
          top: 5,
          bottom: 0,
          left: 10,
          right: 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  order.ref,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _formatDate(
                    DateTime.parse(order.date),
                  ),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _formatCurrencyForList(order.totalAmount),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Succès",
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Date Pickers

  _selectDate(BuildContext context) async {
    final DateTime selected = await showDatePicker(
      context: context,
      initialDate: DateTime(2022),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
      // locale: ,
      helpText: "Choisir la date",
      cancelText: "Annuler",
      confirmText: "Confirmer",
      fieldHintText: "Saisissez la date",
      fieldLabelText: "Saisissez la date",
      initialEntryMode: DatePickerEntryMode.input,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: AppColors.greenDark,
              surface: AppColors.greenDark,
              onSurface: Colors.orange,
            ),
            // ignore: deprecated_member_use
            hintColor: Colors.white,

            dialogBackgroundColor: AppColors.greenDark,
          ),
          child: child,
        );
      },
    );

    if (selected != null && selected != selectedDate) {
      setState(
        () {
          selectedDate = selected;
          _startDate =
              _startDateSelected ? _formatPickerDate(selectedDate) : _startDate;
          _endDate =
              _endDateSelected ? _formatPickerDate(selectedDate) : _endDate;

          // _dateController.text = _formatDate(selectedDate);
          // "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
          print(
              "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}");
        },
      );
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}

String _formatDate(DateTime date) {
  final format = DateFormat('dd/MM/yyyy HH:mm:ss');
  return format.format(date);
}

String _formatPickerDate(DateTime date) {
  final format = DateFormat('yyyy-MM-dd');
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
