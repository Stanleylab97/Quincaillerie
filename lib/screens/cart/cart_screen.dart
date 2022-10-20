import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/ArticleVente.dart';
import 'package:shop_app/models/Cart.dart';
import 'package:substring_highlight/substring_highlight.dart';
import '../../helper/networkHandler.dart';
import 'components/body.dart';
import 'components/check_out_card.dart';
import 'components/styles.dart';
import 'hero_dialogue_route.dart';

class CartScreen extends StatefulWidget {
  static String routeName = "/cart";

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Body(),
      bottomNavigationBar: CheckoutCard(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Achat du client",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          Container(
            child: Row(
              children: [
                Text(
                  "${demoCarts.length} commandes",
                  style: Theme.of(context).textTheme.caption,
                ),
                GestureDetector(
                  child: Hero(
                    tag: _heroAddTodo,
                    child: FaIcon(
                      FontAwesomeIcons.cartPlus,
                      color: kPrimaryColor,
                      size: 30,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(HeroDialogRoute(
                        builder: (context) {
                          return const _AddTodoPopupCard();
                        },
                        settings: RouteSettings()));
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const String _heroAddTodo = 'add-todo-hero';

/// {@template add_todo_popup_card}
/// Popup card to add a new [Todo]. Should be used in conjuction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroAddTodo].
/// {@endtemplate}
class _AddTodoPopupCard extends StatefulWidget {
  /// {@macro add_todo_popup_card}
  const _AddTodoPopupCard({Key? key}) : super(key: key);

  @override
  State<_AddTodoPopupCard> createState() => _AddTodoPopupCardState();
}

class _AddTodoPopupCardState extends State<_AddTodoPopupCard> {
  NetworkHandler networkHandler = NetworkHandler();
  bool isLoading = false;
  Logger log = Logger();
  String token = "";
  late String errorText;

  late List<ArticleVente> autoCompleteData = [];

  late TextEditingController controller;

  isConnected() async {
    return await DataConnectionChecker().connectionStatus;
    // actively listen for status update
  }

  getArticles() async {
    DataConnectionStatus status = await isConnected();
    List<ArticleVente> list = [];
    if (status == DataConnectionStatus.connected) {
      var response = await networkHandler.get("/allArticleVentes");

      if (response.statusCode == 200) {
        Map<String, dynamic> output = json.decode(response.body);
        var y = output['object']
            .map((article) => ArticleVente.fromJson(article))
            .toList();
        // log.v(y);
        for (ArticleVente i in y) {
          list.add(i);
        }
        setState(() {
          autoCompleteData = list;
          isLoading = false;
        });
      } else {
        setState(() {
          if (response.statusCode == 401) {
            errorText = 'Token invalide. Veuillez vous reconnecter';
            log.e('Erreur ${response.statusCode}: $errorText');
            isLoading = false;

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

            autoCompleteData = [];
          }

          if (response.statusCode == 500) {
            errorText = 'Erreur de connexion au serveur';
            log.e('Erreur ${response.statusCode}: $errorText');
            isLoading = false;
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
            autoCompleteData = [];
          }
        });
      }
    } else {
      setState(() {
        autoCompleteData = [];
      });
      Flushbar(
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        message: 'Veuillez vérifier votre connexion internet',
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.blue[300],
        ),
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  Future fetchAutoCompleteData() async {
    setState(() {
      isLoading = true;
    });

    getArticles();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    fetchAutoCompleteData();
    super.initState();
  }

  @override
  void dispose() {
  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Hero(
          tag: _heroAddTodo,
          child: Material(
            color: kPrimaryColor,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: Text(
                          'Enregistrement de commande',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const Divider(
                        color: Colors.white,
                        thickness: 0.2,
                      ),
                      isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Autocomplete<ArticleVente>(
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text.isEmpty) {
                                        return List.empty();
                                      } else {
                                        return autoCompleteData.where(
                                            (article) => article.libelle
                                                .toLowerCase()
                                                .contains(textEditingValue.text
                                                    .toLowerCase()));
                                      }
                                    },
                                    optionsViewBuilder:
                                        (context, onSelected, options) {
                                      return Material(
                                        elevation: 4,
                                        child: ListView.separated(
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            final option =
                                                options.elementAt(index);

                                            return ListTile(
                                              title: SubstringHighlight(
                                                text: option.libelle,
                                                term: controller.text,
                                                textStyleHighlight: TextStyle(
                                                    fontWeight:
                                              FontWeight.w700),
                                              ),
                                              onTap: () {
                                                onSelected(option);
                                              },
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              Divider(),
                                          itemCount: options.length,
                                        ),
                                      );
                                    },
                                    onSelected: (selectedString) =>
                                        print(selectedString.libelle),
                                    displayStringForOption: (ArticleVente d) =>
                                        '${d.libelle} ${d.prixUnitaire} ${d.qteStock}',
                                    fieldViewBuilder: (context, controller,
                                        focusNode, onEditingComplete) {
                                      this.controller = controller;

                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        onEditingComplete: onEditingComplete,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          hintText: "Recherche d'article",
                                          hintStyle:TextStyle(color: Colors.white),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: TextStyle(color: Colors.white),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                      const Divider(
                        color: Colors.white,
                        thickness: 0.2,
                      ),
                      TextButton(
                        style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.all(Colors.deepPurple),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          elevation: MaterialStateProperty.all(7),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Ajouter',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
