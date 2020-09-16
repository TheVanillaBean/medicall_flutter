import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:Medicall/screens/Registration/photo_id_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class PhotoIdScreen extends StatefulWidget {
  final PhotoIdScreenModel model;

  static Widget create(BuildContext context) {
    final ExtImageProvider _extImageProvider =
        Provider.of<ExtImageProvider>(context);
    return ChangeNotifierProvider<PhotoIdScreenModel>(
      create: (context) => PhotoIdScreenModel(
        extImageProvider: _extImageProvider,
      ),
      child: Consumer<PhotoIdScreenModel>(
        builder: (_, model, __) => PhotoIdScreen(
          model: model,
        ),
      ),
    );
  }

  PhotoIdScreen({@required this.model});
  @override
  _PhotoIdScreenState createState() => _PhotoIdScreenState();
}

class _PhotoIdScreenState extends State<PhotoIdScreen> {
  //We should prob convert this to a stateless widget

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView(index, asset) {
    return GestureDetector(
        onTap: loadGovIdImage,
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(8.0),
          child: widget.model.extImageProvider.returnAssetThumb(
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
        child: widget.model.extImageProvider.returnAssetThumb(
          asset: asset,
          height: 200,
          width: 200,
        ),
      ),
    );
  }

  Future<void> deleteGovIdImage() async {
    //await MultiImagePicker.deleteImages(assets: images);
    widget.model.updateWith(govIdImage: List<Asset>());
  }

  Future<void> deleteProfileImage() async {
    //await MultiImagePicker.deleteImages(assets: images);
    widget.model.updateWith(profileImage: List<Asset>());
  }

  Future<void> loadProfileImage() async {
    List<Asset> resultList = List<Asset>();
    String error = '';

    try {
      resultList = await widget.model.extImageProvider.pickImages(
          widget.model.profileImage,
          1,
          true,
          widget.model.extImageProvider
              .pickImagesCupertinoOptions(takePhotoIcon: 'camera'),
          widget.model.extImageProvider.pickImagesMaterialOptions(
              useDetailsView: true,
              actionBarColor:
                  '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
              statusBarColor:
                  '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
              lightStatusBar: false,
              autoCloseOnSelectionLimit: true,
              startInAllView: true,
              actionBarTitle: 'Select Profile Picture',
              allViewTitle: 'All Photos'),
          context);
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    if (!mounted) return;
    widget.model.updateWith(profileImage: resultList);
    if (error == null) widget.model.updateWith(error: 'No Error Dectected');
  }

  Future<void> loadGovIdImage() async {
    List<Asset> resultList = List<Asset>();
    String error = '';
    try {
      resultList = await widget.model.extImageProvider.pickImages(
          widget.model.govIdImage,
          1,
          true,
          widget.model.extImageProvider
              .pickImagesCupertinoOptions(takePhotoIcon: 'camera'),
          widget.model.extImageProvider.pickImagesMaterialOptions(
            useDetailsView: true,
            actionBarColor:
                '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
            statusBarColor:
                '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
            lightStatusBar: false,
            autoCloseOnSelectionLimit: true,
            startInAllView: true,
            actionBarTitle: 'Select Government Id',
            allViewTitle: 'All Photos',
          ),
          context);
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    if (!mounted) return;
    widget.model.updateWith(govIdImage: resultList);
    if (error == null) widget.model.updateWith(error: 'No Error Dectected');
  }

  @override
  Widget build(BuildContext context) {
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context);
    widget.model.setTempUserProvider(
        tempUserProvider); //This sets the provider with the correct context.
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
      ),
      bottomNavigationBar: FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: widget.model.profileImage.length == 1 &&
                widget.model.govIdImage.length == 1
            ? Theme.of(context).colorScheme.primary
            : Colors.grey,
        onPressed: () async {},
        child: Text(
          widget.model.profileImage.length == 1 &&
                  widget.model.govIdImage.length == 1
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
                    widget.model.profileImage.length > 0 &&
                            (widget.model.profileImage.length) >= index
                        ? buildProfileImgView(
                            index, widget.model.profileImage[index])
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
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text(
                        "Also need a government issued id, tap the icon below. This is required by law, all your information will be encrypted and never distributed for any reason.",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                    widget.model.govIdImage.length > 0 &&
                            (widget.model.govIdImage.length) >= index
                        ? buildGridView(index, widget.model.govIdImage[index])
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
