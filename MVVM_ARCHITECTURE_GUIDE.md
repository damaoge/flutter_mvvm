# Flutter MVVM架构详细指南

## 目录
1. [架构概述](#架构概述)
2. [MVVM vs GetX对比](#mvvm-vs-getx对比)
3. [项目结构详解](#项目结构详解)
4. [依赖注入详解](#依赖注入详解)
5. [注解系统详解](#注解系统详解)
6. [Repository模式详解](#repository模式详解)
7. [Clean Architecture分层](#clean-architecture分层)
8. [实际使用示例](#实际使用示例)
9. [最佳实践](#最佳实践)
10. [常见问题解答](#常见问题解答)

---

## 架构概述

### 什么是MVVM？

MVVM（Model-View-ViewModel）是一种软件架构模式，它将应用程序分为三个主要组件：

- **Model（模型）**：负责数据和业务逻辑
- **View（视图）**：负责用户界面显示
- **ViewModel（视图模型）**：连接Model和View的桥梁，处理UI逻辑

### 为什么选择MVVM？

1. **关注点分离**：每个组件都有明确的职责
2. **可测试性**：业务逻辑与UI分离，便于单元测试
3. **可维护性**：代码结构清晰，易于维护和扩展
4. **团队协作**：不同开发者可以并行开发不同层

---

## MVVM vs GetX对比

### GetX架构特点
```dart
// GetX Controller
class HomeController extends GetxController {
  var count = 0.obs;
  
  void increment() {
    count++;
  }
}

// GetX View
class HomePage extends StatelessWidget {
  final controller = Get.put(HomeController());
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text('${controller.count}'));
  }
}
```

### MVVM架构特点
```dart
// MVVM ViewModel
@injectable
class HomeViewModel extends BaseViewModel {
  int _count = 0;
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
}

// MVVM View
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<HomeViewModel>(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Text('${viewModel.count}');
        },
      ),
    );
  }
}
```

### 主要区别

| 特性 | GetX | MVVM |
|------|------|------|
| 学习曲线 | 简单 | 中等 |
| 依赖注入 | 内置简单DI | 专业DI框架 |
| 状态管理 | 响应式编程 | 观察者模式 |
| 测试友好性 | 一般 | 优秀 |
| 架构规范性 | 灵活但容易混乱 | 严格分层 |
| 团队协作 | 适合小团队 | 适合大团队 |

---

## 项目结构详解

```
lib/
├── core/                    # 核心基础设施
│   ├── base/               # 基础类
│   ├── di/                 # 依赖注入配置
│   ├── datasource/         # 数据源抽象
│   ├── repository/         # 仓储抽象
│   ├── network/            # 网络配置
│   ├── storage/            # 存储管理
│   ├── router/             # 路由管理
│   └── widgets/            # 通用组件
├── features/               # 功能模块
│   └── auth/              # 认证功能模块
│       ├── data/          # 数据层
│       │   ├── datasources/   # 数据源实现
│       │   ├── models/        # 数据模型
│       │   └── repositories/  # 仓储实现
│       ├── domain/        # 领域层
│       │   ├── entities/      # 业务实体
│       │   ├── repositories/  # 仓储接口
│       │   └── usecases/      # 用例
│       └── presentation/  # 表现层
│           ├── pages/         # 页面
│           └── viewmodels/    # 视图模型
└── main.dart              # 应用入口
```

### 结构优势

1. **模块化**：每个功能都是独立的模块
2. **分层清晰**：严格按照Clean Architecture分层
3. **可扩展**：新功能只需添加新的feature模块
4. **可测试**：每一层都可以独立测试

---

## 依赖注入详解

### 什么是依赖注入？

依赖注入（Dependency Injection，DI）是一种设计模式，它允许我们将对象的依赖关系从外部注入，而不是在对象内部创建。

### 传统方式 vs 依赖注入

```dart
// 传统方式 - 紧耦合
class UserService {
  final ApiClient _apiClient = ApiClient(); // 直接创建依赖
  
  Future<User> getUser(String id) {
    return _apiClient.get('/users/$id');
  }
}

// 依赖注入方式 - 松耦合
class UserService {
  final ApiClient _apiClient;
  
  UserService(this._apiClient); // 依赖从外部注入
  
  Future<User> getUser(String id) {
    return _apiClient.get('/users/$id');
  }
}
```

### 我们使用的DI框架

我们使用`get_it`和`injectable`来实现依赖注入：

- **get_it**：服务定位器，用于注册和获取依赖
- **injectable**：代码生成器，自动生成依赖注入代码

### DI配置文件详解

#### 1. service_locator.dart
```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'service_locator.config.dart';

// 全局服务定位器实例
final getIt = GetIt.instance;

// 配置依赖注入
@InjectableInit()
void configureDependencies() => getIt.init();
```

**作用**：
- 创建全局的GetIt实例
- 提供配置入口点
- 在应用启动时调用`configureDependencies()`

#### 2. injection_module.dart
```dart
@module
abstract class InjectionModule {
  // 注册第三方库
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();
  
  @lazySingleton
  Dio get dio => Dio();
  
  // 注册复杂依赖
  @lazySingleton
  RemoteDataSource remoteDataSource(Dio dio) => RemoteDataSourceImpl(dio);
}
```

**作用**：
- 注册第三方库实例
- 处理复杂的依赖关系
- 配置单例和工厂模式

---

## 注解系统详解

### 核心注解说明

#### 1. @injectable
```dart
@injectable
class UserRepository {
  final ApiService _apiService;
  
  UserRepository(this._apiService);
}
```

**作用**：
- 标记类可以被依赖注入
- 自动分析构造函数参数
- 生成注册代码

**原理**：
- 编译时扫描所有@injectable类
- 分析构造函数依赖
- 生成`getIt.registerFactory(() => UserRepository(getIt<ApiService>()))`

#### 2. @lazySingleton
```dart
@lazySingleton
class DatabaseService {
  // 单例实现
}
```

**作用**：
- 创建懒加载单例
- 第一次使用时才创建实例
- 整个应用生命周期内只有一个实例

**使用场景**：
- 数据库连接
- 网络客户端
- 配置服务

#### 3. @singleton
```dart
@singleton
class ConfigService {
  // 立即创建的单例
}
```

**作用**：
- 应用启动时立即创建实例
- 整个应用生命周期内只有一个实例

**vs @lazySingleton**：
- @singleton：应用启动时创建
- @lazySingleton：首次使用时创建

#### 4. @module
```dart
@module
abstract class NetworkModule {
  @lazySingleton
  Dio provideDio() {
    return Dio(BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: 5000,
    ));
  }
}
```

**作用**：
- 提供第三方库的实例
- 配置复杂的依赖关系
- 处理需要特殊初始化的对象

#### 5. @preResolve
```dart
@module
abstract class StorageModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
```

**作用**：
- 处理异步依赖
- 在依赖注入配置阶段就解析
- 确保异步依赖在使用前已准备好

#### 6. @Named
```dart
@module
abstract class ConfigModule {
  @lazySingleton
  @Named('apiUrl')
  String get apiUrl => 'https://api.example.com';
  
  @lazySingleton
  @Named('timeout')
  int get timeout => 30000;
}

@injectable
class ApiService {
  final String apiUrl;
  final int timeout;
  
  ApiService(
    @Named('apiUrl') this.apiUrl,
    @Named('timeout') this.timeout,
  );
}
```

**作用**：
- 为相同类型的依赖提供不同的实例
- 通过名称区分不同配置
- 避免类型冲突

### 注解工作原理

#### 1. 编译时代码生成
```bash
# 运行代码生成
flutter packages pub run build_runner build
```

#### 2. 生成的代码示例
```dart
// service_locator.config.dart (自动生成)
GetIt _getIt = GetIt.instance;

void _configureInjection() {
  // 注册单例
  _getIt.registerLazySingleton<Dio>(() => Dio());
  
  // 注册工厂
  _getIt.registerFactory<UserRepository>(
    () => UserRepository(_getIt<ApiService>())
  );
  
  // 注册命名依赖
  _getIt.registerLazySingleton<String>(
    () => 'https://api.example.com',
    instanceName: 'apiUrl',
  );
}
```

#### 3. 依赖解析过程
```dart
// 1. 请求依赖
final userRepo = getIt<UserRepository>();

// 2. GetIt查找注册信息
// 3. 发现UserRepository需要ApiService
// 4. 递归解析ApiService的依赖
// 5. 创建完整的依赖树
// 6. 返回UserRepository实例
```

---

## Repository模式详解

### 什么是Repository模式？

Repository模式是一种设计模式，它封装了数据访问逻辑，为业务层提供统一的数据访问接口。

### Repository结构

```dart
// 1. Repository接口（领域层）
abstract class IUserRepository {
  Future<User?> getUserById(String id);
  Future<List<User>> getAllUsers();
  Future<User> createUser(User user);
  Future<User> updateUser(User user);
  Future<void> deleteUser(String id);
}

// 2. Repository实现（数据层）
@injectable
class UserRepositoryImpl implements IUserRepository {
  final IUserRemoteDataSource _remoteDataSource;
  final IUserLocalDataSource _localDataSource;
  
  UserRepositoryImpl(this._remoteDataSource, this._localDataSource);
  
  @override
  Future<User?> getUserById(String id) async {
    try {
      // 先尝试从本地获取
      final localUser = await _localDataSource.getUserById(id);
      if (localUser != null && !_isExpired(localUser)) {
        return localUser.toEntity();
      }
      
      // 从远程获取
      final remoteUser = await _remoteDataSource.getUserById(id);
      
      // 缓存到本地
      await _localDataSource.saveUser(remoteUser);
      
      return remoteUser.toEntity();
    } catch (e) {
      // 网络失败时返回本地数据
      final localUser = await _localDataSource.getUserById(id);
      return localUser?.toEntity();
    }
  }
}
```

### Repository优势

1. **数据源抽象**：业务层不需要知道数据来自哪里
2. **缓存策略**：统一处理本地缓存和远程数据
3. **错误处理**：统一的错误处理逻辑
4. **可测试性**：可以轻松mock数据源

---

## Clean Architecture分层

### 分层结构

```
┌─────────────────────────────────────┐
│           Presentation Layer        │  ← UI层
│  (Pages, ViewModels, Widgets)      │
├─────────────────────────────────────┤
│            Domain Layer             │  ← 业务层
│   (Entities, UseCases, Repos)      │
├─────────────────────────────────────┤
│             Data Layer              │  ← 数据层
│ (DataSources, Models, Repo Impls)  │
└─────────────────────────────────────┘
```

### 各层职责

#### 1. Presentation Layer（表现层）
```dart
// ViewModel
@injectable
class LoginViewModel extends BaseViewModel {
  final LoginUseCase _loginUseCase;
  
  LoginViewModel(this._loginUseCase);
  
  Future<void> login(String email, String password) async {
    setLoading(true);
    try {
      final result = await _loginUseCase(LoginParams(
        email: email,
        password: password,
      ));
      
      if (result.isSuccess) {
        // 导航到主页
      } else {
        // 显示错误
      }
    } finally {
      setLoading(false);
    }
  }
}

// Page
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<LoginViewModel>(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: LoginForm(
              onLogin: viewModel.login,
              isLoading: viewModel.isLoading,
            ),
          );
        },
      ),
    );
  }
}
```

**职责**：
- 处理用户交互
- 显示数据
- 管理UI状态
- 调用业务用例

#### 2. Domain Layer（领域层）
```dart
// Entity
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}

// UseCase
@injectable
class LoginUseCase {
  final IAuthRepository _authRepository;
  
  LoginUseCase(this._authRepository);
  
  Future<AuthResult> call(LoginParams params) async {
    // 验证输入
    if (params.email.isEmpty) {
      return AuthResult.failure('邮箱不能为空');
    }
    
    // 执行登录
    return await _authRepository.login(
      email: params.email,
      password: params.password,
    );
  }
}

// Repository Interface
abstract class IAuthRepository {
  Future<AuthResult> login({required String email, required String password});
  Future<void> logout();
  Future<User?> getCurrentUser();
}
```

**职责**：
- 定义业务实体
- 实现业务规则
- 定义数据访问接口
- 不依赖外部框架

#### 3. Data Layer（数据层）
```dart
// Model
class UserModel {
  final String id;
  final String name;
  final String email;
  
  UserModel({required this.id, required this.name, required this.email});
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
  
  User toEntity() {
    return User(id: id, name: name, email: email);
  }
}

// DataSource
@injectable
class AuthRemoteDataSource {
  final RemoteDataSource _remoteDataSource;
  
  AuthRemoteDataSource(this._remoteDataSource);
  
  Future<UserModel> login(String email, String password) async {
    final response = await _remoteDataSource.post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    return UserModel.fromJson(response.data['user']);
  }
}

// Repository Implementation
@injectable
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);
  
  @override
  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final userModel = await _remoteDataSource.login(email, password);
      await _localDataSource.saveUser(userModel);
      return AuthResult.success(userModel.toEntity());
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
}
```

**职责**：
- 实现数据访问
- 处理数据转换
- 管理缓存策略
- 处理网络请求

### 依赖规则

```
Presentation → Domain ← Data
```

- **Presentation层**依赖**Domain层**
- **Data层**依赖**Domain层**
- **Domain层**不依赖任何外部层
- 依赖方向始终指向内层

---

## 实际使用示例

### 1. 创建新功能模块

假设我们要创建一个产品管理功能：

#### Step 1: 创建领域层
```dart
// lib/features/product/domain/entities/product.dart
class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });
}

// lib/features/product/domain/repositories/product_repository.dart
abstract class IProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<Product> createProduct(Product product);
}

// lib/features/product/domain/usecases/get_products_usecase.dart
@injectable
class GetProductsUseCase {
  final IProductRepository _repository;
  
  GetProductsUseCase(this._repository);
  
  Future<List<Product>> call() async {
    return await _repository.getProducts();
  }
}
```

#### Step 2: 创建数据层
```dart
// lib/features/product/data/models/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  
  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'],
    );
  }
  
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      price: price,
      description: description,
    );
  }
}

// lib/features/product/data/datasources/product_remote_datasource.dart
@injectable
class ProductRemoteDataSource {
  final RemoteDataSource _remoteDataSource;
  
  ProductRemoteDataSource(this._remoteDataSource);
  
  Future<List<ProductModel>> getProducts() async {
    final response = await _remoteDataSource.get('/products');
    return (response.data as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }
}

// lib/features/product/data/repositories/product_repository_impl.dart
@injectable
class ProductRepositoryImpl implements IProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  
  ProductRepositoryImpl(this._remoteDataSource);
  
  @override
  Future<List<Product>> getProducts() async {
    final models = await _remoteDataSource.getProducts();
    return models.map((model) => model.toEntity()).toList();
  }
}
```

#### Step 3: 创建表现层
```dart
// lib/features/product/presentation/viewmodels/product_viewmodel.dart
@injectable
class ProductViewModel extends BaseViewModel {
  final GetProductsUseCase _getProductsUseCase;
  
  ProductViewModel(this._getProductsUseCase);
  
  List<Product> _products = [];
  List<Product> get products => _products;
  
  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }
  
  Future<void> loadProducts() async {
    setLoading(true);
    try {
      _products = await _getProductsUseCase();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}

// lib/features/product/presentation/pages/product_list_page.dart
class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ProductViewModel>(),
      child: Scaffold(
        appBar: AppBar(title: Text('产品列表')),
        body: Consumer<ProductViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (viewModel.hasError) {
              return Center(child: Text('错误: ${viewModel.errorMessage}'));
            }
            
            return ListView.builder(
              itemCount: viewModel.products.length,
              itemBuilder: (context, index) {
                final product = viewModel.products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('\$${product.price}'),
                  onTap: () {
                    // 导航到产品详情
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
```

#### Step 4: 注册依赖
```dart
// lib/core/di/injection_module.dart
@module
abstract class InjectionModule {
  // ... 其他依赖
  
  @lazySingleton
  IProductRepository productRepository(
    ProductRemoteDataSource remoteDataSource,
  ) => ProductRepositoryImpl(remoteDataSource);
}
```

#### Step 5: 运行代码生成
```bash
flutter packages pub run build_runner build
```

### 2. 测试示例

```dart
// test/features/product/domain/usecases/get_products_usecase_test.dart
void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;
  
  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });
  
  group('GetProductsUseCase', () {
    test('should return products when repository call is successful', () async {
      // Arrange
      final products = [Product(id: '1', name: 'Test', price: 10.0, description: 'Test')];
      when(mockRepository.getProducts()).thenAnswer((_) async => products);
      
      // Act
      final result = await useCase();
      
      // Assert
      expect(result, equals(products));
      verify(mockRepository.getProducts()).called(1);
    });
  });
}
```

---

## 最佳实践

### 1. 命名规范

```dart
// 实体命名
class User {}           // 简洁的名词
class Product {}

// 模型命名
class UserModel {}      // 添加Model后缀
class ProductModel {}

// 用例命名
class GetUserUseCase {} // 动词 + 名词 + UseCase
class LoginUseCase {}

// 仓储命名
abstract class IUserRepository {}     // 接口以I开头
class UserRepositoryImpl {}           // 实现以Impl结尾

// 数据源命名
class UserRemoteDataSource {}        // 明确数据来源
class UserLocalDataSource {}

// ViewModel命名
class UserListViewModel {}           // 功能 + ViewModel
class LoginViewModel {}
```

### 2. 文件组织

```
features/
└── user/
    ├── data/
    │   ├── datasources/
    │   │   ├── user_local_datasource.dart
    │   │   └── user_remote_datasource.dart
    │   ├── models/
    │   │   └── user_model.dart
    │   └── repositories/
    │       └── user_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── user.dart
    │   ├── repositories/
    │   │   └── user_repository.dart
    │   └── usecases/
    │       ├── get_user_usecase.dart
    │       └── login_usecase.dart
    └── presentation/
        ├── pages/
        │   ├── user_list_page.dart
        │   └── login_page.dart
        └── viewmodels/
            ├── user_list_viewmodel.dart
            └── login_viewmodel.dart
```

### 3. 错误处理

```dart
// 定义统一的错误类型
abstract class Failure {
  final String message;
  Failure(this.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

// 使用Either类型处理错误
class GetUserUseCase {
  Future<Either<Failure, User>> call(String userId) async {
    try {
      final user = await _repository.getUser(userId);
      return Right(user);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
```

### 4. 状态管理

```dart
// 使用枚举定义状态
enum ViewState {
  idle,
  loading,
  success,
  error,
}

// BaseViewModel提供通用状态管理
abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  ViewState get state => _state;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  
  void setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }
  
  void setError(String message) {
    _errorMessage = message;
    setState(ViewState.error);
  }
  
  void clearError() {
    _errorMessage = null;
    if (_state == ViewState.error) {
      setState(ViewState.idle);
    }
  }
}
```

### 5. 依赖注入最佳实践

```dart
// 1. 优先使用接口
@injectable
class UserService {
  final IUserRepository _repository;  // 依赖接口而不是实现
  UserService(this._repository);
}

// 2. 合理使用单例
@lazySingleton  // 数据库、网络客户端等
class DatabaseService {}

@injectable     // 业务服务、用例等
class UserService {}

// 3. 使用命名依赖区分配置
@module
abstract class ConfigModule {
  @Named('apiUrl')
  @lazySingleton
  String get apiUrl => 'https://api.example.com';
  
  @Named('debugMode')
  @lazySingleton
  bool get debugMode => true;
}
```

---

## 常见问题解答

### Q1: 为什么要使用这么多层？不是过度设计吗？

**A**: 分层的好处：
- **可测试性**：每一层都可以独立测试
- **可维护性**：修改一层不影响其他层
- **团队协作**：不同开发者可以并行开发
- **代码复用**：业务逻辑可以在不同UI中复用

对于小项目，可以简化某些层，但保持基本的分层思想。

### Q2: 注解是如何工作的？

**A**: 注解工作流程：
1. 编写带注解的代码
2. 运行`build_runner`扫描注解
3. 生成依赖注入配置代码
4. 运行时使用生成的配置

```dart
// 你写的代码
@injectable
class UserService {}

// 生成的代码
getIt.registerFactory<UserService>(() => UserService());
```

### Q3: 什么时候使用@singleton vs @lazySingleton？

**A**: 
- **@singleton**：应用启动时立即创建，适用于必须的服务
- **@lazySingleton**：首次使用时创建，适用于可选的服务

```dart
@singleton
class LoggingService {}    // 应用启动就需要

@lazySingleton
class ImageCache {}        // 用到时再创建
```

### Q4: 如何处理异步依赖？

**A**: 使用@preResolve注解：

```dart
@module
abstract class StorageModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}

// 在main.dart中
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();  // 等待异步依赖解析
  runApp(MyApp());
}
```

### Q5: 如何在测试中mock依赖？

**A**: 

```dart
// 测试中替换依赖
void main() {
  setUp(() {
    getIt.reset();
    getIt.registerLazySingleton<IUserRepository>(
      () => MockUserRepository(),
    );
  });
  
  test('should return user', () async {
    final viewModel = UserViewModel(getIt<IUserRepository>());
    // 测试逻辑
  });
}
```

### Q6: Repository和DataSource的区别？

**A**: 
- **DataSource**：单一数据源（API、数据库、缓存）
- **Repository**：协调多个数据源，实现业务逻辑

```dart
// DataSource - 单一职责
class UserRemoteDataSource {
  Future<UserModel> getUser(String id) => _api.get('/users/$id');
}

// Repository - 协调多个数据源
class UserRepository {
  Future<User> getUser(String id) async {
    // 先查本地缓存
    final cached = await _localDataSource.getUser(id);
    if (cached != null && !isExpired(cached)) {
      return cached.toEntity();
    }
    
    // 从远程获取
    final remote = await _remoteDataSource.getUser(id);
    
    // 更新缓存
    await _localDataSource.saveUser(remote);
    
    return remote.toEntity();
  }
}
```

### Q7: 如何处理复杂的依赖关系？

**A**: 使用@module和工厂方法：

```dart
@module
abstract class NetworkModule {
  @lazySingleton
  Dio provideDio(@Named('baseUrl') String baseUrl) {
    return Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 3000,
    ));
  }
  
  @lazySingleton
  ApiClient provideApiClient(Dio dio, AuthService authService) {
    return ApiClient(dio, authService);
  }
}
```

---

## 总结

这个MVVM架构提供了：

1. **清晰的分层结构**：每一层都有明确的职责
2. **强大的依赖注入**：自动管理对象生命周期
3. **优秀的可测试性**：每个组件都可以独立测试
4. **良好的可维护性**：代码结构清晰，易于扩展
5. **团队协作友好**：不同开发者可以并行开发

相比GetX，这个架构更适合大型项目和团队开发，虽然学习曲线稍陡，但带来的长期收益是巨大的。

开始使用时，建议：
1. 先理解基本概念
2. 从简单功能开始实践
3. 逐步掌握高级特性
4. 在实际项目中应用和优化

记住：好的架构不是一蹴而就的，需要在实践中不断完善和优化。