// To parse this JSON data, do
//
//     final productProduct = productProductFromJson(jsonString);

import 'dart:convert';

ProductProduct productProductFromJson(String str) =>
    ProductProduct.fromJson(json.decode(str));

String productProductToJson(ProductProduct data) => json.encode(data.toJson());

class ProductProduct {
  ProductProduct({
    required this.price,
    required this.name,
    required this.text,
    required this.quantitiy,
    required this.restaurantName,
    required this.restaurantAddress,
  });

  double price;
  String name;
  String text;
  int quantitiy;
  String restaurantName;
  String restaurantAddress;

  factory ProductProduct.fromJson(Map<String, dynamic> json) => ProductProduct(
      price: json["price"].toDouble(),
      name: json["name"],
      text: json["text"],
      quantitiy: json["quantitiy"],
      restaurantName: json["restaurant_name"],
      restaurantAddress: json["restaurant_address"]);

  Map<String, dynamic> toJson() => {
        "price": price,
        "name": name,
        "text": text,
        "quantitiy": quantitiy,
        "restaurant_name": restaurantName,
        "restaurant_address": restaurantAddress,
      };
}
