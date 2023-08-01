import 'package:shared_preferences/shared_preferences.dart';
import 'package:teslo_shop/features/shared/infrastructure/services/storage_service.dart';

class StorageServiceImpl extends StorageService {
  @override
  Future<bool> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return await prefs.remove(key);
  }

  @override
  Future<T?> read<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();

    switch (T) {
      case int:
        return prefs.getInt(key) as T?;
      case String:
        return prefs.getString(key) as T?;
      default:
        throw Exception('Type: ${T.runtimeType} not supported');
    }
  }

  @override
  Future<void> write<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();

    switch (T) {
      case int:
        prefs.setInt(key, value as int);
        break;
      case String:
        prefs.setString(key, value as String);
        break;
      default:
        throw Exception('Type: ${T.runtimeType} not supported');
    }
  }
}
