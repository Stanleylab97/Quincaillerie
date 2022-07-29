import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/screens/cart/cart_screen.dart';

import '../../constants.dart';
import '../../size_config.dart';


class QrCodeGenerator extends StatefulWidget {
    static String routeName = "/qrcode";

   String? codeFacture;
  QrCodeGenerator({ this.codeFacture});

  @override
  State<QrCodeGenerator> createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
   String nom="";
   String prenom="";


void geUserInfo() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
     nom= prefs.getString('nom').toString();
     prenom=prefs.getString('prenom').toString();
  });


 


}
   @override
  void initState() {
    geUserInfo();
    super.initState();


  }

  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: _contentWidget(),
    );
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary? boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      var image = await boundary!.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      final channel = const MethodChannel('channel:me.alfian.share/share');
      channel.invokeMethod('shareFile', 'image.png');

    } catch(e) {
      print(e.toString());
    }
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
    return  Container(
      color: const Color(0xFFFFFFFF),
      child:
          Column(
            children: [
              Expanded(
                flex: 8,
                child:  Center(
                  child: RepaintBoundary(
                      key: globalKey,
                      child: QrImage(
                        data: widget.codeFacture!,
                        size: 0.3 * bodyHeight,
                        embeddedImage: AssetImage('assets/images/AfricUni-carre.png'),
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          size: Size(100, 100),
                        ),
                        errorStateBuilder:
                            (cxt, err) {
                          return Container(
                            child: Center(
                              child: Text(
                                "Votre inscription est validée mais le code ne peut s'afficher",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      )
                  ),
                ),
              ),
              
              SizedBox(height: getProportionateScreenHeight(18)),
              Text("Merci à vous $nom $prenom", textAlign: TextAlign.center, style: TextStyle(fontSize: 16),),
              SizedBox(height: getProportionateScreenHeight(18)),
              Text("Un point bonus a été ajouté sur votre compte", textAlign: TextAlign.center),
              Spacer(flex: 2),
              DefaultButton(
                text: "Retour à l'achat",
                press: () {

                  Navigator.pushReplacementNamed(context, CartScreen.routeName);

                },
              ),
            ],
          ),

    );
  }
}

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key? key,
    this.text,
    this.press,
  }) : super(key: key);
  final String? text;
  final Function? press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: getProportionateScreenHeight(56),
      child: TextButton(
        style: TextButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          primary: Colors.white,
          backgroundColor: kPrimaryColor,
        ),
        onPressed: press as void Function()?,
        child: Text(
          text!,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(18),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}