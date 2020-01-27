import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:provider/provider.dart';

class PhotoIdScreen extends StatefulWidget {
  const PhotoIdScreen({Key key}) : super(key: key);
  @override
  _PhotoIdScreenState createState() => _PhotoIdScreenState();
}

class _PhotoIdScreenState extends State<PhotoIdScreen> {
  List images = List();
  List govIdImage = List();
  List profileImage = List();
  String _error = '';
  ExtImageProvider _extImageProvider;

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView(index, asset) {
    return GestureDetector(
        onTap: loadGovIdImage,
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(8.0),
          child: _extImageProvider.returnAssetThumb(
            asset: asset,
            height: 200,
            width: 340,
          ),
        ));
  }

  Widget buildProfileImgView(index, asset) {
    return GestureDetector(
      onTap: loadProfileImage,
      child: ClipRRect(
        borderRadius: new BorderRadius.circular(1000.0),
        child: _extImageProvider.returnAssetThumb(
          asset: asset,
          height: 200,
          width: 200,
        ),
      ),
    );
  }

  Future<void> deleteGovIdImage() async {
    //await MultiImagePicker.deleteImages(assets: images);
    setState(() {
      govIdImage = [];
    });
  }

  Future<void> deleteProfileImage() async {
    //await MultiImagePicker.deleteImages(assets: images);
    setState(() {
      profileImage = [];
    });
  }

  Future<void> loadProfileImage() async {
    List resultList = [];
    String error = '';

    try {
      resultList = await _extImageProvider.pickImages(
          profileImage,
          1,
          true,
          _extImageProvider.pickImagesCupertinoOptions(takePhotoIcon: 'camera'),
          _extImageProvider.pickImagesMaterialOptions(
              useDetailsView: true,
              actionBarColor:
                  '#${Theme.of(context).primaryColor.value.toRadixString(16).toUpperCase().substring(2)}',
              statusBarColor:
                  '#${Theme.of(context).primaryColor.value.toRadixString(16).toUpperCase().substring(2)}',
              lightStatusBar: false,
              autoCloseOnSelectionLimit: true,
              startInAllView: true,
              actionBarTitle: 'Select Profile Picture',
              allViewTitle: 'All Photos'),
          context);
    } on PlatformException catch (e) {
      error = e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      profileImage = resultList;
      if (error == null) _error = 'No Error Dectected';
    });
    print(_error);
  }

  Future<void> loadGovIdImage() async {
    List resultList = [];
    String error = '';

    try {
      resultList = await _extImageProvider.pickImages(
          govIdImage,
          1,
          true,
          _extImageProvider.pickImagesCupertinoOptions(takePhotoIcon: 'camera'),
          _extImageProvider.pickImagesMaterialOptions(
            useDetailsView: true,
            actionBarColor:
                '#${Theme.of(context).primaryColor.value.toRadixString(16).toUpperCase().substring(2)}',
            statusBarColor:
                '#${Theme.of(context).primaryColor.value.toRadixString(16).toUpperCase().substring(2)}',
            lightStatusBar: false,
            autoCloseOnSelectionLimit: true,
            startInAllView: true,
            actionBarTitle: 'Select Government Id',
            allViewTitle: 'All Photos',
          ),
          context);
    } on PlatformException catch (e) {
      error = e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      govIdImage = resultList;
      if (error == null) _error = 'No Error Dectected';
    });
    print(_error);
  }

  // Future _addUserImages() async {
  //   // var ref = Firestore.instance.document("users/" + medicallUser.uid);
  //   // var images = [...this.profileImage, ...this.govIdImage];
  //   // await saveImages(images, ref.documentID);
  //   // medicallUser.govId = this.govIdImage as String;
  //   Navigator.of(context).pushNamed('/consent');
  // }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthBase>(context);
    medicallUser = auth.medicallUser;
    _extImageProvider = Provider.of<ExtImageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Upload Identification',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      bottomNavigationBar: FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: profileImage.length == 1 && govIdImage.length == 1
            ? Theme.of(context).primaryColor
            : Colors.grey,
        onPressed: () async {
          if (profileImage.length == 1 && govIdImage.length == 1) {
            auth.tempRegUser.images = [...profileImage, ...govIdImage];
            Navigator.of(context).pushNamed('/consent');
          }
        },
        child: Text(
          profileImage.length == 1 && govIdImage.length == 1
              ? 'CONTINUE'
              : 'IMAGES REQUIRED',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            letterSpacing: 2,
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext ctxt, int index) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
                  child: Text(
                    "We will need a current profile picture, tap icon below.",
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
                Column(
                  children: <Widget>[
                    profileImage.length > 0 && (profileImage.length) >= index
                        ? buildProfileImgView(index, profileImage[index])
                        : Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            child: IconButton(
                              onPressed: loadProfileImage,
                              icon: Icon(
                                Icons.account_circle,
                                color: Colors.purple.withAlpha(140),
                                size: 180,
                              ),
                            ),
                          ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Text(
                        "Also need a government issued id, tap the icon below.",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                    govIdImage.length > 0 && (govIdImage.length) >= index
                        ? buildGridView(index, govIdImage[index])
                        : Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            child: IconButton(
                              onPressed: loadGovIdImage,
                              icon: Icon(
                                CustomIcons.MedicallIcons.license,
                                color: Colors.red.withAlpha(170),
                                size: 140,
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            );
          }),
    );
  }
}
