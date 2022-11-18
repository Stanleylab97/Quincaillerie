import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/blocs/vente/bloc/vente_bloc.dart';
import 'package:shop_app/routes.dart';
import 'package:shop_app/screens/profile/profile_screen.dart';
import 'package:shop_app/screens/splash/splash_screen.dart';
import 'package:shop_app/theme.dart';
import 'splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
        
          BlocProvider(
            create: (context) => VenteBloc()
           
          ),
        ],
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme(),
      initialRoute: Splash.routeName,
      routes: routes,
    ));
  }
}
