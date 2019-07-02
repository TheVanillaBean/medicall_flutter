import 'dart:convert';

import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
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
    getConsult();
  }

  Future getConsult() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var perfConsult = jsonDecode(pref.getString('consult'));
    _consult.consultType = perfConsult["consultType"];
    _consult.provider = perfConsult["provider"];
    _consult.providerId = perfConsult["providerId"];
    _consult.screeningQuestions = perfConsult["screeningQuestions"];
    _consult.historyQuestions = perfConsult["historyQuestions"];
  }

  setConsult() async {
    SharedPreferences _thisConsult = await SharedPreferences.getInstance();
    _consult.media = images;
    String currentConsultString = jsonEncode(_consult);
    await _thisConsult.setString("consult", currentConsultString);
    return;
  }

  Widget buildGridView() {
    //_consult.media = images;
    return GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(10),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: List.generate(images.length, (index) {
          Asset asset = images[index];

          return Container(
            child: AssetView(
              index,
              asset,
              key: UniqueKey(),
            ),
          );
        }));
  }

  Future<void> deleteAssets() async {
    await MultiImagePicker.deleteImages(assets: images);
    setState(() {
      images = List<Asset>();
    });
  }

  Future<void> loadAssets() async {
    // setState(() {
    //   images = List<Asset>();
    // });

    List<Asset> resultList = List<Asset>();
    String error = '';

    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 4,
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
      floatingActionButton: FloatingActionButton(
        onPressed: loadAssets,
        child: Icon(
          Icons.camera_alt,
          color: Theme.of(context).colorScheme.onBackground,
          size: 30,
        ),
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
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Please make sure the pictures are taken in bright daylight and that the area of concern is centered in the photo.',
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 210,
            child: Stack(
              children: <Widget>[
                GridView.count(
                    crossAxisCount: 2,
                    padding: EdgeInsets.all(10),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: List.generate(4, (index) {
                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12)),
                        child: Container(
                          child: Icon(
                            Icons.photo,
                            size: 110,
                            color: Colors.black12,
                          ),
                        ),
                      );
                    })),
                buildGridView(),
              ],
            ),
          ),
          Center(child: _error.length > 0 ? Text('Error: $_error') : Text('')),
        ],
      ),
    );
  }
}
