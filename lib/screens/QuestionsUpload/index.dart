//import 'dart:io';/

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
//import 'package:multi_image_picker/material_options.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:Medicall/screens/ConfirmConsult/index.dart';

//import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
//import 'package:flutter_alert/flutter_alert.dart';
import 'asset_view.dart';

class QuestionsUploadScreen extends StatefulWidget {
  @override
  _QuestionsUploadScreenState createState() => _QuestionsUploadScreenState();
}

class _QuestionsUploadScreenState extends State<QuestionsUploadScreen> {
  List<Asset> images = List<Asset>();
  String _error = '';
  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView() {
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
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList = List<Asset>();
    String error = '';

    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 4,
          enableCamera: true,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
              actionBarColor: "#F16477",
              statusBarColor: "#D8485C",
              actionBarTitle: "Select Images",
              allViewTitle: "All Photos"));
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
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(35, 179, 232, 1),
        title: new Text(
          'Pictures',
          style: new TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: new FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Color.fromRGBO(35, 179, 232, 1),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ConfirmConsultScreen(),
          ));
        },
        //Navigator.pushNamed(context, '/history'), // Switch tabs

        child: Text(
          'SEND CONSULT REQUEST',
          style: TextStyle(
            color: Colors.white,
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
          Expanded(
            child: Stack(
              children: <Widget>[
                GridView.count(
                    crossAxisCount: 2,
                    padding: EdgeInsets.all(10),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: List.generate(4, (index) {
                      return Container(
                        decoration: new BoxDecoration(
                            border: new Border.all(color: Colors.black12)),
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
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: FlatButton(
                  color: Colors.transparent,
                  splashColor: Color.fromRGBO(241, 100, 119, 0.2),
                  padding: EdgeInsets.all(10),
                  onPressed: loadAssets,
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.camera_alt,
                        color: Color.fromRGBO(241, 100, 119, 0.8),
                        size: 40,
                      ),
                      Text(
                        'Camera/Album',
                        style: TextStyle(
                          color: Color.fromRGBO(241, 100, 119, 0.8),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              images.length > 0
                  ? Expanded(
                      flex: 1,
                      child: FlatButton(
                        color: Colors.transparent,
                        splashColor: Color.fromRGBO(241, 100, 119, 0.2),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.clear,
                              color: Color.fromRGBO(241, 100, 119, 0.8),
                              size: 40,
                            ),
                            Text(
                              'Delete All',
                              style: TextStyle(
                                color: Color.fromRGBO(241, 100, 119, 0.8),
                              ),
                            )
                          ],
                        ),
                        onPressed: deleteAssets,
                      ),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}
