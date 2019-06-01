import 'dart:typed_data';

import 'package:Medicall/models/medicall_user.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ConfirmConsultScreen extends StatefulWidget {
  final globals.ConsultData data;

  const ConfirmConsultScreen({Key key, @required this.data}) : super(key: key);
  @override
  _ConfirmConsultScreenState createState() => _ConfirmConsultScreenState();
}

class _ConfirmConsultScreenState extends State<ConfirmConsultScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Consult Review',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        bottom: TabBar(
          tabs: <Tab>[
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: !isLoading
          ? FlatButton(
              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
              color: Theme.of(context).colorScheme.primaryVariant,
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                await _addConsult();
                await _addProviderConsult();
                setState(() {
                  isLoading = false;
                });
                Navigator.pushNamed(context, '/history',
                    arguments: widget.data);
              },
              //Navigator.pushNamed(context, '/history'), // Switch tabs
              child: Text(
                'CONFIRM',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            )
          : Text(''),
      body: TabBarView(
        // Add tabs as widgets
        children: <Widget>[
          _buildTab(widget.data.screeningQuestions),
          _buildTab(widget.data.historyQuestions),
          _buildTab(widget.data.media),
        ],
        // set the controller
        controller: controller,
      ),
    );
  }

  Future _addConsult() async {
    final DocumentReference documentReference =
        Firestore.instance.document("users/" + globals.currentFirebaseUser.uid);
    var ref = documentReference.collection('consults').document();

    Map<String, dynamic> data = <String, dynamic>{
      "screening_questions": widget.data.screeningQuestions,
      "medical_history_questions": widget.data.historyQuestions,
      "type": widget.data.consultType,
      "date": DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now()),
      "provider": widget.data.provider,
      "provider_id": widget.data.providerId,
      "media": widget.data.media.length > 0
          ? await saveImages(widget.data.media, ref.documentID)
          : "",
    };
    ref.setData(data).whenComplete(() {
      print("Document Added");
    }).catchError((e) => print(e));
  }

  Future _addProviderConsult() async {
    final DocumentReference documentReference =
        Firestore.instance.document("users/" + widget.data.providerId);
    var ref = documentReference.collection('consults').document();

    Map<String, dynamic> data = <String, dynamic>{
      "screening_questions": widget.data.screeningQuestions,
      "medical_history_questions": widget.data.historyQuestions,
      "type": widget.data.consultType,
      "date": DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now()),
      "patient": medicallUser.displayName,
      "patient_id": medicallUser.id,
      "media": widget.data.media.length > 0
          ? await saveImages(widget.data.media, ref.documentID)
          : "",
    };
    ref.setData(data).whenComplete(() {
      print("Document Added");
    }).catchError((e) => print(e));
  }

  Future saveImages(assets, consultId) async {
    var allMediaList = [];
    for (var i = 0; i < assets.length; i++) {
      ByteData byteData = await assets[i].requestOriginal();
      List<int> imageData = byteData.buffer.asUint8List();
      StorageReference ref = FirebaseStorage.instance.ref().child(
          medicallUser.id + "/consults/" + consultId + "/" + assets[i].name);
      StorageUploadTask uploadTask = ref.putData(imageData);

      allMediaList
          .add(await (await uploadTask.onComplete).ref.getDownloadURL());
    }
    return allMediaList;
  }

  _buildTab(questions) {
    return Scaffold(
      body: Container(
        child: questions[0].runtimeType == Asset
            ? GridView.count(
                crossAxisCount: 2,
                children: List.generate(questions.length, (index) {
                  Asset asset = questions[index];
                  return AssetThumb(
                    asset: asset,
                    width: 300,
                    height: 300,
                  );
                }),
              )
            : ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, i) {
                  if (questions[i]['answers'] is String) {
                    return ListTile(
                      title: Text(
                        questions[i]['question'],
                        style: TextStyle(fontSize: 14.0),
                      ),
                      subtitle: Text(
                        questions[i]['answers'],
                        style: TextStyle(
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      leading: Text((i + 1).toString() + '.'),
                    );
                  } else {
                    return ListTile(
                      title: Text(
                        questions[i]['question'],
                        style: TextStyle(fontSize: 14.0),
                      ),
                      subtitle: Text(
                        questions[i]['answers']
                            .toString()
                            .replaceAll(']', '')
                            .replaceAll('[', '')
                            .replaceFirst(', ', ''),
                        style: TextStyle(
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      leading: Text((i + 1).toString() + '.'),
                    );
                  }
                }),
      ),
    );
  }
}
