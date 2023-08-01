import 'package:image_picker/image_picker.dart';
import 'camera_gallery_service.dart';

class CameraGalleryServiceImpl extends CameraGalleryService {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Future<List<String>> selectMultipleImage() async {
    // TODO: implement selectMultiplePhoto
    throw UnimplementedError();
  }

  @override
  Future<String?> selectImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      return null;
    }

    print('Imagen ${image.path}');

    return image.path;
  }

  @override
  Future<String?> takeImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (image == null) {
      return null;
    }

    print('Imagen ${image.path}');

    return image.path;
  }
}
