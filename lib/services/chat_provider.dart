import 'package:Medicall/models/user/user_model_base.dart' as MedicallUser;
import 'package:Medicall/secrets.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatProvider {
  final Client client = Client(
    streamChatAPIKey,
    logLevel: Level.INFO,
  );

  bool userSet = false;

  Future<void> setUser(MedicallUser.MedicallUser user) async {
    if (!userSet) {
      await client.setUser(
        User(
          id: user.uid,
          role: "user",
          extraData: {
            "online": true,
            "name": user.fullName,
            'image': user.profilePic,
          },
        ),
        user.streamChatID,
      );
      userSet = true;
    }
  }
}
