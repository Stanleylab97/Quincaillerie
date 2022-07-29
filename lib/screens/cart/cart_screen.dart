import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/Cart.dart';
import 'package:substring_highlight/substring_highlight.dart';

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
  bool isLoading = false;

  late List<String> autoCompleteData;

  late TextEditingController controller;

  Future fetchAutoCompleteData() async {
    setState(() {
      isLoading = true;
    });

    final String stringData = await rootBundle.loadString("assets/data.json");

    final List<dynamic> json = jsonDecode(stringData);

    final List<String> jsonStringData = json.cast<String>();

    setState(() {
      isLoading = false;
      autoCompleteData = jsonStringData;
    });
  }
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
  bool isLoading = false;

  late List<String> autoCompleteData;

  late TextEditingController controller;

  Future fetchAutoCompleteData() async {
    setState(() {
      isLoading = true;
    });

    final String stringData = await rootBundle.loadString("assets/data.json");

    final List<dynamic> json = jsonDecode(stringData);

    final List<String> jsonStringData = json.cast<String>();

    setState(() {
      isLoading = false;
      autoCompleteData = jsonStringData;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _heroAddTodo,
          child: Material(
            color: kPrimaryColor,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(child: Text('Enregistrement de commande', style: TextStyle(color: Colors.white),),),
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
                  Autocomplete(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      } else {
                        return autoCompleteData.where((word) => word
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      }
                    },
                    optionsViewBuilder:
                        (context, Function(String) onSelected, options) {
                      return Material(
                        elevation: 4,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);

                            return ListTile(
                              // title: Text(option.toString()),
                              title: SubstringHighlight(
                                text: option.toString(),
                                term: controller.text,
                                textStyleHighlight: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text("This is subtitle"),
                              onTap: () {
                                onSelected(option.toString());
                              },
                            );
                          },
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: options.length,
                        ),
                      );
                    },
                    onSelected: (selectedString) {
                      print(selectedString);
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      this.controller = controller;

                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          hintText: "Recherche d'article",
                          prefixIcon: Icon(Icons.search, color: Colors.white,),
                        ),
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
                      style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.deepPurple), backgroundColor:MaterialStateProperty.all(Colors.white),elevation: MaterialStateProperty.all(7), shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),),
                      onPressed: () {Navigator.of(context).pop();},
                      child: const Text('Ajouter',style: TextStyle(color: Colors.black),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
