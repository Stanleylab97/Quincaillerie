part of 'vente_bloc.dart';

abstract class VenteState extends Equatable {
  const VenteState();
  
  @override
  List<Object> get props => [];
}

class VenteInitial extends VenteState {

}

class VentePageLoadedState extends VenteState {
  late AvalaibleProducts avalaibleProducts;
  late List<CartItem> cartData;

  VentePageLoadedState({required this.avalaibleProducts, required this.cartData});
  
}

class ItemAddingCartState extends VenteState {
  AvalaibleProducts? cartData;
  late List<CartItem> cartItems;

  ItemAddingCartState({this.cartData, required this.cartItems});
}

class ItemAddedCartState extends VenteState {
    late List<CartItem> cartItems;
    ItemAddedCartState({required this.cartItems});
}

class ItemDeletingCartState extends VenteState {
    late List<CartItem> cartItems;
    ItemDeletingCartState({required this.cartItems});
}
