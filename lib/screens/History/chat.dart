import 'dart:async';
import 'dart:io';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final themeColor = Color(0xfff5a623);
final primaryColor = Color(0xff203152);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);

class Chat extends StatelessWidget {
  final String peerId;
  final bool peerAvatar;

  Chat({Key key, @required this.peerId, @required this.peerAvatar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatScreen(
        peerId: peerId,
        peerAvatar: peerAvatar,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final bool peerAvatar;

  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar})
      : super(key: key);

  @override
  State createState() =>
      ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});

  String peerId;
  bool peerAvatar;
  String id;

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal();
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
    listScrollController.dispose();
    focusNode.dispose();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    // Firestore.instance
    //     .collection('users')
    //     .document(id)
    //     .updateData({'chattingWith': peerId});

    //setState(() {});
  }

  // Future getImage() async {
  //   imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

  //   if (imageFile != null) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //     uploadFile();
  //   }
  // }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      AppUtil().showFlushBar('This file is not an image', context);
    });
  }

  onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      final DocumentReference documentReference =
          Firestore.instance.collection('consults').document(this.peerId);
      Map<String, dynamic> data = {
        'chat': FieldValue.arrayUnion([
          {
            'user_id': medicallUser.uid,
            'date': DateTime.now(),
            'txt': content,
          }
        ])
      };
      documentReference.snapshots().forEach((snap) {
        if (snap.data['provider_id'] == medicallUser.uid &&
            snap.data['state'] == 'new') {
          Map<String, dynamic> consultStateData = {'state': 'in progress'};
          documentReference.updateData(consultStateData).whenComplete(() {
            print("Msg Sent");
          }).catchError((e) => print(e));
        }
      });
      documentReference.updateData(data).whenComplete(() {
        print("Msg Sent");
      }).catchError((e) => print(e));
    } else {
      AppUtil().showFlushBar('Nothing to send', context);
    }
  }

  Widget buildItem(int index, Map document) {
    Timestamp timestamp = document['date'];
    if (document['user_id'] == medicallUser.uid) {
      // Right (my message)
      return Container(
          child: Column(children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              child: Linkify(
                onOpen: (link) async {
                  if (await canLaunch(link.url)) {
                    await launch(link.url);
                  } else {
                    throw 'Could not launch $link';
                  }
                },
                text: document['txt'],
                humanize: true,
                style: TextStyle(color: primaryColor),
                linkStyle: TextStyle(color: Colors.red),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                  color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(
                  bottom: isLastMessageRight(index) ? 5.0 : 5.0, right: 5.0),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
        Container(
          child: Text(
            DateFormat('dd MMM h:mm a').format(timestamp.toDate()).toString(),
            style: TextStyle(
                color: greyColor, fontSize: 12.0, fontStyle: FontStyle.italic),
          ),
          margin: EdgeInsets.only(left: 50.0, top: 0.0, bottom: 10.0),
        )
      ]));
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Material(
                  child: Container(
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: document['txt'],
                      style: TextStyle(color: Colors.white),
                      linkStyle: TextStyle(color: Colors.red),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8.0)),
                    margin: EdgeInsets.only(left: 10.0),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(18.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
              ],
            ),
            Container(
              child: Text(
                DateFormat('dd MMM h:mm a')
                    .format(timestamp.toDate())
                    .toString(),
                style: TextStyle(
                    color: greyColor,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['user_id'] == medicallUser.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['user_id'] != medicallUser.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      // Firestore.instance
      //     .collection('users')
      //     .document(id)
      //     .updateData({'chattingWith': null});
      Navigator.of(context).pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Container(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // List of messages
                buildListMessage(),

                // Sticker
                //(isShowSticker ? buildSticker() : Container()),

                // Input content
                buildInput(),
              ],
            ),

            // Loading
            buildLoading()
          ],
        ),
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return SafeArea(
      child: Container(
        child: Row(
          children: <Widget>[
            // Edit text
            Flexible(
              child: Container(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: TextField(
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 15.0,
                  ),
                  enabled: !this.peerAvatar,
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: !this.peerAvatar
                        ? 'Type your message...'
                        : 'This consult has finished, chat disabled.',
                    hintStyle: TextStyle(color: greyColor),
                  ),
                  focusNode: focusNode,
                ),
              ),
            ),

            // Button send message
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: !this.peerAvatar ? Colors.lightGreen : greyColor,
                  ),
                  onPressed: () {
                    if (!this.peerAvatar) {
                      onSendMessage(textEditingController.text, 0);
                    }
                  },
                  color: !this.peerAvatar ? primaryColor : greyColor,
                ),
              ),
              color: !peerAvatar ? Colors.white : greyColor2,
            ),
          ],
        ),
        width: double.infinity,
        height: 50.0,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
            color: !peerAvatar ? Colors.white : greyColor2),
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('consults')
            .document(this.peerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            List listMessage = snapshot.data.data["chat"];
            listMessage = listMessage.reversed.toList();
            if (listMessage.length == 0) {
              return Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                    Container(
                      child: Text(
                        'Send a message, it will appear here',
                        style: TextStyle(
                            color: greyColor,
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  ]));
            }
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, listMessage[index]),
              itemCount: listMessage.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }
}
