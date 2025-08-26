import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

/// 登出用例
@injectable
class LogoutUseCase {
  final IAuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  /// 执行登出
  /// 
  /// 返回是否成功登出
  Future<bool> call() async {
    try {
      // 执行登出操作
      final result = await _authRepository.logout();
      
      if (result) {
        // 清除本地认证数据
        await _authRepository.clearAuthData();
      }
      
      return result;
    } catch (e) {
      // 即使登出失败，也要清除本地数据
      try {
        await _authRepository.clearAuthData();
      } catch (clearError) {
        // 忽略清除数据时的错误
      }
      
      // 登出操作失败，但本地数据已清除，可以认为是成功的
      return true;
    }
  }
}