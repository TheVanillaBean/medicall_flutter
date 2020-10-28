import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/services/chat_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'chat_app_bar.dart';
import 'chat_message_input.dart';

class ChatScreen extends StatefulWidget {
  final Channel channel;
  final Consult consult;

  const ChatScreen({@required this.channel, @required this.consult});

  static Future<void> show({
    BuildContext context,
    Channel channel,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.chatScreen,
      arguments: {
        'channel': channel,
        'consult': consult,
      },
    );
  }

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isLoading = true;

  Future<void> initChat(
    UserProvider userProvider,
    ChatProvider chatProvider,
  ) async {
    await chatProvider.setUser(userProvider.user);

    await widget.channel.watch();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    if (isLoading) {
      this.initChat(userProvider, chatProvider);
      return LoadingPage();
    }
    return StreamChat(
      streamChatThemeData: StreamChatThemeData.fromTheme(
        Theme.of(context),
      ),
      client: chatProvider.client,
      child: StreamChannel(
        channel: widget.channel,
        child: ChannelPage(
          consult: this.widget.consult,
          userProvider: userProvider,
        ),
      ),
    );
  }
}

class ChannelPage extends StatelessWidget {
  final Consult consult;
  final UserProvider userProvider;

  const ChannelPage({
    this.consult,
    this.userProvider,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
        otherUser: this.otherUserName,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(),
          ),
          ChatMessageInput(),
        ],
      ),
    );
  }

  String get otherUserName {
    if (userProvider.user.uid == consult.patientId) {
      return "${consult.providerUser.fullName} ${consult.providerUser.professionalTitle}";
    }
    return consult.patientUser.fullName;
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Loading",
        theme: Theme.of(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              'Loading Chat...',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          SizedBox(height: 32),
          CircularProgressIndicator()
        ],
      ),
    );
  }
}
