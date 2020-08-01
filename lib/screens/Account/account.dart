import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/Account/view_medical_history.dart';
import 'package:Medicall/screens/Questions/tempLinksPage.dart';
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

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String profileImageURL = "";
  bool imageLoading = false;

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
                color: Colors.grey,
              ),
            );
          },
        ),
        title: Text(
          'Account',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
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
    User medicallUser,
    FirebaseStorageService storageService,
    ExtImageProvider extImageProvider,
    UserProvider userProvider,
    BuildContext context,
  }) {
    return SingleChildScrollView(
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
          SizedBox(height: 10),
          Text(
            medicallUser.fullName,
            style: TextStyle(
              fontFamily: 'SourceSansPro',
              fontSize: 30.0,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            EnumToString.parse(userProvider.user.type).toUpperCase(),
            style: TextStyle(
              fontFamily: 'SourceSansPro',
              fontSize: 16.0,
              letterSpacing: 2.5,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20,
            width: 150,
            child: Divider(
              color: Colors.grey[300],
            ),
          ),
          _buildEmailCard(medicallUser),
          _buildPhoneCard(medicallUser),
          _buildPaymentMethodsCard(context),
          _buildMedicalHistoryCard(context),
          FlatButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TempLinksPage()));
              },
              child: Text('Links Page')),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
      child: ListTile(
        title: Text(
          'Update Medical History',
          style: TextStyle(color: Colors.grey),
        ),
        leading: Icon(
          Icons.history,
          color: Colors.grey,
        ),
        onTap: () {
          ViewMedicalHistory.show(context: context);
        },
      ),
    );
  }

  Widget _buildPaymentMethodsCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
      child: ListTile(
        title: Text(
          'Payment Cards',
          style: TextStyle(color: Colors.grey),
        ),
        leading: Icon(
          Icons.payment,
          color: Colors.grey,
        ),
        onTap: () {
          Navigator.of(context).pushNamed('/paymentDetail');
        },
      ),
    );
  }

  Widget _buildPhoneCard(User medicallUser) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
      child: ListTile(
        enabled: false,
        title: Text(medicallUser.phoneNumber != null &&
                medicallUser.phoneNumber.length > 0
            ? medicallUser.phoneNumber
            : '(xxx)xxx-xxxx'),
        leading: Icon(
          Icons.phone,
          color: Colors.grey,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildEmailCard(User medicallUser) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
      child: ListTile(
        enabled: false,
        title: Text(
          medicallUser.email,
          style: TextStyle(color: Colors.grey),
        ),
        leading: Icon(Icons.email, color: Colors.grey),
        onTap: () {},
      ),
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
