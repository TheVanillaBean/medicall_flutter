import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/personal_info/personal_info_form.dart';
import 'package:Medicall/screens/patient_flow/personal_info/personal_info_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class PersonalInfoScreen extends StatefulWidget {
  final PersonalInfoViewModel model;
  final ExtendedImageProvider extendedImageProvider;

  const PersonalInfoScreen(
      {@required this.model, @required this.extendedImageProvider});

  static Widget create(BuildContext context, Consult consult) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final ExtendedImageProvider extendedImageProvider =
        Provider.of<ExtImageProvider>(context);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    final FirebaseStorageService firestoreStorage =
        Provider.of<FirebaseStorageService>(context);
    return ChangeNotifierProvider<PersonalInfoViewModel>(
      create: (context) => PersonalInfoViewModel(
        consult: consult,
        userProvider: userProvider,
        firestoreDatabase: firestoreDatabase,
        firebaseStorageService: firestoreStorage,
      ),
      child: Consumer<PersonalInfoViewModel>(
        builder: (_, model, __) => PersonalInfoScreen(
          model: model,
          extendedImageProvider: extendedImageProvider,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushReplacementNamed(
      Routes.personalInfo,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _billingAddressController =
      TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _billingAddressFocusNode = FocusNode();
  final FocusNode _zipCodeFocusNode = FocusNode();

  PersonalInfoViewModel get model => widget.model;
  ExtImageProvider get extendedImageProvider => widget.extendedImageProvider;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _billingAddressController.dispose();
    _zipCodeController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _billingAddressFocusNode.dispose();
    _zipCodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tell us about yourself"),
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
                children: _buildChildren(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    return <Widget>[
      Center(
        child: _buildProfilePictureWidget(),
      ),
      SizedBox(height: 36),
      PersonalInfoForm(),
      SizedBox(height: 24),
    ];
  }

  Widget _buildProfilePictureWidget() {
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        if (model.profileImage.length == 0)
          ..._buildProfilePlaceholder(height: height),
        if (model.profileImage.length > 0)
          _buildProfileImgView(asset: model.profileImage.first, height: height),
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

  List<Widget> _buildProfilePlaceholder({double height}) {
    return [
      Text(
        "Please add a profile picture\n(Required)",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1,
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

  Future<void> _loadProfileImage() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await this.extendedImageProvider.pickImages(
        [],
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
