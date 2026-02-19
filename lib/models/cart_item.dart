import 'product.dart';

class CartItem {
  final int? id;
  final int productId;
  final String productName;
  final double productPrice;
  final String productImageUrl;
  int quantity;
  final DateTime addedAt;

  CartItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
    this.quantity = 1,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  double get totalPrice => productPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as int?,
      productId: map['productId'] as int,
      productName: map['productName'] as String,
      productPrice: map['productPrice'] as double,
      productImageUrl: map['productImageUrl'] as String,
      quantity: map['quantity'] as int,
      addedAt: DateTime.parse(map['addedAt'] as String),
    );
  }

  CartItem copyWith({
    int? id,
    int? productId,
    String? productName,
    double? productPrice,
    String? productImageUrl,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
