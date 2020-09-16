import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/drivers_license/photo_id_view_model.dart';
import 'package:Medicall/screens/patient_flow/personal_info/personal_info.dart';
import 'package:Medicall/screens/patient_flow/visit_payment/make_payment.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PhotoIDScreen extends StatelessWidget {
  final PhotoIDViewModel model;
  final ExtendedImageProvider extendedImageProvider;

  const PhotoIDScreen({
    @required this.model,
    @required this.extendedImageProvider,
  });

  static Widget create(BuildContext context, Consult consult) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final ExtendedImageProvider extendedImageProvider =
        Provider.of<ExtImageProvider>(context);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    final FirebaseStorageService firestoreStorage =
        Provider.of<FirebaseStorageService>(context);
    return ChangeNotifierProvider<PhotoIDViewModel>(
      create: (context) => PhotoIDViewModel(
        consult: consult,
        userProvider: userProvider,
        firestoreDatabase: firestoreDatabase,
        firebaseStorageService: firestoreStorage,
      ),
      child: Consumer<PhotoIDViewModel>(
        builder: (_, model, __) => PhotoIDScreen(
          model: model,
          extendedImageProvider: extendedImageProvider,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed = true,
    Consult consult,
  }) async {
    if (pushReplaceNamed) {
      await Navigator.of(context).pushReplacementNamed(
        Routes.photoID,
        arguments: {
          'consult': consult,
        },
      );
    } else {
      await Navigator.of(context).pushNamed(
        Routes.photoID,
        arguments: {
          'consult': consult,
        },
      );
    }
  }

  Future<void> _submit(
    ExtendedImageProvider extendedImageProvider,
    BuildContext context,
  ) async {
    try {
      await model.submit();
      extendedImageProvider.clearImageMemory();
      if ((model.userProvider.user as PatientUser).fullName.length > 2 &&
          (model.userProvider.user as PatientUser).profilePic.length > 2 &&
          (model.userProvider.user as PatientUser).mailingAddress.length > 2) {
        MakePayment.show(context: context, consult: model.consult);
      } else {
        PersonalInfoScreen.show(context: context, consult: model.consult);
      }
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Photo ID"),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                PatientDashboardScreen.show(
                    context: context, pushReplaceNamed: true);
              },
              icon: Icon(Icons.close),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildChildren(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    return <Widget>[
      Center(
        child: _buildProfilePictureWidget(context),
      ),
      SizedBox(height: 30),
      Align(
        alignment: FractionalOffset.bottomCenter,
        child: SizedBox(
          height: 50,
          width: 200,
          child: RoundedLoadingButton(
            controller: model.btnController,
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              'Submit Photo ID!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            onPressed: !model.isLoading
                ? () {
                    _submit(extendedImageProvider, context);
                  }
                : null,
          ),
        ),
      ),
    ];
  }

  Widget _buildProfilePictureWidget(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        if (model.idPhoto.length == 0)
          ..._buildProfilePlaceholder(context: context, height: height),
        if (model.idPhoto.length > 0)
          _buildProfileImgView(
              context: context, asset: model.idPhoto.first, height: height),
      ],
    );
  }

  Widget _buildProfileImgView(
      {BuildContext context, Asset asset, double height}) {
    return GestureDetector(
      onTap: () => _loadProfileImage(context),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        overflow: Overflow.visible,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(300),
            child: this.extendedImageProvider.returnAssetThumb(
                  asset: asset,
                  height: (height * 0.2).toInt(),
                  width: (height * 0.2).toInt(),
                ),
          ),
          Positioned(
            bottom: -10,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 20.0,
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProfilePlaceholder({BuildContext context, double height}) {
    return [
      Text(
        "Please upload a photo ID\nThis is a legal requirement for telemedicine",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      Container(
        height: height * 0.15,
        width: MediaQuery.of(context).size.width,
        child: IconButton(
          onPressed: () => _loadProfileImage(context),
          icon: Stack(
            alignment: AlignmentDirectional.bottomStart,
            overflow: Overflow.visible,
            children: <Widget>[
              Icon(
                Icons.account_circle,
                color: Colors.grey.withAlpha(140),
                size: height * 0.15,
              ),
              Positioned(
                bottom: -10,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  radius: 20.0,
                  child: new Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Future<void> _loadProfileImage(BuildContext context) async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await this.extendedImageProvider.pickImages(
            model.idPhoto,
            1,
            true,
            this
                .extendedImageProvider
                .pickImagesCupertinoOptions(takePhotoIcon: 'camera'),
            this.extendedImageProvider.pickImagesMaterialOptions(
                useDetailsView: true,
                actionBarColor:
                    '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
                statusBarColor:
                    '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
                lightStatusBar: false,
                autoCloseOnSelectionLimit: true,
                startInAllView: true,
                actionBarTitle: 'Select Photo ID',
                allViewTitle: 'All Photos'),
            context,
          );
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }

    model.updateWith(idPhoto: resultList);
  }
}
