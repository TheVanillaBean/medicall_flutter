import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:Medicall/Screens/History/chat.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HistoryDetailScreen extends StatefulWidget {
  final data;
  HistoryDetailScreen({Key key, @required this.data}) : super(key: key);

  _HistoryDetailScreenState createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController controller;
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool isDone = false;
  bool isConsultOpen = false;
  String documentId;
  String from;

  var snapshot;
  @override
  initState() {
    super.initState();
    documentId = widget.data['documentId'];
    medicallUser = widget.data['user'];
    from = widget.data['from'];
    controller = TabController(length: 4, vsync: this);
    controller.addListener(_handleTabSelection);
    _getConsultDetail();
  }

  _handleTabSelection() {
    setState(() {
      _currentIndex = controller.index;
    });
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  Future<void> _getConsultDetail() async {
    final DocumentReference documentReference =
        Firestore.instance.collection('consults').document(documentId);
    await documentReference.get().then((datasnapshot) {
      if (datasnapshot.data != null) {
        setState(() {
          snapshot = datasnapshot.data;
          if (snapshot['state'] == 'done') {
            isDone = true;
          } else {
            isDone = false;
          }
        });
      }
    }).catchError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 5, 10, 0),
            width: 40,
            child: medicallUser.type == 'provider' && from != 'consults'
                ? GestureDetector(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        snapshot != null && isDone
                            ? Icon(Icons.assignment_turned_in)
                            : Icon(Icons.check_box_outline_blank),
                        Text(
                          'Done',
                          style: TextStyle(fontSize: 10),
                        )
                      ],
                    ),
                    onTap: () {
                      final DocumentReference documentReference = Firestore
                          .instance
                          .collection('consults')
                          .document(documentId);
                      documentReference.get().then((snap) {
                        if (snap.documentID == documentId &&
                            snap.data['provider_id'] == medicallUser.id) {
                          Map<String, dynamic> consultStateData = {
                            'state': 'done'
                          };
                          if (snap.data['state'] == 'done') {
                            consultStateData = {'state': 'in progress'};
                          }

                          documentReference
                              .updateData(consultStateData)
                              .whenComplete(() {
                            setState(() {
                              if (consultStateData['state'] == 'done') {
                                isDone = true;
                                if (_currentIndex != 0) {
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    controller.index = 0;
                                  });
                                } else {
                                  Navigator.pop(context);
                                }
                              } else {
                                isDone = false;
                                if (_currentIndex != 0) {
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    controller.index = 0;
                                  });
                                } else {
                                  controller.index = 3;
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    controller.index = 0;
                                  });
                                }
                              }
                            });
                            print("Document Added");
                          }).catchError((e) => print(e));
                        }
                      });
                    },
                  )
                : FlatButton(
                    onPressed: () {},
                    child: Text(''),
                  ),
          ),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  snapshot != null && from == 'consults'
                      ? snapshot['type'] + ' Consult'
                      : snapshot != null && from == 'patients'
                          ? snapshot['patient']
                          : '',
                  style: TextStyle(
                    fontSize: Theme.of(context).platform == TargetPlatform.iOS
                        ? 17.0
                        : 20.0,
                  ),
                ),
                Text(
                  snapshot != null &&
                          from == 'consults' &&
                          medicallUser.type == 'patient'
                      ? '${snapshot['provider'].split(" ")[0][0].toUpperCase()}${snapshot['provider'].split(" ")[0].substring(1)} ${snapshot['provider'].split(" ")[1][0].toUpperCase()}${snapshot['provider'].split(" ")[1].substring(1)} ' +
                          snapshot['providerTitles']
                      : snapshot != null &&
                              from == 'consults' &&
                              medicallUser.type == 'provider'
                          ? '${snapshot['provider'].split(" ")[0][0].toUpperCase()}${snapshot['provider'].split(" ")[0].substring(1)} ${snapshot['provider'].split(" ")[1][0].toUpperCase()}${snapshot['provider'].split(" ")[1].substring(1)} ' +
                              snapshot['providerTitles']
                          : snapshot != null && from == 'patients'
                              ? snapshot['type'] + ' Consult'
                              : '',
                  style: TextStyle(
                    fontSize: Theme.of(context).platform == TargetPlatform.iOS
                        ? 12.0
                        : 14.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontSize: 12),
          tabs: <Tab>[
            Tab(
              // set icon to the tab
              text: 'Chat',
              icon: Icon(Icons.chat_bubble_outline),
            ),
            Tab(
              // set icon to the tab
              text: 'Symptom',
              icon: Icon(Icons.local_pharmacy),
            ),
            Tab(
              text: 'History',
              icon: Icon(Icons.assignment_ind),
            ),
            Tab(
              text: 'Pictures',
              icon: Icon(Icons.perm_media),
            ),
          ],
          // setup the controller
          controller: controller,
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        leading: WillPopScope(
          onWillPop: () async {
            Navigator.pushNamed(context, '/history',
                arguments: {'user': medicallUser});
            return false;
          },
          child: BackButton(),
        ),
      ),
      body: snapshot != null
          ? TabBarView(
              // Add tabs as widgets
              children: <Widget>[
                _buildTab(snapshot['chat'], 0),
                _buildTab(snapshot['screening_questions'], 1),
                _buildTab(snapshot['medical_history_questions'], 2),
                _buildTab(snapshot['media'], 3),
              ],
              // set the controller
              controller: controller,
            )
          : null,
    );
  }

  _buildTab(questions, i) {
    if (i != 0) {
      if (questions.length > 0) {
        return Scaffold(
          body: Container(
            child: questions[0].toString().contains('https')
                ? Container(
                  color: Colors.black,
                    child: Carousel(
                      autoplay: false,
                      dotIncreasedColor:
                          Theme.of(context).colorScheme.secondary,
                      boxFit: BoxFit.contain,
                      dotColor: Theme.of(context).colorScheme.primary,
                      dotBgColor: Colors.white.withAlpha(480),
                      images: questions
                          .map((f) => (CachedNetworkImageProvider(f)))
                          .toList(),
                    ),
                  )
                : ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, i) {
                      if (questions[i]['visible'] &&
                          questions[i]['options'] is String) {
                        return ListTile(
                          title: Text(
                            questions[i]['question'],
                            style: TextStyle(fontSize: 14.0),
                          ),
                          subtitle: Text(
                            questions[i]['answer'],
                            style: TextStyle(
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        );
                      } else {
                        return questions[i]['visible']
                            ? ListTile(
                                title: Text(
                                  questions[i]['question'],
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                subtitle: Text(
                                  questions[i]['answer']
                                      .toString()
                                      .replaceAll(']', '')
                                      .replaceAll('[', '')
                                      .replaceAll('null', '')
                                      .replaceFirst(', ', ''),
                                  style: TextStyle(
                                      height: 1.2,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              )
                            : SizedBox();
                      }
                    }),
          ),
        );
      } else {
        return Center(
          child: Icon(
            Icons.broken_image,
            size: 140,
            color: Theme.of(context).colorScheme.secondary.withAlpha(90),
          ),
        );
      }
    } else {
      return Chat(
        peerId: documentId,
        peerAvatar: isDone,
      );
    }
  }
}
