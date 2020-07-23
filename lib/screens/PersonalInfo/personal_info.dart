import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/MakePayment/make_payment.dart';
import 'package:Medicall/screens/PersonalInfo/personal_info_view_model.dart';
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
    await Navigator.of(context).pushNamed(
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

  Future<void> _submit() async {
    try {
      await model.submit();
      extendedImageProvider.clearImageMemory();
      MakePayment.show(context: context, consult: model.consult);
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Info"),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName(Routes.symptoms),
                );
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
      Text(
        'Does everything look correct?',
        style: TextStyle(fontSize: 30),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 24),
      _buildProfilePictureWidget(),
      SizedBox(height: 24),
      Row(
        children: <Widget>[
          Expanded(child: _buildFirstNameTextField()),
          Expanded(child: _buildLastNameTextField()),
        ],
      ),
      SizedBox(height: 24),
      Row(
        children: <Widget>[
          Expanded(child: _buildBillingAddressTextField()),
          Expanded(child: _buildZipCodeTextField()),
        ],
      ),
      SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            color: Theme.of(context).colorScheme.secondary,
            child: Text(
              "Birthday: ${model.birthday}",
              style: TextStyle(color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      SizedBox(height: 24),
      Row(
        children: <Widget>[
          Expanded(
            child: SignInButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              text: "Looks Good!",
              onPressed: model.canSubmit ? _submit : null,
            ),
          )
        ],
      ),
      SizedBox(height: 12),
      if (model.isLoading) const CircularProgressIndicator(),
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

  TextField _buildFirstNameTextField() {
    return TextField(
      controller: _firstNameController,
      focusNode: _firstNameFocusNode,
      autocorrect: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model.updateFirstName,
      style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        hintStyle: TextStyle(
          color: Color.fromRGBO(100, 100, 100, 1),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(100),
        prefixIcon: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
        labelText: 'First Name',
        hintText: 'Jane',
        errorText: model.firstNameErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }

  TextField _buildLastNameTextField() {
    return TextField(
      controller: _lastNameController,
      focusNode: _lastNameFocusNode,
      autocorrect: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model.updateLastName,
      style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        hintStyle: TextStyle(
          color: Color.fromRGBO(100, 100, 100, 1),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(100),
        prefixIcon: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
        labelText: 'Last Name',
        hintText: 'Doe',
        errorText: model.lastNameErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }

  TextField _buildBillingAddressTextField() {
    return TextField(
      controller: _billingAddressController,
      focusNode: _billingAddressFocusNode,
      autocorrect: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: model.updateBillingAddress,
      style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        hintStyle: TextStyle(
          color: Color.fromRGBO(100, 100, 100, 1),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(100),
        prefixIcon: Icon(
          Icons.location_city,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
        labelText: 'Billing Address',
        hintText: '541 Tremont St.',
        errorText: model.billingAddressErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }

  TextField _buildZipCodeTextField() {
    return TextField(
      controller: _zipCodeController,
      focusNode: _zipCodeFocusNode,
      autocorrect: false,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onChanged: model.updateZipCode,
      style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        hintStyle: TextStyle(
          color: Color.fromRGBO(100, 100, 100, 1),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(100),
        prefixIcon: Icon(
          Icons.location_city,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
        labelText: 'Zip Code',
        hintText: '85226',
        errorText: model.zipCodeErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    final DateTime currentDate = DateTime.now();
    final initialDate = model.birthDate.year <= DateTime.now().year - 18
        ? model.birthDate
        : DateTime(
            currentDate.year - 18,
            currentDate.month,
            currentDate.day,
          );
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate:
          DateTime(currentDate.year - 18, currentDate.month, currentDate.day),
    );
    if (picked != null && picked != currentDate) {
      model.updateWith(birthDate: picked);
    }
  }

  Widget _buildProfileImgView({Asset asset, double height}) {
    return GestureDetector(
      onTap: _loadProfileImage,
      child: ClipRRect(
        borderRadius: new BorderRadius.circular(500.0),
        child: this.extendedImageProvider.returnAssetThumb(
              asset: asset,
              height: (height * 0.2).toInt(),
              width: (height * 0.2).toInt(),
            ),
      ),
    );
  }

  List<Widget> _buildProfilePlaceholder({double height}) {
    return [
      Text(
        "We will need a current profile picture, tap icon below.",
        style: TextStyle(fontSize: 12, color: Colors.black87),
      ),
      Container(
        height: height * 0.15,
        width: MediaQuery.of(context).size.width,
        child: IconButton(
          onPressed: _loadProfileImage,
          icon: Icon(
            Icons.account_circle,
            color: Colors.blue.withAlpha(140),
            size: height * 0.15,
          ),
        ),
      )
    ];
  }

  Future<void> _loadProfileImage() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await this.extendedImageProvider.pickImages(
            model.profileImage,
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
