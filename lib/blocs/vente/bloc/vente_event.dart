part of 'vente_bloc.dart';

abstract class VenteEvent extends Equatable {
  const VenteEvent();

  @override
  List<Object> get props => [];
}

class VentePageInitializedEvent extends VenteEvent{

}


class ItemAddingCartEvent extends VenteEvent{
  late List<CartItem> cartItems;
  ItemAddingCartEvent({required this.cartItems});
}

class ItemAddedCartEvent extends VenteEvent{
 late List<CartItem> cartItems;
  ItemAddedCartEvent({required this.cartItems});
}

class ItemDeletedCartEvent extends VenteEvent{
  late List<CartItem> cartItems;
  int? index;
  ItemDeletedCartEvent({required this.cartItems, this.index});
}


