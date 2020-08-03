import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration_form.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  final ProviderRegistrationViewModel model;
  final ExtendedImageProvider extendedImageProvider;

  const ProviderRegistrationScreen(
      {@required this.model, @required this.extendedImageProvider});

  static Widget create(BuildContext context) {
    final NonAuthDatabase db =
        Provider.of<NonAuthDatabase>(context, listen: false);
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    final FirebaseStorageService firebaseStorageService =
        Provider.of<FirebaseStorageService>(context, listen: false);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final ExtendedImageProvider extendedImageProvider =
        Provider.of<ExtendedImageProvider>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    return ChangeNotifierProvider<ProviderRegistrationViewModel>(
      create: (context) => ProviderRegistrationViewModel(
        nonAuthDatabase: db,
        auth: auth,
        tempUserProvider: tempUserProvider,
        firebaseStorageService: firebaseStorageService,
        firestoreDatabase: firestoreDatabase,
        userProvider: userProvider,
      ),
      child: Consumer<ProviderRegistrationViewModel>(
        builder: (_, model, __) => ProviderRegistrationScreen(
          extendedImageProvider: extendedImageProvider,
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({BuildContext context}) async {
    await Navigator.of(context).pushNamed(Routes.providerRegistration);
  }

  @override
  _ProviderRegistrationScreenState createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Provider Registration",
        theme: Theme.of(context),
      ),
      //Content of tabs
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
            children: <Widget>[
              Center(
                child: _buildProfilePictureWidget(),
              ),
              SizedBox(height: 36),
              ProviderRegistrationForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureWidget() {
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        if (widget.model.profileImage.length == 0)
          ..._buildProfilePlaceholder(height: height),
        if (widget.model.profileImage.length > 0)
          _buildProfileImgView(
              asset: widget.model.profileImage.first, height: height),
      ],
    );
  }

  Widget _buildProfileImgView({Asset asset, double height}) {
    return GestureDetector(
      onTap: _loadProfileImage,
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        overflow: Overflow.visible,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(300),
            child: this.widget.extendedImageProvider.returnAssetThumb(
                  asset: asset,
                  height: (height * 0.2).toInt(),
                  width: (height * 0.2).toInt(),
                ),
          ),
          Positioned(
            bottom: -10,
            child: CircleAvatar(
              backgroundColor: Colors.red,
              radius: 20.0,
              child: new Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProfilePlaceholder({double height}) {
    return [
      Text(
        "Please add a profile picture",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontFamily: 'Roboto Thin',
          fontWeight: FontWeight.w300,
        ),
      ),
      Container(
        height: height * 0.15,
        width: MediaQuery.of(context).size.width,
        child: IconButton(
          onPressed: _loadProfileImage,
          icon: Stack(
            alignment: AlignmentDirectional.bottomStart,
            overflow: Overflow.visible,
            children: <Widget>[
              Icon(
                Icons.account_circle,
                color: Colors.blue.withAlpha(140),
                size: height * 0.15,
              ),
              Positioned(
                bottom: -10,
                child: CircleAvatar(
                  backgroundColor: Colors.red,
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

  Future<void> _loadProfileImage() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await this.widget.extendedImageProvider.pickImages(
            widget.model.profileImage,
            1,
            true,
            this
                .widget
                .extendedImageProvider
                .pickImagesCupertinoOptions(takePhotoIcon: 'camera'),
            this.widget.extendedImageProvider.pickImagesMaterialOptions(
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
            context,
          );
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    if (!mounted) return;
    widget.model.updateWith(profileImage: resultList);
  }
}
