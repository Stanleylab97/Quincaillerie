import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:shop_app/routes.dart';
import 'package:shop_app/theme.dart';
import 'splash.dart';

void main() {
 // Bloc.observer=SimpleBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme(),
      initialRoute: Splash.routeName,
      routes: routes,
    );
  }
}
