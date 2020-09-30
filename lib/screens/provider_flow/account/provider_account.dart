import 'package:Medicall/common_widgets/provider_bio_card.dart';
import 'package:Medicall/common_widgets/reusable_account_card.dart';
import 'package:Medicall/components/drawer_menu.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_registration_form.dart';
import 'package:Medicall/screens/provider_flow/registration/update_provider_info/update_provider_info_form.dart';
import 'package:Medicall/screens/provider_flow/registration/update_provider_info/update_provider_info_screen.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class ProviderAccountScreen extends StatefulWidget {
  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.providerAccount,
    );
  }

  @override
  _ProviderAccountScreenState createState() => _ProviderAccountScreenState();
}

class _ProviderAccountScreenState extends State<ProviderAccountScreen> {
  String profileImageURL = "";
  bool imageLoading = false;

  @override
  Widget build(BuildContext context) {
    UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);
    FirestoreDatabase _firestoreDB =
        Provider.of<FirestoreDatabase>(context, listen: false);

    ExtImageProvider _extImageProvider =
        Provider.of<ExtImageProvider>(context, listen: false);
    FirebaseStorageService _storageService =
        Provider.of<FirebaseStorageService>(context, listen: false);

    final ProviderUser medicallUser = _userProvider.user;

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
      body: SafeArea(
        child: _buildChildren(
          medicallUser: medicallUser,
          storageService: _storageService,
          extImageProvider: _extImageProvider,
          userProvider: _userProvider,
          firestoreDatabase: _firestoreDB,
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
    FirestoreDatabase firestoreDatabase,
    BuildContext context,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
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
                    firestoreDatabase: firestoreDatabase,
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
            Center(
              child: Text(
                EnumToString.parse(userProvider.user.type).toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.0,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
              width: 150,
              child: Divider(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            _buildEmailCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildPhoneCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildAddressCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildProfessionalTitleCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildMedicalLicenseCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildMedicalLicenseStateCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildNpiCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildBoardCertifiedCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildMedicalSchoolCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildMedicalResidencyCard(medicallUser),
            Divider(height: 0.5, thickness: 1),
            _buildProviderBioCard(medicallUser),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Email:',
      title: medicallUser.email,
    );
  }

  Widget _buildPhoneCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Mobile Phone:',
      title: medicallUser.phoneNumber != null &&
              medicallUser.phoneNumber.length > 0
          ? medicallUser.phoneNumber
          : '(xxx)xxx-xxxx',
      trailing: IconButton(
        icon: Icon(Icons.create, size: 20),
        onPressed: () {
          UpdateProviderInfoScreen.show(
              context: context, inputType: ProfileInputType.PHONE);
        },
      ),
    );
  }

  Widget _buildAddressCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Practice \nAddress:',
      title: medicallUser.mailingAddressLine2 == ''
          ? '${medicallUser.mailingAddress} \n${medicallUser.mailingCity}, ${medicallUser.mailingState} ${medicallUser.mailingZipCode}'
          : '${medicallUser.mailingAddress} \n${medicallUser.mailingAddressLine2} \n${medicallUser.mailingCity}, ${medicallUser.mailingState} ${medicallUser.mailingZipCode}',
      trailing: IconButton(
        icon: Icon(Icons.create, size: 20),
        onPressed: () => UpdateProviderInfoScreen.show(
            context: context, inputType: ProfileInputType.ADDRESS),
      ),
    );
  }

  Widget _buildProfessionalTitleCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Title:',
      title: (medicallUser as ProviderUser).professionalTitle,
      trailing: IconButton(
        icon: Icon(Icons.create, size: 20),
        onPressed: () => UpdateProviderInfoScreen.show(
            context: context, inputType: ProfileInputType.PROFESSIONAL_TITLE),
      ),
    );
  }

  Widget _buildMedicalLicenseCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Medical License:',
      title: '${(medicallUser as ProviderUser).medLicense}',
      trailing: IconButton(icon: Icon(Icons.create, size: 20), onPressed: null),
    );
  }

  Widget _buildMedicalLicenseStateCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Medical License State:',
      title: '${(medicallUser as ProviderUser).medLicenseState}',
      trailing: IconButton(icon: Icon(Icons.create, size: 20), onPressed: null),
    );
  }

  Widget _buildNpiCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'NPI Number:',
      title: '${(medicallUser as ProviderUser).npi}',
      trailing: IconButton(
          icon: Icon(Icons.create, size: 20),
          onPressed: () => UpdateProviderInfoScreen.show(
              context: context, inputType: ProfileInputType.NPI)),
    );
  }

  Widget _buildBoardCertifiedCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Board Certification:',
      title: '${(medicallUser as ProviderUser).boardCertified}',
      trailing: IconButton(icon: Icon(Icons.create, size: 20), onPressed: null),
    );
  }

  Widget _buildMedicalSchoolCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Medical \nSchool:',
      title: '${(medicallUser as ProviderUser).medSchool}',
      trailing: IconButton(icon: Icon(Icons.create, size: 20), onPressed: null),
    );
  }

  Widget _buildMedicalResidencyCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Medical \nResidency:',
      title: '${(medicallUser as ProviderUser).medResidency}',
      trailing: IconButton(icon: Icon(Icons.create, size: 20), onPressed: null),
    );
  }

  Widget _buildProviderBioCard(MedicallUser medicallUser) {
    return ProviderBioCard(
      leading: 'Bio:',
      trailing: IconButton(icon: Icon(Icons.create, size: 20), onPressed: null),
      bioText: '${(medicallUser as ProviderUser).providerBio}',
    );
  }

  Widget _buildAvatarWidget({
    MedicallUser medicallUser,
    FirebaseStorageService storageService,
    ExtImageProvider extImageProvider,
    UserProvider userProvider,
    FirestoreDatabase firestoreDatabase,
  }) {
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => _loadProfileImage(
          storageService: storageService,
          extImageProvider: extImageProvider,
          userProvider: userProvider,
          firestoreDatabase: firestoreDatabase),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        overflow: Overflow.visible,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(300),
            child: this.profileImageURL.length > 0
                ? extImageProvider.returnNetworkImage(
                    this.profileImageURL,
                    height: (height * 0.3),
                    width: (height * 0.3),
                    fit: BoxFit.cover,
                    cache: true,
                  )
                : Icon(
                    Icons.account_circle,
                    color: Colors.blue.withAlpha(140),
                    size: height * 0.20,
                  ),
          ),
          Positioned(
            bottom: 15,
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

  Future<void> _loadProfileImage({
    FirebaseStorageService storageService,
    FirestoreDatabase firestoreDatabase,
    ExtendedImageProvider extImageProvider,
    UserProvider userProvider,
  }) async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await extImageProvider.pickImages(
        [],
        1,
        true,
        extImageProvider.pickImagesCupertinoOptions(takePhotoIcon: 'camera'),
        extImageProvider.pickImagesMaterialOptions(
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
    if (resultList.length > 0) {
      this.setState(() {
        this.imageLoading = true;
      });
      String url =
          await storageService.uploadProfileImage(asset: resultList.first);
      userProvider.user.profilePic = url;
      this.setState(() {
        this.imageLoading = false;
        this.profileImageURL = url;
      });
      await firestoreDatabase.setUser(userProvider.user);
    }
  }
}
