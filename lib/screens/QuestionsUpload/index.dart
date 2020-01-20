import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/services/auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'asset_view.dart';

class QuestionsUploadScreen extends StatefulWidget {
  const QuestionsUploadScreen({Key key}) : super(key: key);
  @override
  _QuestionsUploadScreenState createState() => _QuestionsUploadScreenState();
}

class _QuestionsUploadScreenState extends State<QuestionsUploadScreen> {
  List<Asset> images = List<Asset>();
  String _error = '';
  var auth = Provider.of<AuthBase>(GlobalNavigatorKey.key.currentContext);
  @override
  void initState() {
    super.initState();
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
          maxImages: auth.newConsult.uploadQuestions.length - 1,
          enableCamera: true,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: 'chat'),
          materialOptions: MaterialOptions(
              actionBarColor:
                  '#${Theme.of(context).primaryColor.value.toRadixString(16).toUpperCase().substring(2)}',
              statusBarColor:
                  '#${Theme.of(context).primaryColor.value.toRadixString(16).toUpperCase().substring(2)}',
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
        color: Theme.of(context).primaryColor,
        onPressed: () async {
          auth.newConsult.media = images;
          GlobalNavigatorKey.key.currentState.pushNamed('/consultReview');
        },
        child: Text(
          'CONTINUE',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            letterSpacing: 2,
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: auth.newConsult.uploadQuestions.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: index == 0
                      ? EdgeInsets.fromLTRB(20, 10, 20, 0)
                      : EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    auth.newConsult.uploadQuestions[index]['question'],
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
                                    auth.newConsult.uploadQuestions[index]
                                        ['media'],
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
