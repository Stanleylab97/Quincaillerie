import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/blocs/vente/bloc/vente_bloc.dart';
import 'package:shop_app/components/cart_item.dart';
import 'package:shop_app/components/default_button.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/controllers/cart_controller.dart';
import 'package:shop_app/models/ArticleVente.dart';
import 'package:shop_app/models/Cart.dart';
import 'package:shop_app/models/cartItemForBackend.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/screens/cart/qr_code_genarator.dart';
import 'package:shop_app/size_config.dart';
import 'package:substring_highlight/substring_highlight.dart';
import '../../helper/networkHandler.dart';
import 'components/body.dart';
import 'components/styles.dart';
import 'hero_dialogue_route.dart';

class CartScreen extends StatefulWidget {
  static String routeName = "/cart";

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final controller = Get.put(CartController());
  late List<ArticleVente> venteItems;
  List<CartItem> cartItems = [];
  bool loadingData = true;
  TextEditingController nom_prenom = TextEditingController();
  NetworkHandler networkHandler = NetworkHandler();
  bool vis = true;
  late String errorText;
  bool validate = false;
  bool circular = false;
  Logger log = Logger();
  bool statut = false;
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  
  bool isLoading = false;

  String token = "";

  final cartController = Get.put(CartController());
  late List<ArticleVente> autoCompleteData = [];
  bool haveSelectedProduct = false;
  late TextEditingController libcontroller = TextEditingController();
  late TextEditingController qteCtrl = TextEditingController();
  int qte = 0;
  late ArticleVente articleVente;

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



  saveFacture() async {
    //  if (_formKey.currentState!.validate()) {
    final prefs = await SharedPreferences.getInstance();
    // final storage = new FlutterSecureStorage();
    setState(() {
      circular = true;
    });
    var x = <CartItemForBackend>[];
    print(controller.products.keys.toList());
    for (var item in controller.products.keys.toList())
      x.add(CartItemForBackend(
          articleVenteId: item.id,
          mtn: item.prixUnitaire.toDouble(),
          qte: controller.products[item]));

    var products = x.map((e) {
      return {
        "articleVenteId": e.articleVenteId,
        "mtn": e.mtn,
        "qte": e.qte,
      };
    }).toList();

    String encodedProducts = json.encode(products);

    DataConnectionStatus status = await isConnected();
    if (status == DataConnectionStatus.connected) {
      Map<String, dynamic> data = {
        "client": "${nom_prenom.text.trim()}",
        "listArticle": products,
        "mtnTotale": controller.total.toDouble(),
        "userName": "${prefs.getString('username')}"
      };
      var url = NetworkHandler.baseurl + "/saveVente/mobileVersion";
      print(data);
      var response =
          await networkHandler.post(url, prefs.getString('token')!, data);

      log.v(response.statusCode);
      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> output = json.decode(response.body);
          controller.clearCart;
        setState(() {
          validate = true;
          circular = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QrCodeGenerator(codeFacture: output['object']['codePrescription'])));
      } else {
        setState(() {
          validate = false;
          if (response.statusCode == 401) {
            circular = false;
            errorText = 'Identifiant ou mot de passe incorrects';
            //log.e('Erreur ${response.statusCode}: $errorText');
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
            errorText = 'Erreur système détectée';
            CherryToast.error(
                    title: Text("Erreur réseau",
                        style: TextStyle(color: Colors.black)),
                    displayTitle: false,
                    description: Text(errorText),
                    animationType: AnimationType.fromRight,
                    animationDuration: Duration(milliseconds: 1000),
                    autoDismiss: true)
                .show(context);
          } else {
            circular = false;
          }
        });

        nom_prenom.clear();
      }
    } else {
      setState(() {
        circular = false;
      });
      CherryToast.error(
              title: Text("Erreur réseau"),
              displayTitle: false,
              description: Text(
                "Vérifiez votre connexion internet!",
                style: TextStyle(color: Colors.black),
              ),
              animationType: AnimationType.fromRight,
              animationDuration: Duration(milliseconds: 1000),
              autoDismiss: true)
          .show(context);
    }
    // }
  }

  showDataAlert() {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          contentPadding: EdgeInsets.only(
            top: 10.0,
          ),
          title: Text(
            "Ajout de produit",
            style: TextStyle(fontSize: 24.0),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height * .4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                       
                        const Divider(
                          color: Colors.black,
                          thickness: 0.2,
                        ),
                        isLoading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 16.0, bottom: 16.0),
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
                                                term: libcontroller.text,
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
                                        qte = selectedString.qteStock;
                                        articleVente = ArticleVente(
                                            id: selectedString.id,
                                            libelle: selectedString.libelle,
                                            prixUnitaire:
                                                selectedString.prixUnitaire,
                                            qteStock: selectedString.qteStock);
                                      });
                                    },
                                    displayStringForOption: (ArticleVente d) =>
                                        '${d.libelle} ${d.prixUnitaire}',
                                    fieldViewBuilder: (context, libcontroller,
                                        focusNode, onEditingComplete) {
                                      this.libcontroller = libcontroller;
    
                                      return TextField(
                                        controller: libcontroller,
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
                                              TextStyle(color: Colors.black),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Colors.black,
                                          ),
                                        ),
                                        style: TextStyle(color: Colors.black),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height * .03,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        suffix: Text(
                                      "Stock: ${qte}",
                                      style: TextStyle(color: Colors.black),
                                    )),
                                    style: TextStyle(color: Colors.black),
                                    controller: qteCtrl,
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
                            cartController.addProduct(
                                articleVente, int.parse(qteCtrl.text));
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
        );
      });
}

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
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
                  Obx(
                    () => Text(
                      "${controller.products.length} articles",
                      style: Theme.of(context).textTheme.caption,
                    ),
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
                     /*  Navigator.of(context).push(HeroDialogRoute(
                          builder: (context) {
                            return const _AddTodoPopupCard();
                          },
                          settings: RouteSettings())); */
                         // print('xxxxx');
                         showDataAlert();
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
              'Produits ajoutés',
              style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            SizedBox(
              height: size.height * .02,
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    return CartProductCard(
                      product: CartItem(
                          article: controller.products.keys.toList()[index],
                          qte: controller.products.values.toList()[index]),
                      index: index,
                      controller: controller,
                    );
                  },
                ),
              ),
            )
          ])),
      //Body(),
      bottomNavigationBar: Obx(
        () => Container(
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
                    Expanded(
                      child: TextField(
                        controller: nom_prenom,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          hintText: "Nom du client",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .08,
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
                                "${controller.total} F", //"${state.basket.totalString} XOF",
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
                  child: circular
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          child: Text("Enregistrer"),
                          onPressed: () {
                            saveFacture();
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
  final cartController = Get.put(CartController());
  late List<ArticleVente> autoCompleteData = [];
  bool haveSelectedProduct = false;
  late TextEditingController controller = TextEditingController();
  late TextEditingController qteCtrl = TextEditingController();
  int qte = 0;
  late ArticleVente articleVente;

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
    return Expanded(
      child: Center(
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
    
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Center(
                            child: Text(
                              'Ajout de produit',
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
                                  padding: const EdgeInsets.only(
                                      left: 16.0, top: 16.0, bottom: 16.0),
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
                                          qte = selectedString.qteStock;
                                          articleVente = ArticleVente(
                                              id: selectedString.id,
                                              libelle: selectedString.libelle,
                                              prixUnitaire:
                                                  selectedString.prixUnitaire,
                                              qteStock: selectedString.qteStock);
                                        });
                                      },
                                      displayStringForOption: (ArticleVente d) =>
                                          '${d.libelle} ${d.prixUnitaire}',
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
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          suffix: Text(
                                        "Stock: ${qte}",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                      style: TextStyle(color: Colors.white),
                                      controller: qteCtrl,
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
                              cartController.addProduct(
                                  articleVente, int.parse(qteCtrl.text));
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
