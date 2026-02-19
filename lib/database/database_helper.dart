import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ecommerce.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        imageUrl TEXT NOT NULL,
        category TEXT NOT NULL,
        stock INTEGER NOT NULL,
        rating REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        productPrice REAL NOT NULL,
        productImageUrl TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        addedAt TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');

    await _insertSampleProducts(db);
  }

  Future<void> _insertSampleProducts(Database db) async {
    final products = [
      {
        'name': 'Smartphone Pro',
        'description':
            'Smartphone de última generación con cámara de 108MP y 256GB de almacenamiento. Pantalla AMOLED de 6.7 pulgadas.',
        'price': 899.99,
        'imageUrl': 'assets/images/smartphone.jpg',
        'category': 'Electrónica',
        'stock': 50,
        'rating': 4.8,
      },
      {
        'name': 'MacBook Pro',
        'description':
            'Laptop ultraligera con procesador Intel i7, 16GB RAM y SSD de 512GB. Ideal para trabajo y entretenimiento.',
        'price': 1299.99,
        'imageUrl': 'assets/images/macbook.jpg',
        'category': 'Electrónica',
        'stock': 30,
        'rating': 4.9,
      },
      {
        'name': 'AirPods Pro',
        'description':
            'Audífonos con cancelación de ruido activa, 30 horas de batería y sonido de alta fidelidad.',
        'price': 249.99,
        'imageUrl': 'assets/images/airpods.png',
        'category': 'Audio',
        'stock': 100,
        'rating': 4.6,
      },
      {
        'name': 'Apple Watch',
        'description':
            'Reloj inteligente con monitor de ritmo cardíaco, GPS integrado y resistencia al agua.',
        'price': 199.99,
        'imageUrl': 'assets/images/applewatch.jpg',
        'category': 'Wearables',
        'stock': 75,
        'rating': 4.5,
      },
      {
        'name': 'iPad Pro',
        'description':
            'Tablet de 12 pulgadas con pantalla retina, lápiz óptico incluido y 128GB de almacenamiento.',
        'price': 649.99,
        'imageUrl': 'assets/images/ipad.jpg',
        'category': 'Electrónica',
        'stock': 40,
        'rating': 4.7,
      },
      {
        'name': 'Cámara Sony',
        'description':
            'Cámara sin espejo con sensor full-frame, 4K video y sistema de enfoque automático avanzado.',
        'price': 1899.99,
        'imageUrl': 'assets/images/camara.jpg',
        'category': 'Fotografía',
        'stock': 20,
        'rating': 4.9,
      },
      {
        'name': 'Bocina Inteligente',
        'description':
            'Bocina con asistente de voz integrado, sonido 360 grados y conectividad multi-room.',
        'price': 129.99,
        'imageUrl': 'assets/images/bocinas.jpg',
        'category': 'Audio',
        'stock': 60,
        'rating': 4.4,
      },
      {
        'name': 'PlayStation 5',
        'description':
            'Consola de última generación con 1TB SSD, juegos en 4K y 120fps compatibles.',
        'price': 499.99,
        'imageUrl': 'assets/images/playstation5.jpg',
        'category': 'Gaming',
        'stock': 25,
        'rating': 4.8,
      },
    ];

    for (final product in products) {
      await db.insert('products', product);
    }
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM products ORDER BY category',
    );
    return maps.map((map) => map['category'] as String).toList();
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart_items');
    return List.generate(maps.length, (i) => CartItem.fromMap(maps[i]));
  }

  Future<CartItem?> getCartItemByProductId(int productId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cart_items',
      where: 'productId = ?',
      whereArgs: [productId],
    );
    if (maps.isNotEmpty) {
      return CartItem.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCartItem(CartItem cartItem) async {
    final db = await database;
    return await db.insert('cart_items', cartItem.toMap());
  }

  Future<int> updateCartItem(CartItem cartItem) async {
    final db = await database;
    return await db.update(
      'cart_items',
      cartItem.toMap(),
      where: 'id = ?',
      whereArgs: [cartItem.id],
    );
  }

  Future<int> deleteCartItem(int id) async {
    final db = await database;
    return await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  Future<double> getCartTotal() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(productPrice * quantity) as total FROM cart_items',
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> getCartItemCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(quantity) as count FROM cart_items',
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
