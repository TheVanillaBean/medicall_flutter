TempRegUser tempRegUser;

class TempRegUser {
  String pass;
  String username;
  List<dynamic> images;

  TempRegUser({
    this.pass = '',
    this.username = '',
    this.images = const ['', ''],
  });
}
