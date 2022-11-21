import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/blocs/vente/bloc/vente_bloc.dart';
import 'package:shop_app/components/default_button.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/ArticleVente.dart';
import 'package:shop_app/models/Cart.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/size_config.dart';
import 'package:substring_highlight/substring_highlight.dart';
import '../../helper/networkHandler.dart';
import 'components/body.dart';
import 'components/styles.dart';
import 'hero_dialogue_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartScreen extends StatefulWidget {
  static String routeName = "/cart";

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<ArticleVente> venteItems;
  List<CartItem> cartItems = [];
  bool loadingData = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocListener<VenteBloc, VenteState>(
      listener: (context, state) {
        if (state is VenteInitial) {
          loadingData = true;
        }
        if (state is VentePageLoadedState) {
          venteItems = state.avalaibleProducts.products;
          cartItems = state.cartData;
          loadingData = false;
        }
        if (state is ItemAddedCartState) {
          cartItems = state.cartItems;
        }
        if (state is ItemDeletingCartState) {
          cartItems = state.cartItems;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Achat du client",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
              Container(
                child: Row(
                  children: [
                    BlocBuilder<VenteBloc, VenteState>(
                      builder: (context, state) {
                        return Text(
                          "${cartItems.length.toString()} articles",
                          style: Theme.of(context).textTheme.caption,
                        );
                      },
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
        ),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Enregistrement de commande',
                style: Theme.of(context).textTheme.headline5!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Livraison incluse?',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    /*  BlocBuilder<BasketBloc, BasketState>(
                      builder: (context, state) {
                        if (state is BasketLoading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is BasketLoaded) {
                          return SizedBox(
                            width: 100,
                            child: SwitchListTile(
                                dense: false,
                                value: state.basket.isdelivered!,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                onChanged: (bool? newValue) {
                                  context.read<BasketBloc>().add(
                                        ToggleSwitch(),
                                      );
                                }),
                          );
                        } else {
                          return Text('Something went wrong.');
                        }
                      },
                    ), */
                  ],
                ),
              ),
              Text(
                'Produits ajoutés',
                style: Theme.of(context).textTheme.headline5!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              BlocListener<VenteBloc, VenteState>(listener: (context, state) {
                if (state is VenteInitial) {
                  loadingData = true;

                  /*    return Center(
                      child: CircularProgressIndicator(),
                    ); */
                }
                if (state is VentePageLoadedState) {
                  venteItems = state.avalaibleProducts.products;
                  cartItems = state.cartData;
                  loadingData = false;
                }
                if (state is ItemAddedCartState) {
                  cartItems = state.cartItems;
                }

                if (state is ItemDeletingCartState) {
                  cartItems = state.cartItems;
                }
              }, child:
                  BlocBuilder<VenteBloc, VenteState>(builder: (context, state) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return Container(
                      /*  width: double.infinity,
                                margin: const EdgeInsets.only(top: 5), */
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ssss"),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Text(
                              '',
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          Text(
                            '\$',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }))
            ])),
        //Body(),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(
            vertical: getProportionateScreenWidth(15),
            horizontal: getProportionateScreenWidth(30),
          ),
          // height: 174,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -15),
                blurRadius: 20,
                color: Color(0xFFDADADA).withOpacity(0.15),
              )
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      height: getProportionateScreenWidth(40),
                      width: getProportionateScreenWidth(40),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F6F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SvgPicture.asset("assets/icons/receipt.svg"),
                    ),
                    Text.rich(
                      TextSpan(
                        text: "Total:\n",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                        children: [
                          TextSpan(
                            text:
                                "50000 XOF", //"${state.basket.totalString} XOF",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                Center(
                  child: DefaultButton(
                    text: "Enregistrer",
                    press: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=> QrCodeGenerator(codeFacture: "1254848"))) ;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
  bool haveSelectedProduct = false;
  late TextEditingController controller = TextEditingController();
  late TextEditingController qteCtrl = TextEditingController();
  int qte = 0;

  Widget _incrementButton(int index) {
   

    return MaterialButton(
      onPressed: () {
        setState(() {
          qte = index;
          qte++;
          qteCtrl.text = qte.toString();
        });
      },
      color: Colors.white,
      textColor: Colors.white,
      child: Icon(Icons.add, color: Colors.black),
      padding: EdgeInsets.all(16),
      shape: CircleBorder(),
    );
  }

  Widget _decrementButton(int index) {
    return MaterialButton(
      onPressed: () {
        setState(() {
          qte = index;
          qte--;
          qteCtrl.text = qte.toString();
        });
      },
      color: Colors.white,
      textColor: Colors.white,
      child: Icon(Icons.remove, color: Colors.black),
      padding: EdgeInsets.all(16),
      shape: CircleBorder(),
    );
  }

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
    qteCtrl.text = "1";
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
                              padding: const EdgeInsets.only(left:16.0, top:16.0, bottom: 16.0),
                              child: Column(children: [
                                Autocomplete<ArticleVente>(
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return List.empty();
                                    } else {
                                      return autoCompleteData.where((article) =>
                                          article.libelle
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
                                                  fontWeight: FontWeight.w700),
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
                                  onSelected: (selectedString) {
                                    //  print(selectedString.libelle);
                                    setState(() {
                                      haveSelectedProduct = true;
                                      qteCtrl.text = "1";
                                    
                                    });
                                  },
                                  displayStringForOption: (ArticleVente d) =>
                                      '${d.libelle} ${d.prixUnitaire} Stock:${d.qteStock}',
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
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: TextStyle(color: Colors.white),
                                    );
                                  },
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .03,
                                ),
                                Visibility(
                                    visible: haveSelectedProduct,
                                    
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _decrementButton(
                                              int.parse(qteCtrl.text)),
                                          Flexible(
                                            child: TextFormField(
                                              keyboardType: TextInputType.number,
                                              style: TextStyle(color: Colors.white),
                                              controller: qteCtrl,
                                            ),
                                          ),
                                          _incrementButton(
                                              int.parse(qteCtrl.text)),
                                        ],
                                      ),
                                    ),
                              ]),
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
                          //context.read<VenteBloc>().add(ItemAddedCartEvent(cartItems: cartItems));
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
