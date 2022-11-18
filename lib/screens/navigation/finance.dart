import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';


class BilanMensuel extends StatefulWidget {
  final VoidCallback showNavigation;
  final VoidCallback hideNavigation;

   const BilanMensuel({Key? key,
    required this.showNavigation,
    required this.hideNavigation
    }): super(key: key);

  @override
  State<BilanMensuel> createState() => _BilanMensuelState();
}

class _BilanMensuelState extends State<BilanMensuel> {

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
        child: Center(child: Text(""),),
      ),
    );
  }
}