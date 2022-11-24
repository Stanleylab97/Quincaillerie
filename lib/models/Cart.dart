import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'Product.dart';
import 'Product.dart';

class Cart extends Equatable {
  final List<Product> products;

  Cart({this.products = const <Product>[]});

 //int get total => products.fold(0, (total, current) => null)
  @override
  List<Object?> get props => [products];
}
