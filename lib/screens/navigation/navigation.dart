import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shop_app/screens/navigation/account.dart';
import 'package:shop_app/screens/navigation/finance.dart';
import 'package:shop_app/screens/navigation/ventes.dart';


//import 'package:awesome_bottom_navigation/awesome_bottom_navigation.dart';

class Dashboard extends StatefulWidget {
  static String routeName = "/navigation";
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  bool visible = true;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static const List<Widget> _widgetOptions = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Ventes(
            hideNavigation: hideNav,
            showNavigation: showNav,
          ),
          BilanMensuel(
            hideNavigation: hideNav,
            showNavigation: showNav,
          ),
         Account(hideNavigation: hideNav,
            showNavigation: showNav,
          ),
          
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: Duration(microseconds: 1000),
        height: visible ? kBottomNavigationBarHeight + 10 : 0,
        curve: Curves.fastLinearToSlowEaseIn,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.blue,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 300),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: [
                GButton(
                  icon: LineIcons.list,
                  text: 'Ventes',
                ),
                GButton(
                  icon: LineIcons.moneyBill,
                  text: 'Point du mois',
                ),
               
                GButton(
                  icon: LineIcons.user,
                  text: 'Compte',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  void hideNav() {
    setState(() {
      visible = false;
    });
  }

  void showNav() {
    setState(() {
      visible = true;
    });
  }
}
