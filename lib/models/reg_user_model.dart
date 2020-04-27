import 'package:multi_image_picker/multi_image_picker.dart';

TempRegUser tempRegUser;

class TempRegUser {
  String pass;
  String username;
  List<Asset> images;

  TempRegUser({
    this.pass = '',
    this.username = '',
    this.images,
  });
}
