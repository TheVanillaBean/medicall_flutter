import 'dart:async';
import 'dart:io';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/history_detail_state.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class Chat extends StatefulWidget {
  Chat({Key key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  MedicallUser _medicallUser;
  Database _db;
  DetailedHistoryState _detailedHistoryState;

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
    var documentReference = Firestore.instance
        .collection('chat')
        .document(_db.currConsultId)
        .collection('messages')
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        message.toJson(),
      );
    });
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
    _detailedHistoryState = Provider.of<DetailedHistoryState>(context);
    _db = Provider.of<Database>(context);
    ExtImageProvider _extImageProvider = Provider.of<ExtImageProvider>(context);
    user = ChatUser(
        name: _medicallUser.displayName,
        uid: _medicallUser.uid,
        avatar: _medicallUser.profilePic);
    otherUser = _medicallUser.type == 'provider'
        ? ChatUser(
            name: _db.consultSnapshot['patient'],
            uid: _db.consultSnapshot['patient_id'])
        : ChatUser(
            name: _db.consultSnapshot['provider'],
            uid: _db.consultSnapshot['provider_id']);
    var _stream = Firestore.instance
        .collection('chat')
        .document(_db.currConsultId)
        .collection('messages')
        .snapshots();
    return StreamBuilder(
        stream: _stream,
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

              return Container(
                color: Colors.grey.withAlpha(50),
                child: DashChat(
                  key: _chatViewKey,
                  inverted: false,
                  onSend: onSend,
                  user: user,
                  height: MediaQuery.of(context).size.height -
                      Scaffold.of(context).appBarMaxHeight,
                  inputDecoration: InputDecoration.collapsed(
                      hintText: "Add message here..."),
                  dateFormat: DateFormat('MMM-dd-yyyy'),
                  timeFormat: DateFormat('dd MMM h:mm a'),
                  messages: messages,
                  showUserAvatar: true,
                  showAvatarForEveryMessage: true,
                  scrollToBottom: false,
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
                        return _extImageProvider.returnNetworkImage(img);
                      },
                      messageTimeBuilder: (val) {
                        return Container(
                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Text(
                            val,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 10),
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
                        ),
                        MatchText(type: ParsedType.PHONE),
                        MatchText(type: ParsedType.EMAIL),
                      ],
                    );
                  },
                  inputMaxLines: 5,
                  messageContainerPadding:
                      EdgeInsets.only(left: 5.0, right: 5.0),
                  alwaysShowSend: !_detailedHistoryState.getIsDone(),
                  inputTextStyle: TextStyle(fontSize: 16.0),
                  inputContainerStyle: BoxDecoration(
                    border: Border.all(width: 0.0),
                    color: Colors.white,
                  ),
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
                    print("laoding...");
                  },
                  shouldShowLoadEarlier: false,
                  showTraillingBeforeSend: true,
                  trailing: <Widget>[
                    IconButton(
                      icon: Icon(Icons.photo),
                      onPressed: () async {
                        File result = await ImagePicker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                          maxHeight: 400,
                          maxWidth: 400,
                        );

                        if (result != null) {
                          final StorageReference storageRef =
                              FirebaseStorage.instance.ref().child("consults/" +
                                  _medicallUser.uid +
                                  '/' +
                                  _db.currConsultId +
                                  '/' +
                                  path.basename(result.path));

                          StorageUploadTask uploadTask = storageRef.putFile(
                            result,
                            StorageMetadata(
                              contentType: 'image/jpg',
                            ),
                          );
                          StorageTaskSnapshot download =
                              await uploadTask.onComplete;

                          String url = await download.ref.getDownloadURL();

                          ChatMessage message =
                              ChatMessage(text: "", user: user, image: url);

                          var documentReference = Firestore.instance
                              .collection('chat')
                              .document(_db.currConsultId)
                              .collection('messages')
                              .document(DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString());

                          Firestore.instance
                              .runTransaction((transaction) async {
                            await transaction.set(
                              documentReference,
                              message.toJson(),
                            );
                          });
                        }
                      },
                    )
                  ],
                ),
              );
          }
        });
  }
}
