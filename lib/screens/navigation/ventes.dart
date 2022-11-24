import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:shop_app/models/Cart.dart';


class Ventes extends StatefulWidget {
 final VoidCallback showNavigation;
  final VoidCallback hideNavigation;

   const Ventes({Key? key,
    required this.showNavigation,
    required this.hideNavigation
    }): super(key: key);

  @override
  State<Ventes> createState() => _VentesState();
}

class _VentesState extends State<Ventes> {

   ScrollController scrollController = ScrollController();
 late SingleValueDropDownController _cnt;
  @override
  void initState() {
    _cnt = SingleValueDropDownController();
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.showNavigation();
      } else {
        widget.hideNavigation();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(() {
       if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.showNavigation();
      } else {
        widget.hideNavigation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: scrollController,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add",
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  
  onPressed: () {
    Navigator.pushNamed(context, "/cart");
  },
  child: Icon(Icons.add),
),
    );
  }
}