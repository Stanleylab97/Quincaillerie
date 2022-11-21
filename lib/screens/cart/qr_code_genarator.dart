import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
/* import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart'; */
import 'package:flutter/services.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/enums.dart';
import 'package:shop_app/screens/cart/cart_screen.dart';
import 'package:shop_app/screens/cart/devices.dart';
import 'package:flutter_telpo/flutter_telpo.dart';
import 'package:flutter_telpo/model/row.dart';
import '../../constants.dart';
import '../../size_config.dart';

import 'package:flutter/services.dart';
import 'dart:async';

//import 'package:telpo_flutter_sdk/telpo_flutter_sdk.dart';

const telpoColor = Color(0xff005AFF);

class QrCodeGenerator extends StatefulWidget {
  static String routeName = "/qrcode";

  String? codeFacture;
  QrCodeGenerator({this.codeFacture});

  @override
  State<QrCodeGenerator> createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  String nom = "";
  String prenom = "";

  void geUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nom = prefs.getString('nom').toString();
      prenom = prefs.getString('prenom').toString();
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

  bool _connected = false;
  String _telpoStatus = 'Not initialized';
  bool _isLoading = false;
  //final _telpoFlutterChannel = TelpoFlutterChannel();

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _connect() async {
    // Platform calls are catched on plugin-side. No need to use try-catch here,
    // as connect() method returns non-nullable boolean.

    // final bool connected = await _telpoFlutterChannel.connect();

    /*   setState(() {
      _connected = connected;

      _telpoStatus = _connected ? 'Connected' : 'Telpo not supported';
    });
  }

  Future<void> _checkStatus() async {
    String telpoStatus;

    final TelpoStatus status = await _telpoFlutterChannel.checkStatus();
    telpoStatus = status.name;

    setState(() => _telpoStatus = telpoStatus);
  } 

  Future<void> _printData() async {
    setState(() => _isLoading = true);

    // Creating an [TelpoPrintSheet] instance.
    final sheet = TelpoPrintSheet();

    // Creating a text element
    final textData = PrintData.text(
      'Facture F005879',
      alignment: PrintAlignment.center,
      fontSize: PrintedFontSize.size34,
    );

   

    // Creating 8-line empty space element.
    final spacing = PrintData.space(line: 8);

    final qr= PrintData.byte(bytesList: []);

    // Inserting previously created text element to the sheet.
    sheet.addElement(textData);

    // Inserting previously created spacing element to the sheet.
    sheet.addElement(spacing);

    final PrintResult result = await _telpoFlutterChannel.print(sheet);

    setState(() {
      _telpoStatus = result.name;
      _isLoading = false;
    });
  }

  @override
  void setState(VoidCallback fn) {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    if (mounted) {
      super.setState(fn);
    }
  }

  
  @override
  void dispose() {
    // Disconnecting from Telpo.
    _telpoFlutterChannel.disconnect();
    super.dispose();
  }
*/

    Future<void> _captureAndSharePng() async {
      try {
        RenderRepaintBoundary? boundary = globalKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary?;
        var image = await boundary!.toImage();
        ByteData? byteData =
            await image.toByteData(format: ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        final tempDir = await getTemporaryDirectory();
        final file = await new File('${tempDir.path}/image.png').create();
        await file.writeAsBytes(pngBytes);

        final channel = const MethodChannel('channel:me.alfian.share/share');
        channel.invokeMethod('shareFile', 'image.png');
      } catch (e) {
        print(e.toString());
      }
    }
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: Center(
            child: RepaintBoundary(
                key: globalKey,
                child: QrImage(
                  data: widget.codeFacture!,
                  size: 0.3 * bodyHeight,
                  embeddedImage: AssetImage('assets/images/AfricUni-carre.png'),
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(100, 100),
                  ),
                  errorStateBuilder: (cxt, err) {
                    return Center(
                      child: Text(
                        "Votre inscription est validée mais le code ne peut s'afficher",
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                )),
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(18)),
        Text(
          "Merci à vous $nom $prenom",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: getProportionateScreenHeight(18)),
        Text("Un point bonus a été ajouté sur votre compte",
            textAlign: TextAlign.center),
        Spacer(flex: 2),
        DefaultButton(
          text: "Imprimer",
          press: () async {
            final prefs = await SharedPreferences.getInstance();

            FlutterTelpo _printer = new FlutterTelpo();

            try {
              _printer.connect();
              _printer.isConnected().then((var isConneted) async {
                if (isConneted == true) {
                  List<dynamic> _printables = [];

                  _printables.addAll([
                    PrintRow(
                      text: "QUINCAILLERIE ANGE ROSE",
                      fontSize: 2,
                      position: 1,
                    ),
                    PrintRow(
                        text: "*****************************",
                        fontSize: 1,
                        position: 1),
                  ]);
                  _printables.add(PrintQRCode(
                      text: widget.codeFacture!,
                      height: 300,
                      width: 300,
                      position: 1));
                  _printables.addAll([
                    PrintRow(
                        text: "Passez à la caisse SVP",
                        fontSize: 2,
                        position: 1),
                  ]);

                  _printables.add(
                    PrintRow(
                      text: "Code valable jusqu'au 20/10/2022",
                      fontSize: 1,
                      position: 1,
                    ),
                  );

                  _printables.addAll([
                    PrintRow(
                      text: "Enregistrée par:",
                      fontSize: 1,
                      position: 1,
                    ),
                    PrintRow(
                        text: "${await prefs.getString('prenom')}",
                        fontSize: 1,
                        position: 1),
                  ]);

                  _printer.print(_printables.toList());
                }
              });
            } on PlatformException catch (e) {
              print(e);
            }
          },
        ),
        SizedBox(height: getProportionateScreenHeight(18)),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DefaultButton(
            text: "Retour à l'achat",
            press: () {
              Navigator.pushReplacementNamed(context, CartScreen.routeName);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _contentWidget(),
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
      width: MediaQuery.of(context).size.width * .6,
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
