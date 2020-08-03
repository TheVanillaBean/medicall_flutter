import 'package:Medicall/common_widgets/reusable_account_card.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
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
    UserProvider _userProvider = Provider.of<UserProvider>(context);
    ExtImageProvider _extImageProvider = Provider.of<ExtImageProvider>(context);
    FirebaseStorageService _storageService =
        Provider.of<FirebaseStorageService>(context);

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
          context: context,
        ),
      ),
    );
  }

  Widget _buildChildren({
    User medicallUser,
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
                  fontFamily: 'Roboto Thin',
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
                  fontFamily: 'Roboto Thin',
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
            _buildAddressCard(medicallUser),
            _buildTitleCard(medicallUser),
            _buildMedicalLicenseCard(medicallUser),
            _buildMedicalLicenseStateCard(medicallUser),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailCard(User medicallUser) {
    return ReusableAccountCard(
      title: medicallUser.email,
      leading: Icons.email,
    );
  }

  Widget _buildPhoneCard(User medicallUser) {
    return ReusableAccountCard(
      leading: Icons.phone,
      title: medicallUser.phoneNumber != null &&
              medicallUser.phoneNumber.length > 0
          ? medicallUser.phoneNumber
          : '(xxx)xxx-xxxx',
    );
  }

  Widget _buildAddressCard(User medicallUser) {
    return ReusableAccountCard(
        leading: Icons.home, title: medicallUser.address);
  }

  Widget _buildTitleCard(User medicallUser) {
    return ReusableAccountCard(
      leading: Icons.school,
      title: (medicallUser as ProviderUser).titles,
    );
  }

  Widget _buildMedicalLicenseCard(User medicallUser) {
    return ReusableAccountCard(
      leading: Icons.local_hospital,
      title: 'Medical License: ${(medicallUser as ProviderUser).medLicense}',
    );
  }

  Widget _buildMedicalLicenseStateCard(User medicallUser) {
    return ReusableAccountCard(
      leading: Icons.place,
      title:
          'Medical License State: ${(medicallUser as ProviderUser).medLicenseState}',
    );
  }

  Widget _buildAvatarWidget({
    User medicallUser,
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
                    fit: BoxFit.fill,
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