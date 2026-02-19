import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/models.dart';

class ProductProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'Todas';
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _filteredProducts;
  List<String> get categories => ['Todas', ..._categories];
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _setLoading(true);
    _error = null;
    try {
      _products = await _dbHelper.getProducts();
      _filteredProducts = _products;
      _categories = await _dbHelper.getCategories();
    } catch (e) {
      _error = 'Error al cargar productos: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<Product?> getProduct(int id) async {
    try {
      return await _dbHelper.getProduct(id);
    } catch (e) {
      _error = 'Error al obtener producto: $e';
      return null;
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    if (category == 'Todas') {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products
          .where((product) => product.category == category)
          .toList();
    }
    notifyListeners();
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      filterByCategory(_selectedCategory);
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    _filteredProducts = _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'Todas' || product.category == _selectedCategory;
      final matchesSearch =
          product.name.toLowerCase().contains(lowercaseQuery) ||
          product.description.toLowerCase().contains(lowercaseQuery);
      return matchesCategory && matchesSearch;
    }).toList();
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = 'Todas';
    _filteredProducts = _products;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
