import 'dart:typed_data';

import 'package:Medicall/models/medicall_user.dart';
import 'package:Medicall/screens/QuestionsUpload/asset_view.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ConfirmConsultScreen extends StatefulWidget {
  final globals.ConsultData data;

  const ConfirmConsultScreen({Key key, @required this.data}) : super(key: key);
  @override
  _ConfirmConsultScreenState createState() => _ConfirmConsultScreenState();
}

class _ConfirmConsultScreenState extends State<ConfirmConsultScreen> {
  @override
  Widget build(BuildContext context) {
    var combinedQuestions = [
      {'Symptom Questions': widget.data.screeningQuestions},
      {'Medical History Questions': widget.data.historyQuestions},
      {'Pictures': widget.data.media},
    ];
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Consult Review',
            style: TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: FlatButton(
          padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
          color: Theme.of(context).colorScheme.primaryVariant,
          onPressed: () async {
            Center(
              child: CircularProgressIndicator(
                value: null,
              ),
            );
            await _addConsult();
            await _addProviderConsult();
            Navigator.pushNamed(context, '/history', arguments: widget.data);
          },
          //Navigator.pushNamed(context, '/history'), // Switch tabs
          child: Text(
            'CONFIRM',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Container(
                child: Text(
              widget.data.consultType,
              style: Theme.of(context).textTheme.headline,
            )),
            Container(child: Text(widget.data.provider)),
            Expanded(
              child: ListView.builder(
                itemCount: combinedQuestions.length,
                itemBuilder: (context, i) {
                  return ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      combinedQuestions[i].keys.first,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                    children: <Widget>[
                      Column(
                        children: _buildExpandableContent(combinedQuestions[i]),
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ));
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

  _buildExpandableContent(dynamic question) {
    List<Widget> columnContent = [];
    for (var i = 0; i < question.values.first.length; i++) {
      if (question.values.first[i] is Map) {
        if (question.values.first[i]['answers'] is String) {
          columnContent.add(
            ListTile(
              title: Text(
                question.values.first[i]['answers'],
                style: TextStyle(fontSize: 18.0),
              ),
              subtitle: Text(question.values.first[i]['question']),
              leading: Icon(Icons.linear_scale),
            ),
          );
        } else {
          columnContent.add(
            ListTile(
              title: Text(
                question.values.first[i]['answers']
                    .toString()
                    .replaceAll(']', '')
                    .replaceAll('[', '')
                    .replaceFirst(', ', ''),
                style: TextStyle(fontSize: 18.0),
              ),
              subtitle: Text(question.values.first[i]['question']),
              leading: Icon(Icons.linear_scale),
            ),
          );
        }
      } else {
        if (question.values.first[i].name is String) {
          columnContent.add(
            ListTile(
              title: Text(
                question.values.first[i].name,
                style: TextStyle(fontSize: 18.0),
              ),
              leading: AssetView(
                i,
                question.values.first[i],
              ),
            ),
          );
        } else {}
      }
    }

    return columnContent;
  }
}
