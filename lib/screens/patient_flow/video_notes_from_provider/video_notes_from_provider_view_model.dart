import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';

class VideoNotesFromProviderViewModel with ChangeNotifier {
  final FirestoreDatabase database;
  final UserProvider userProvider;

  VideoNotesFromProviderViewModel(
      {@required this.database, @required this.userProvider});
}
