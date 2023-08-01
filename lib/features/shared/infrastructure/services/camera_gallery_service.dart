abstract class CameraGalleryService {
  Future<String?> takeImage();
  Future<String?> selectImage();
  Future<List<String>> selectMultipleImage();
}
