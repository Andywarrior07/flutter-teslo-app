abstract class StorageService {
  Future<T?> read<T>(String key);
  Future<void> write<T>(String key, T value);
  Future<bool> delete(String key);
}
