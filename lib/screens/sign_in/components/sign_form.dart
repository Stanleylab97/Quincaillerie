import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/components/custom_surfix_icon.dart';
import 'package:shop_app/components/form_error.dart';
import 'package:shop_app/helper/keyboard.dart';
import 'package:shop_app/helper/networkHandler.dart';
import 'package:shop_app/screens/forgot_password/forgot_password_screen.dart';
import 'package:shop_app/screens/login_success/login_success_screen.dart';
import '../../../components/default_button.dart';
import '../../../constants.dart';
import '../../../size_config.dart';
//import 'package:data_connection_checker/data_connection_checker.dart';

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  NetworkHandler networkHandler = NetworkHandler();
  bool vis = true;
  late String errorText;
  bool validate = false;
  bool circular = false;
  Logger log = Logger();
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool? remember = false;
  final List<String?> errors = [];

  void addError({String? error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String? error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    remember = value;
                  });
                },
              ),
              Text("Se souvenir de moi"),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, ForgotPasswordScreen.routeName),
                child: Text(
                  "Mot de passe oublié",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  login();
                  // if all are valid then go to success screen
                  KeyboardUtil.hideKeyboard(context);
                }
              },
              child: circular
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      'Connexion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
        ],
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      controller: _password,
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Mot de passe",
        hintText: "Entrez votre mot de passe",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      controller: _username,
      keyboardType: TextInputType.text,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Identifiant",
        hintText: "Entrez votre identifiant",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: FaIcon(FontAwesomeIcons.user),
      ),
    );
  }

  login() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        circular = true;
      });
      Map<String, String> data = {
        "username": _username.text.trim(),
        "password": _password.text.trim()
      };
      DataConnectionStatus status = await isConnected();
      if (status == DataConnectionStatus.connected) {
        var response =
            await networkHandler.authenticateUser("/authenticate", data);

        if (response.statusCode == 200) {
          Map<String, dynamic> output = json.decode(response.body);

          log.v(response.body);
          await prefs.setString('token', output["token"]);
          await prefs.setString('username', output["userName"]);
          await prefs.setString('nom', output["nom"]);
          await prefs.setString('prenom', output["prenoms"]);

          setState(() {
            validate = true;
            circular = false;
          });

          Navigator.pushNamedAndRemoveUntil(
              context, LoginSuccessScreen.routeName, (route) => false);
        } else {
          setState(() {
            validate = false;
            if (response.statusCode == 401) {
              circular = false;
              errorText = 'Identifiant ou mot de passe incorrects';
              log.e('Erreur ${response.statusCode}: $errorText');

              Flushbar(
                margin: EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(8),
                message: errorText,
                icon: Icon(
                  Icons.info_outline,
                  size: 28.0,
                  color: Colors.blue[300],
                ),
                duration: Duration(seconds: 3),
               
              )..show(context);
            }

            if (response.statusCode == 500) {
              circular = false;
              errorText = 'Erreur de connexion au serveur';
              log.e('Erreur ${response.statusCode}: $errorText');
              Flushbar(
                margin: EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(8),
                message: errorText,
                icon: Icon(
                  Icons.info_outline,
                  size: 28.0,
                  color: Colors.blue[300],
                ),
                duration: Duration(seconds: 3),
                
              )..show(context);
            }
          });
        }
      } else {
        setState(() {
          circular = false;
        });
        Flushbar(
            title: "",
            message:
                "",
            flushbarPosition: FlushbarPosition.TOP,
            flushbarStyle: FlushbarStyle.FLOATING,
            reverseAnimationCurve: Curves.decelerate,
            forwardAnimationCurve: Curves.elasticOut,
            backgroundColor: Colors.red,
            boxShadows: [
              BoxShadow(
                  color: Colors.blue[800]!,
                  offset: Offset(0.0, 2.0),
                  blurRadius: 3.0)
            ],
            backgroundGradient:
                LinearGradient(colors: [Colors.blueGrey, Colors.black]),
            isDismissible: false,
            duration: Duration(seconds: 4),
            icon: Icon(
              Icons.info_outline,
              color: Colors.greenAccent,
            ),
            mainButton: FlatButton(
              onPressed: () {},
              child: Text(
                "BAD",
                style: TextStyle(color: Colors.amber),
              ),
            ),
            showProgressIndicator: true,
            progressIndicatorBackgroundColor: Colors.blueGrey,
            titleText: Text(
              "Connexion impossible",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.yellow[600],
                  fontFamily: "ShadowsIntoLightTwo"),
            ),
            messageText: Text(
              "Vérifiez votre connexion internet!",
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.green,
                  fontFamily: "ShadowsIntoLightTwo"),
            ));
      }
    }
  }

  showError(String errormessage) {
    Flushbar(
      message: errormessage,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.blue[300],
      ),
      duration: Duration(seconds: 3),
      leftBarIndicatorColor: Colors.blue[300],
    )..show(context);
  }

  isConnected() async {
    return await DataConnectionChecker().connectionStatus;
    // actively listen for status update
  }
}
