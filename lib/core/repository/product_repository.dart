import 'package:injectable/injectable.dart';
import 'package:flutter_mvvm/core/repository/base_repository.dart';
import 'package:flutter_mvvm/core/datasource/base_datasource.dart';

/// 产品模型
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 产品Repository接口
abstract class IProductRepository extends BaseRepository<Product> {
  /// 根据分类获取产品列表
  Future<List<Product>> getProductsByCategory(String category);
  
  /// 搜索产品
  Future<List<Product>> searchProducts(String query);
  
  /// 获取热门产品
  Future<List<Product>> getFeaturedProducts();
  
  /// 获取可用产品
  Future<List<Product>> getAvailableProducts();
  
  /// 更新产品可用性
  Future<bool> updateProductAvailability(String productId, bool isAvailable);
}

/// 产品Repository实现
@LazySingleton(as: IProductRepository)
class ProductRepository implements IProductRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  ProductRepository(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<Product?> get(String id) async {
    try {
      // 先从本地缓存获取
      final cachedData = await _localDataSource.get('product_$id');
      if (cachedData != null) {
        return Product.fromJson(cachedData);
      }
      
      // 从远程获取
      final remoteData = await _remoteDataSource.get('/products/$id');
      if (remoteData != null) {
        final product = Product.fromJson(remoteData);
        // 缓存到本地
        await _localDataSource.save('product_$id', product.toJson());
        return product;
      }
      
      return null;
    } catch (e) {
      throw DataSourceException('获取产品失败: $e');
    }
  }

  @override
  Future<List<Product>> getAll() async {
    try {
      // 先尝试从本地获取
      final cachedData = await _localDataSource.getAll('products');
      if (cachedData.isNotEmpty) {
        return cachedData.map((data) => Product.fromJson(data)).toList();
      }
      
      // 从远程获取
      final remoteData = await _remoteDataSource.getAll('/products');
      final products = remoteData.map((data) => Product.fromJson(data)).toList();
      
      // 缓存到本地
      await _localDataSource.saveAll('products', products.map((p) => p.toJson()).toList());
      
      return products;
    } catch (e) {
      throw DataSourceException('获取产品列表失败: $e');
    }
  }

  @override
  Future<Product> create(Product item) async {
    try {
      final data = await _remoteDataSource.create('/products', item.toJson());
      final product = Product.fromJson(data);
      
      // 更新本地缓存
      await _localDataSource.save('product_${product.id}', product.toJson());
      
      return product;
    } catch (e) {
      throw DataSourceException('创建产品失败: $e');
    }
  }

  @override
  Future<Product> update(String id, Product item) async {
    try {
      final data = await _remoteDataSource.update('/products/$id', item.toJson());
      final product = Product.fromJson(data);
      
      // 更新本地缓存
      await _localDataSource.save('product_$id', product.toJson());
      
      return product;
    } catch (e) {
      throw DataSourceException('更新产品失败: $e');
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      final success = await _remoteDataSource.delete('/products/$id');
      if (success) {
        // 删除本地缓存
        await _localDataSource.delete('product_$id');
      }
      return success;
    } catch (e) {
      throw DataSourceException('删除产品失败: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      return await _remoteDataSource.count('/products/count');
    } catch (e) {
      throw DataSourceException('获取产品数量失败: $e');
    }
  }

  @override
  Future<bool> clear() async {
    try {
      // 清除本地缓存
      await _localDataSource.clear('products');
      return true;
    } catch (e) {
      throw DataSourceException('清除产品缓存失败: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final data = await _remoteDataSource.getAll('/products?category=$category');
      return data.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      throw DataSourceException('获取分类产品失败: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final data = await _remoteDataSource.getAll('/products/search?q=$query');
      return data.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      throw DataSourceException('搜索产品失败: $e');
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final data = await _remoteDataSource.getAll('/products/featured');
      return data.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      throw DataSourceException('获取热门产品失败: $e');
    }
  }

  @override
  Future<List<Product>> getAvailableProducts() async {
    try {
      final data = await _remoteDataSource.getAll('/products?available=true');
      return data.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      throw DataSourceException('获取可用产品失败: $e');
    }
  }

  @override
  Future<bool> updateProductAvailability(String productId, bool isAvailable) async {
    try {
      final data = await _remoteDataSource.update(
        '/products/$productId/availability',
        {'isAvailable': isAvailable},
      );
      
      // 更新本地缓存
      final cachedProduct = await _localDataSource.get('product_$productId');
      if (cachedProduct != null) {
        final product = Product.fromJson(cachedProduct);
        final updatedProduct = product.copyWith(isAvailable: isAvailable);
        await _localDataSource.save('product_$productId', updatedProduct.toJson());
      }
      
      return data['success'] ?? false;
    } catch (e) {
      throw DataSourceException('更新产品可用性失败: $e');
    }
  }
}