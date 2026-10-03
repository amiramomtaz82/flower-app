import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

abstract class ImagePickerService {
  Future<String?> pickImageFromGallery();
}

@LazySingleton(as: ImagePickerService)
class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker;

  ImagePickerServiceImpl() : _picker = ImagePicker();

  ImagePickerServiceImpl.withPicker(this._picker);

  @override
  Future<String?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    return pickedFile?.path;
  }
}
