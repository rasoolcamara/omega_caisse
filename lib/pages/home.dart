import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:ordering_services/constants/app_colors.dart';

import 'ordering_page.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({Key key}) : super(key: key);

  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}



class _HomeScreenPageState extends State<HomeScreenPage> {

  int _currentIndex = 0;
  PageController _pageController = PageController();

  List<IconData> iconList = [
    Feather.home,
    Feather.bookmark,
    Feather.user,
    Feather.bell
  ];
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(index,
        curve: Curves.easeIn, duration: Duration(milliseconds: 350));
  }

  @override
  void dispose() {
    _pageController.dispose();
    //context.read<AdsBloc>().dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeColor: AppColors.PRIMARY_COLOR,
        backgroundColor: AppColors.ACCENT_COLOR,
        gapLocation: GapLocation.none,
        activeIndex: _currentIndex,
        inactiveColor: Colors.white,
        onTap: (index) => onTabTapped(index),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          EcommerceFivePage(),
        ],
      ),
    );
  }

}
