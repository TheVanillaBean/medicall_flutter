import 'dart:async';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Chat extends StatefulWidget {
  final bool isDone;
  Chat({Key key, this.isDone}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  MedicallUser _medicallUser;
  Database _db;
  ExtImageProvider _extImageProvider;

  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();

  ChatUser user = ChatUser();

  ChatUser otherUser = ChatUser();

  List<ChatMessage> messages = List<ChatMessage>();
  var m = List<ChatMessage>();

  var i = 0;

  @override
  void initState() {
    super.initState();
  }

  void systemMessage() {
    Timer(Duration(milliseconds: 300), () {
      if (i < 6) {
        setState(() {
          messages = [...messages, m[i]];
        });
        i++;
      }
      Timer(Duration(milliseconds: 300), () {
        _chatViewKey.currentState.scrollController
          ..animateTo(
            _chatViewKey.currentState.scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
      });
    });
  }

  void onSend(ChatMessage message) {
    print(message.toJson());
    _db.createNewConsultChatMsg(message);
    /* setState(() {
      messages = [...messages, message];
      print(messages.length);
    });
    if (i == 0) {
      systemMessage();
      Timer(Duration(milliseconds: 600), () {
        systemMessage();
      });
    } else {
      systemMessage();
    } */
  }

  @override
  Widget build(BuildContext context) {
    _medicallUser = Provider.of<UserProvider>(context).medicallUser;
    _db = Provider.of<Database>(context);
    _extImageProvider = Provider.of<ExtImageProvider>(context);
    user = ChatUser(
        name: _medicallUser.displayName,
        uid: _medicallUser.uid,
        avatar: _medicallUser.profilePic);

    otherUser = _medicallUser.type == 'provider'
        ? ChatUser(
            name: _db.consultSnapshot.data['patient']
                    .split(' ')[0][0]
                    .toUpperCase() +
                _db.consultSnapshot.data['patient'].split(' ')[0].substring(1) +
                ' ' +
                _db.consultSnapshot.data['patient']
                    .split(' ')[1][0]
                    .toUpperCase() +
                _db.consultSnapshot.data['patient'].split(' ')[1].substring(1),
            uid: _db.consultSnapshot['patient_id'])
        : ChatUser(
            name: _db.consultSnapshot.data['provider']
                    .split(' ')[0][0]
                    .toUpperCase() +
                _db.consultSnapshot.data['provider']
                    .split(' ')[0]
                    .substring(1) +
                ' ' +
                _db.consultSnapshot.data['provider']
                    .split(' ')[1][0]
                    .toUpperCase() +
                _db.consultSnapshot.data['provider']
                    .split(' ')[1]
                    .substring(1) +
                ' ' +
                _db.consultSnapshot.data['providerTitles'],
            uid: _db.consultSnapshot['provider_id']);
    AppBar appBar = AppBar(
      title: Text(otherUser.name),
      centerTitle: true,
    );
    return Scaffold(
      appBar: appBar,
      body: StreamBuilder(
          stream: _db.getConsultChat(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              default:
                List<DocumentSnapshot> items = snapshot.data.documents;
                var messages =
                    items.map((i) => ChatMessage.fromJson(i.data)).toList();
                if (_chatViewKey.currentState != null) {
                  _chatViewKey.currentState.scrollController.animateTo(
                      _chatViewKey.currentState.scrollController.position
                              .maxScrollExtent +
                          200,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.easeOut);
                }
                return Container(
                  alignment: Alignment.center,
                  color: Colors.grey.withAlpha(50),
                  child: DashChat(
                    key: _chatViewKey,
                    inverted: false,
                    onSend: onSend,
                    user: user,
                    height: ScreenUtil.screenHeightDp -
                        (appBar.preferredSize.height +
                            ScreenUtil.statusBarHeight),
                    inputDecoration: InputDecoration(
                      hintText: "Add message here...",
                    ),
                    sendButtonBuilder: (fn) {
                      return IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: fn);
                    },
                    inputMaxLines: 5,
                    inputTextStyle: TextStyle(fontSize: 14.0, height: 2),
                    inputContainerStyle: BoxDecoration(
                      border: Border.all(width: 0.0),
                      color: Colors.white,
                    ),
                    dateFormat: DateFormat('MMM-dd-yyyy'),
                    timeFormat: DateFormat('dd MMM h:mm a'),
                    messages: messages,
                    scrollToBottom: false,
                    scrollToBottomWidget: () {
                      return Container(
                        width: 48.0,
                        height: 48.0,
                        child: RawMaterialButton(
                          highlightElevation: 10.0,
                          fillColor: Theme.of(context).primaryColor,
                          shape: CircleBorder(),
                          elevation: 0.0,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _chatViewKey.currentState.scrollController
                              ..animateTo(
                                _chatViewKey.currentState.scrollController
                                    .position.maxScrollExtent,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );
                          },
                        ),
                      );
                    },
                    showUserAvatar: true,
                    showAvatarForEveryMessage: false,
                    onPressAvatar: (ChatUser user) {
                      print("OnPressAvatar: ${user.name}");
                    },
                    onLongPressAvatar: (ChatUser user) {
                      print("OnLongPressAvatar: ${user.name}");
                    },
                    messageBuilder: (ChatMessage msg) {
                      return MessageContainer(
                        isUser: msg.user.uid == _medicallUser.uid,
                        message: msg,
                        timeFormat: DateFormat('dd MMM h:mm a'),
                        messageImageBuilder: (img) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return DetailScreen(img, _extImageProvider);
                              }));
                            },
                            child: Hero(
                              tag: img,
                              child: _extImageProvider.returnNetworkImage(img),
                            ),
                          );
                        },
                        messageTimeBuilder: (val) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Text(
                              val,
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 10),
                            ),
                          );
                        },
                        messageContainerDecoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onBackground,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        parsePatterns: [
                          MatchText(
                              type: ParsedType.URL,
                              style: TextStyle(color: Colors.blue),
                              onTap: (url) async {
                                if (!url.contains('http://')) {
                                  url = 'http://' + url;
                                }
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              }),
                          MatchText(
                              pattern: '.*',
                              style: TextStyle(color: Colors.black87),
                              onTap: () {}),
                          MatchText(type: ParsedType.PHONE),
                          MatchText(type: ParsedType.EMAIL),
                        ],
                      );
                    },
                    alwaysShowSend: !widget.isDone,
                    onQuickReply: (Reply reply) {
                      setState(() {
                        messages.add(ChatMessage(
                            text: reply.value,
                            createdAt: DateTime.now(),
                            user: user));

                        messages = [...messages];
                      });

                      Timer(Duration(milliseconds: 300), () {
                        _chatViewKey.currentState.scrollController
                          ..animateTo(
                            _chatViewKey.currentState.scrollController.position
                                .maxScrollExtent,
                            curve: Curves.easeOut,
                            duration: const Duration(milliseconds: 300),
                          );

                        if (i == 0) {
                          systemMessage();
                          Timer(Duration(milliseconds: 600), () {
                            systemMessage();
                          });
                        } else {
                          systemMessage();
                        }
                      });
                    },
                    onLoadEarlier: () {
                      CircularProgressIndicator();
                    },
                    shouldShowLoadEarlier: false,
                    showTraillingBeforeSend: true,
                    trailing: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.photo,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () async {
                          await _extImageProvider.setChatImage();

                          if (_extImageProvider.chatMedia != null) {
                            _db.saveConsultChatImage(
                                _medicallUser, _extImageProvider.chatMedia);
                          }
                        },
                      )
                    ],
                  ),
                );
            }
          }),
    );
  }
}

class DetailScreen extends StatelessWidget {
  DetailScreen(this.img, this.ext);
  final String img;
  final ExtImageProvider ext;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: this.img,
            child: this
                .ext
                .returnNetworkImage(img, mode: ExtendedImageMode.gesture,
                    initGestureConfigHandler: (state) {
              return GestureConfig(
                inPageView: true,
                initialScale: 1.0,
                cacheGesture: false,
              );
            }),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
