import 'dart:convert';

import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'asset_view.dart';

class QuestionsUploadScreen extends StatefulWidget {
  final data;

  const QuestionsUploadScreen({Key key, @required this.data}) : super(key: key);
  @override
  _QuestionsUploadScreenState createState() => _QuestionsUploadScreenState();
}

class _QuestionsUploadScreenState extends State<QuestionsUploadScreen> {
  List<Asset> images = List<Asset>();
  ConsultData _consult = ConsultData();
  String _error = '';
  @override
  void initState() {
    super.initState();
    medicallUser = widget.data['user'];
    getConsult().then((onValue) {
      setState(() {
        _consult.consultType = onValue["consultType"];
        _consult.screeningQuestions = onValue["screeningQuestions"];
        _consult.uploadQuestions = onValue["uploadQuestions"];
        _consult.historyQuestions = onValue["historyQuestions"];
        _consult.provider = onValue["provider"];
        _consult.providerTitles = onValue["providerTitles"];
        _consult.providerId = onValue["providerId"];
        if (_consult.provider != null && _consult.provider.length > 0) {
          _consult.historyQuestions[0]["question"] =
              _consult.historyQuestions[0]["question"] +
                  " " +
                  _consult.provider;
        }
      });
    });
  }

  Future getConsult() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return jsonDecode(pref.getString('consult'));
  }

  setConsult() async {
    SharedPreferences _thisConsult = await SharedPreferences.getInstance();
    _consult.media = images;
    String currentConsultString = jsonEncode(_consult);
    await _thisConsult.setString("consult", currentConsultString);
    return;
  }

  Widget buildGridView(index, asset) {
    return Container(
      child: AssetView(
        index,
        asset,
        key: UniqueKey(),
      ),
    );
  }

  Future<void> deleteAssets() async {
    //await MultiImagePicker.deleteImages(assets: images);
    setState(() {
      images = List<Asset>();
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = '';

    try {
      resultList = await MultiImagePicker.pickImages(
          selectedAssets: images,
          maxImages: widget.data['consult'].uploadQuestions.length - 1,
          enableCamera: true,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: 'chat'),
          materialOptions: MaterialOptions(
              actionBarColor:
                  '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
              statusBarColor:
                  '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
              lightStatusBar: false,
              startInAllView: true,
              actionBarTitle: 'Select Images',
              allViewTitle: 'All Photos'));
    } on PlatformException catch (e) {
      error = e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
      showToast(_error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Pictures',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          //await setConsult();
          _consult.media = images;
          Navigator.pushNamed(context, '/consultReview',
              arguments: {'consult': _consult, 'user': medicallUser});
        },
        //Navigator.pushNamed(context, '/history'), // Switch tabs

        child: Text(
          'CONTINUE',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            letterSpacing: 2,
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: widget.data['consult'].uploadQuestions.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: index == 0
                      ? EdgeInsets.fromLTRB(20, 10, 20, 0)
                      : EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    widget.data['consult'].uploadQuestions[index]['question'],
                    style: index == 0
                        ? TextStyle(fontSize: 14, color: Colors.red)
                        : TextStyle(fontSize: 12),
                  ),
                ),
                index != 0
                    ? FlatButton(
                        onPressed: loadAssets,
                        child: Column(
                          children: <Widget>[
                            images.length > 0 && (images.length) >= index
                                ? buildGridView(index, images[index - 1])
                                : Container(
                                    child: Image.network(
                                    widget.data['consult']
                                        .uploadQuestions[index]['media'],
                                  ))
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 0,
                      ),
              ],
            );
          }),
    );
  }
}
