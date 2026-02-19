import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/models.dart';

class CartProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<CartItem> _items = [];
  int _itemCount = 0;
  double _total = 0.0;
  bool _isLoading = false;

  List<CartItem> get items => _items;
  int get itemCount => _itemCount;
  double get total => _total;
  bool get isLoading => _isLoading;

  CartProvider() {
    loadCart();
  }

  Future<void> loadCart() async {
    _setLoading(true);
    try {
      _items = await _dbHelper.getCartItems();
      _itemCount = await _dbHelper.getCartItemCount();
      _total = await _dbHelper.getCartTotal();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart(Product product) async {
    _setLoading(true);
    try {
      final existingItem = await _dbHelper.getCartItemByProductId(product.id!);

      if (existingItem != null) {
        existingItem.quantity++;
        await _dbHelper.updateCartItem(existingItem);
      } else {
        final cartItem = CartItem(
          productId: product.id!,
          productName: product.name,
          productPrice: product.price,
          productImageUrl: product.imageUrl,
          quantity: 1,
        );
        await _dbHelper.insertCartItem(cartItem);
      }

      await loadCart();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    _setLoading(true);
    try {
      await _dbHelper.deleteCartItem(cartItemId);
      await loadCart();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    _setLoading(true);
    try {
      final item = _items.firstWhere((item) => item.id == cartItemId);
      item.quantity = quantity;
      await _dbHelper.updateCartItem(item);
      await loadCart();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearCart() async {
    _setLoading(true);
    try {
      await _dbHelper.clearCart();
      await loadCart();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkout() async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      await clearCart();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
