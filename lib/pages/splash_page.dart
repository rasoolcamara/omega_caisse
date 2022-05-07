// ignore_for_file: prefer_const_constructors
// import 'package:box_app/screens/auth/welcome_back_page.dart';
import 'package:flutter/material.dart';
import 'package:ordering_services/constants/app_api.dart';
import 'package:ordering_services/constants/app_colors.dart';
import 'package:ordering_services/pages/auth/login.dart';
import 'package:ordering_services/pages/home/home.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key key,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Animation<double> opacity;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward().then((_) {
      navigationPage();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void navigationPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var status = prefs.getBool('isLoggedIn') ?? false;
    print('Le status');
    print(status);

    if (status) {
      activeToken = prefs.getString('activeToken');
      userId = prefs.getInt('userId');

      userName = prefs.getString('userName');
      userPhone = prefs.getString('userPhone');
      userProfile = prefs.getInt('profileId');
      userSubscription = prefs.getInt('userSubscription');
      print('Le userPhone');
      print(userProfile);

      print('Le userSubscription');
      print(userSubscription);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: 80,
      decoration: BoxDecoration(
        color: AppColors.greenDark,
        image: DecorationImage(
          image: AssetImage('assets/omega.png'),
          fit: BoxFit.contain,
        ),
        // // color: Colors.transparent.withOpacity(0.1),
      ),
    );
  }
}
