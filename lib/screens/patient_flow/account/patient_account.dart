import 'package:Medicall/common_widgets/assets_picker/widget/asset_picker.dart';
import 'package:Medicall/common_widgets/reusable_account_card.dart';
import 'package:Medicall/components/drawer_menu/drawer_menu.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/account/payment_detail/payment_detail.dart';
import 'package:Medicall/screens/patient_flow/account/update_patient_info/update_patient_info_form.dart';
import 'package:Medicall/screens/patient_flow/account/update_patient_info/update_patient_info_screen.dart';
import 'package:Medicall/screens/patient_flow/account/update_patient_info/update_patient_info_view_model.dart';
import 'package:Medicall/screens/patient_flow/account/update_photo_id.dart';
import 'package:Medicall/screens/patient_flow/update_medical_history/view_medical_history.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/image_picker.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class PatientAccountScreen extends StatefulWidget {
  final UpdatePatientInfoViewModel model;

  const PatientAccountScreen({this.model});

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    return ChangeNotifierProvider<UpdatePatientInfoViewModel>(
      create: (context) => UpdatePatientInfoViewModel(
        auth: auth,
        firestoreDatabase: firestoreDatabase,
        userProvider: userProvider,
      ),
      child: Consumer<UpdatePatientInfoViewModel>(
        builder: (_, model, __) => PatientAccountScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.patientAccount,
    );
  }

  @override
  _PatientAccountScreenState createState() => _PatientAccountScreenState();
}

class _PatientAccountScreenState extends State<PatientAccountScreen> {
  String profileImageURL = "";
  bool imageLoading = false;
  UpdatePatientInfoViewModel get model => widget.model;

  @override
  Widget build(BuildContext context) {
    UserProvider _userProvider = Provider.of<UserProvider>(context);
    ExtImageProvider _extImageProvider = Provider.of<ExtImageProvider>(context);
    FirebaseStorageService _storageService =
        Provider.of<FirebaseStorageService>(context);

    final PatientUser medicallUser = _userProvider.user;

    this.profileImageURL = _userProvider.user.profilePic;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.home,
                color: Theme.of(context).appBarTheme.iconTheme.color,
              ),
            );
          },
        ),
        title: Text(
          'Account',
          style: Theme.of(context).appBarTheme.textTheme.headline6,
        ),
      ),
      drawer: DrawerMenu(),
      //Content of tabs
      body: SafeArea(
        child: _buildChildren(
          medicallUser: medicallUser,
          storageService: _storageService,
          extImageProvider: _extImageProvider,
          userProvider: _userProvider,
          context: context,
        ),
      ),
    );
  }

  Widget _buildChildren({
    MedicallUser medicallUser,
    FirebaseStorageService storageService,
    ExtImageProvider extImageProvider,
    UserProvider userProvider,
    BuildContext context,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            this.imageLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _buildAvatarWidget(
                    medicallUser: medicallUser,
                    storageService: storageService,
                    extImageProvider: extImageProvider,
                    userProvider: userProvider,
                  ),
            SizedBox(height: 20),
            Center(
              child: Text(
                medicallUser.fullName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20.0,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Text(
              EnumToString.convertToString(userProvider.user.type)
                  .toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
              width: 150,
              child: Divider(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            _buildNameCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildBirthdayCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildEmailCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildPhoneCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildBillingAddressCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildInsuranceCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildPaymentMethodsCard(context),
            Divider(height: 0.5, thickness: 1),
            _buildMedicalHistoryCard(context),
            Divider(height: 0.5, thickness: 1),
            _buildPhotoID(context, userProvider.user),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoID(BuildContext context, PatientUser user) {
    return ReusableAccountCard(
      leading: 'View Photo ID',
      title: '',
      trailing: IconButton(
        icon: Icon(Icons.create, size: 20),
        onPressed: () {
          UpdatePhotoID.show(context: context, user: user);
        },
      ),
      onTap: () {
        UpdatePhotoID.show(context: context, user: user);
      },
    );
  }

  Widget _buildMedicalHistoryCard(BuildContext context) {
    return ReusableAccountCard(
      leading: 'Update Medical History',
      title: '',
      trailing: IconButton(
        icon: Icon(Icons.create, size: 20),
        onPressed: () {
          ViewMedicalHistory.show(context: context);
        },
      ),
    );
  }

  Widget _buildPaymentMethodsCard(BuildContext context) {
    return ReusableAccountCard(
      leading: 'Payment Methods',
      title: '',
      trailing: IconButton(
        icon: Icon(Icons.create, size: 20),
        onPressed: () {
          PaymentDetail.show(context: context, paymentModel: null);
        },
      ),
    );
  }

  Widget _buildBillingAddressCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Billing \nAddress:',
      title: medicallUser.mailingAddressLine2 == ''
          ? '${medicallUser.mailingAddress} \n${medicallUser.mailingCity}, ${medicallUser.mailingState} ${medicallUser.mailingZipCode}'
          : '${medicallUser.mailingAddress} \n${medicallUser.mailingAddressLine2} \n${medicallUser.mailingCity}, ${medicallUser.mailingState} ${medicallUser.mailingZipCode}',
      trailing: IconButton(
          icon: Icon(Icons.create, size: 20),
          onPressed: () {
            model.patientProfileInputType = PatientProfileInputType.ADDRESS;
            model.initAddress();
            UpdatePatientInfoScreen.show(
              context: context,
              model: model,
            );
          }),
    );
  }

  Widget _buildInsuranceCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Insurance:',
      title: medicallUser.insurance,
      trailing: IconButton(
          icon: Icon(Icons.create, size: 20),
          onPressed: () {
            model.patientProfileInputType = PatientProfileInputType.INSURANCE;
            model.initInsurance();
            UpdatePatientInfoScreen.show(
              context: context,
              model: model,
            );
          }),
    );
  }

  Widget _buildPhoneCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Phone:',
      title: medicallUser.phoneNumber != null &&
              medicallUser.phoneNumber.length > 0
          ? medicallUser.phoneNumber
          : '(xxx)xxx-xxxx',
      trailing: IconButton(
        icon: Icon(Icons.create, size: 20),
        onPressed: () {
          model.patientProfileInputType = PatientProfileInputType.PHONE;
          model.initPhoneNumber();
          UpdatePatientInfoScreen.show(
            context: context,
            model: model,
          );
        },
      ),
    );
  }

  Widget _buildEmailCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Email:',
      title: medicallUser.email,
    );
  }

  Widget _buildNameCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Name:',
      title: '${medicallUser.firstName} ${medicallUser.lastName}',
      trailing: IconButton(
        icon: Icon(Icons.create, size: 20),
        onPressed: () {
          model.patientProfileInputType = PatientProfileInputType.NAME;
          model.initName();
          UpdatePatientInfoScreen.show(
            context: context,
            model: model,
          );
        },
      ),
    );
  }

  Widget _buildBirthdayCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Date of Birth:',
      title: medicallUser.dob,
      trailing: IconButton(
        icon: Icon(Icons.create, size: 20),
        onPressed: () {
          model.patientProfileInputType = PatientProfileInputType.DOB;
          model.initBirthDate();
          UpdatePatientInfoScreen.show(
            context: context,
            model: model,
          );
        },
      ),
    );
  }

  Widget _buildAvatarWidget({
    MedicallUser medicallUser,
    FirebaseStorageService storageService,
    ExtImageProvider extImageProvider,
    UserProvider userProvider,
  }) {
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => _loadProfileImage(
        storageService: storageService,
        extImageProvider: extImageProvider,
        userProvider: userProvider,
      ),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        overflow: Overflow.visible,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(300),
            child: this.profileImageURL.length > 0
                ? extImageProvider.returnNetworkImage(
                    this.profileImageURL,
                    height: (height * 0.2),
                    width: (height * 0.2),
                    fit: BoxFit.cover,
                    cache: true,
                  )
                : Icon(
                    Icons.account_circle,
                    color: Colors.blue.withAlpha(140),
                    size: height * 0.15,
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

  ThemeData themeData(Color themeColor) => ThemeData.dark().copyWith(
        buttonColor: themeColor,
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        primaryColorBrightness: Brightness.dark,
        primaryColorLight: Colors.grey[900],
        primaryColorDark: Colors.grey[900],
        accentColor: themeColor,
        accentColorBrightness: Brightness.dark,
        canvasColor: Colors.grey[850],
        scaffoldBackgroundColor: Colors.grey[900],
        bottomAppBarColor: Colors.grey[900],
        cardColor: Colors.grey[900],
        highlightColor: Colors.transparent,
        toggleableActiveColor: themeColor,
        cursorColor: themeColor,
        textSelectionColor: themeColor.withAlpha(100),
        textSelectionHandleColor: themeColor,
        indicatorColor: themeColor,
        appBarTheme: const AppBarTheme(
          brightness: Brightness.dark,
          elevation: 0,
        ),
        colorScheme: ColorScheme(
          primary: Colors.grey[900],
          primaryVariant: Colors.grey[900],
          secondary: themeColor,
          secondaryVariant: themeColor,
          background: Colors.grey[900],
          surface: Colors.grey[900],
          brightness: Brightness.dark,
          error: const Color(0xffcf6679),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.black,
        ),
      );

  Future<void> _loadProfileImage({
    FirebaseStorageService storageService,
    FirestoreDatabase firestoreDatabase,
    ExtendedImageProvider extImageProvider,
    UserProvider userProvider,
  }) async {
    AssetPicker.registerObserve();

    AssetEntity assetEntity = AssetEntity();

    try {
      assetEntity = await ImagePicker.pickSingleImage(context: context);
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    if (!mounted) return;
    if (assetEntity.id != null) {
      this.setState(() {
        this.imageLoading = true;
      });
      String url = await storageService.uploadProfileImage(asset: assetEntity);
      userProvider.user.profilePic = url;
      this.setState(() {
        this.imageLoading = false;
        this.profileImageURL = url;
      });
      await firestoreDatabase.setUser(userProvider.user);
    }
    AssetPicker.unregisterObserve();
  }
}
