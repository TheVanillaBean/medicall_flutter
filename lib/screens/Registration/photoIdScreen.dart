import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;

class PhotoIdScreen extends StatefulWidget {
  final data;
  const PhotoIdScreen({Key key, this.data}) : super(key: key);
  @override
  _PhotoIdScreenState createState() => _PhotoIdScreenState();
}

class _PhotoIdScreenState extends State<PhotoIdScreen> {
  List<Asset> images = List<Asset>();
  List<Asset> govIdImage = List<Asset>();
  List<Asset> profileImage = List<Asset>();
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  Widget buildGridView(index, asset) {
    return GestureDetector(
        onTap: loadGovIdImage,
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(8.0),
          child: AssetThumb(
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
        child: AssetThumb(
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
      govIdImage = List<Asset>();
    });
  }

  Future<void> deleteProfileImage() async {
    //await MultiImagePicker.deleteImages(assets: images);
    setState(() {
      profileImage = List<Asset>();
    });
  }

  Future<void> loadProfileImage() async {
    List<Asset> resultList = List<Asset>();
    String error = '';

    try {
      resultList = await MultiImagePicker.pickImages(
          selectedAssets: profileImage,
          maxImages: 1,
          enableCamera: true,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: 'chat'),
          materialOptions: MaterialOptions(
              useDetailsView: true,
              actionBarColor:
                  '#${Theme.of(context).primaryColor.value.toRadixString(16).toUpperCase().substring(2)}',
              statusBarColor:
                  '#${Theme.of(context).primaryColor.value.toRadixString(16).toUpperCase().substring(2)}',
              lightStatusBar: false,
              autoCloseOnSelectionLimit: true,
              startInAllView: true,
              actionBarTitle: 'Select Profile Picture',
              allViewTitle: 'All Photos'));
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
    List<Asset> resultList = List<Asset>();
    String error = '';

    try {
      resultList = await MultiImagePicker.pickImages(
          selectedAssets: govIdImage,
          maxImages: 1,
          enableCamera: true,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: 'chat'),
          materialOptions: MaterialOptions(
              useDetailsView: true,
              actionBarColor:
                  '#${Theme.of(context).primaryColor.value.toRadixString(16).toUpperCase().substring(2)}',
              statusBarColor:
                  '#${Theme.of(context).primaryColor.value.toRadixString(16).toUpperCase().substring(2)}',
              lightStatusBar: false,
              autoCloseOnSelectionLimit: true,
              startInAllView: true,
              actionBarTitle: 'Select Government Id',
              allViewTitle: 'All Photos'));
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

  Future _addUserImages() async {
    var ref = Firestore.instance.document("users/" + medicallUser.uid);
    var images = [...this.profileImage, ...this.govIdImage];
    var imagesList = await saveImages(images, ref.documentID);
    medicallUser.profilePic = imagesList[0];
    medicallUser.govId = imagesList[1];
  }

  Future saveImages(assets, consultId) async {
    var allMediaList = [];
    for (var i = 0; i < assets.length; i++) {
      ByteData byteData = await assets[i].requestOriginal();
      List<int> imageData = byteData.buffer.asUint8List();
      StorageReference ref = FirebaseStorage.instance
          .ref()
          .child("profile/" + medicallUser.uid + '/' + assets[i].name);
      StorageUploadTask uploadTask = ref.putData(imageData);

      allMediaList
          .add(await (await uploadTask.onComplete).ref.getDownloadURL());
    }
    return allMediaList;
  }

  @override
  Widget build(BuildContext context) {
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
            setState(() {
              _isLoading = true;
            });
            await _addUserImages();
            GlobalNavigatorKey.key.currentState
                .pushNamed('/consent', arguments: {'user': medicallUser});
          }
        },
        child: !_isLoading
            ? Text(
                profileImage.length == 1 && govIdImage.length == 1
                    ? 'CONTINUE'
                    : 'IMAGES REQUIRED',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  letterSpacing: 2,
                ),
              )
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
