import 'package:Medicall/routing/router.dart';
import 'package:Medicall/services/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'chat_app_bar.dart';

class ChatScreen extends StatelessWidget {
  final Channel channel;

  const ChatScreen({@required this.channel});

  static Future<void> show({
    BuildContext context,
    Channel channel,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.chatScreen,
      arguments: {
        'channel': channel,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    return StreamChat(
      streamChatThemeData: StreamChatThemeData.fromTheme(
        Theme.of(context),
      ),
      client: chatProvider.client,
      child: StreamChannel(
        channel: channel,
        child: ChannelPage(),
      ),
    );
  }
}

class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(),
          ),
          MessageInput(),
        ],
      ),
    );
  }
}
