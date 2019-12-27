import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/firebase_anonymously_util.dart';
import 'package:Medicall/util/firebase_auth_codes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:Medicall/secrets.dart' as secrets;
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:multi_image_picker/multi_image_picker.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: secrets.kGoogleApiKey);

class RegistrationScreen extends StatefulWidget {
  final data;
  const RegistrationScreen({Key key, @required this.data}) : super(key: key);
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormBuilderState> _userRegKey = GlobalKey<FormBuilderState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final FirebaseAnonymouslyUtil firebaseAnonymouslyUtil =
      FirebaseAnonymouslyUtil();
  var data;
  bool autoValidate = true;
  bool _isLoading = false;
  bool readOnly = false;
  List<dynamic> _addressList = [];
  double formSpacing = 20;
  bool showSegmentedControl = true;
  FirebaseUser firebaseUser;
  DocumentReference documentReference = medicallUser.id != null
      ? Firestore.instance.document("users/" + medicallUser.id)
      : null;

  @override
  void initState() {
    medicallUser = widget.data['user'];
    super.initState();
  }

  getNearbyPlaces(addresses) async {
    var placesList = [];

    for (var i = 0; i < addresses.length; i++) {
      placesList.add(await _places.searchByText(addresses[i]));
      if (placesList[i].status == 'OK') {
        return true;
      } else {
        return false;
      }
    }
  }

  Future moveUserDashboardScreen(FirebaseUser currentUser) async {
    _isLoading = false;
    medicallUser.id = currentUser.uid;
    medicallUser.displayName = _userRegKey.currentState.value['First name'] +
        ' ' +
        _userRegKey.currentState.value['Last name'];
    medicallUser.firstName = _userRegKey.currentState.value['First name'];
    medicallUser.lastName = _userRegKey.currentState.value['Last name'];
    medicallUser.dob = DateFormat('MM-dd-yyyy')
        .format(_userRegKey.currentState.value['Date of birth'])
        .toString();
    medicallUser.gender = _userRegKey.currentState.value['Gender'];
    medicallUser.email = _userRegKey.currentState.value['Email'];
    medicallUser.terms = _userRegKey.currentState.value['Terms and conditions'];
    medicallUser.policy =
        _userRegKey.currentState.value['accept_privacy_switch'];
    medicallUser.consent = _userRegKey.currentState.value['accept_consent'];
    if (medicallUser.type == 'provider') {
      medicallUser.titles = _userRegKey.currentState.value['Medical Titles'];
      medicallUser.npi = _userRegKey.currentState.value['NPI Number'];
      medicallUser.medLicense =
          _userRegKey.currentState.value['License Number'];
      medicallUser.medLicenseState =
          _userRegKey.currentState.value['State Issued'];
    }
    firebaseUser = currentUser;
    // Navigator.of(context).pushReplacement(MaterialPageRoute(
    //   builder: (context) => AuthScreen(),
    // ));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhotoIdScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            '${medicallUser.type != null ? medicallUser.type[0].toUpperCase() : ''}${medicallUser.type != null ? medicallUser.type.substring(1) : ''}' +
                ' Registration'),
      ),
      bottomNavigationBar: FlatButton(
        color: Theme.of(context).colorScheme.primary,
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        onPressed: () {
          _isLoading = true;
          _userRegKey.currentState.save();
          if (_userRegKey.currentState.validate()) {
            print('validationSucceded');
            //print(_userRegKey.currentState.value);
            _signUp();
          } else {
            _isLoading = false;
            print('External FormValidation failed');
          }
        }, // Switch tabs

        child: !_isLoading
            ? Text(
                'SUBMIT',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  letterSpacing: 2,
                ),
              )
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
      ),
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: FormBuilder(
            key: _userRegKey,
            autovalidate: false,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: FormBuilderTextField(
                        attribute: "First name",
                        initialValue: medicallUser.firstName,
                        decoration: InputDecoration(
                            labelText: 'First Name',
                            fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                            filled: true,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: FormBuilderTextField(
                        attribute: "Last name",
                        initialValue: medicallUser.lastName,
                        decoration: InputDecoration(
                            labelText: 'Last Name',
                            fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                            filled: true,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Theme(
                  data: ThemeData(buttonColor: Colors.blue),
                  child: FormBuilderDateTimePicker(
                    attribute: "Date of birth",
                    inputType: InputType.date,
                    initialDatePickerMode: DatePickerMode.year,
                    initialDate: DateTime.utc(DateTime.now().year - 19, 1, 1),
                    format: DateFormat("MM-dd-yyyy"),
                    decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none),
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                medicallUser.type == "provider"
                    ? Column(
                        children: <Widget>[
                          FormBuilderTextField(
                            attribute: "Medical Titles",
                            initialValue: medicallUser.titles,
                            decoration: InputDecoration(
                                labelText: 'Medical Titles',
                                fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                                filled: true,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          FormBuilderTextField(
                            attribute: "NPI Number",
                            initialValue: medicallUser.npi,
                            decoration: InputDecoration(
                                labelText: 'NPI Number',
                                fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                                filled: true,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          FormBuilderTextField(
                            attribute: "License Number",
                            initialValue: medicallUser.medLicense,
                            decoration: InputDecoration(
                                labelText: 'License Number',
                                fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                                filled: true,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          FormBuilderDropdown(
                            attribute: "State Issued",
                            initialValue: medicallUser.medLicenseState,
                            isDense: true,
                            decoration: InputDecoration(
                                labelText: 'State Issued',
                                fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                                filled: true,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                            items: [
                              'Alabama',
                              'Alaska',
                              'American Samoa',
                              'Arizona',
                              'Arkansas',
                              'California',
                              'Colorado',
                              'Connecticut',
                              'Delaware',
                              'District of Columbia',
                              'Florida',
                              'Georgia',
                              'Guam',
                              'Hawaii',
                              'Idaho',
                              'Illinois',
                              'Indiana',
                              'Iowa',
                              'Kansas',
                              'Kentucky',
                              'Louisiana',
                              'Maine',
                              'Maryland',
                              'Massachusetts',
                              'Michigan',
                              'Minnesota',
                              'Minor Outlying Islands',
                              'Mississippi',
                              'Missouri',
                              'Montana',
                              'Nebraska',
                              'Nevada',
                              'New Hampshire',
                              'New Jersey',
                              'New Mexico',
                              'New York',
                              'North Carolina',
                              'North Dakota',
                              'Northern Mariana Islands',
                              'Ohio',
                              'Oklahoma',
                              'Oregon',
                              'Pennsylvania',
                              'Puerto Rico',
                              'Rhode Island',
                              'South Carolina',
                              'South Dakota',
                              'Tennessee',
                              'Texas',
                              'U.S. Virgin Islands',
                              'Utah',
                              'Vermont',
                              'Virginia',
                              'Washington',
                              'West Virginia',
                              'Wisconsin',
                              'Wyoming'
                            ]
                                .map((state) => DropdownMenuItem(
                                      value: state,
                                      child: Text('$state'),
                                    ))
                                .toList(),
                          ),
                        ],
                      )
                    : SizedBox(
                        height: 5,
                      ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(3, 15, 10, 0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Please select your gender below,',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FormBuilderRadio(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          isDense: true,
                          focusedBorder: InputBorder.none),
                      attribute: "Gender",
                      leadingInput: true,
                      options: [
                        FormBuilderFieldOption(
                          value: 'Male',
                        ),
                        FormBuilderFieldOption(
                          value: 'Female',
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: formSpacing,
                ),
                FormBuilderTextField(
                  attribute: "Email",
                  initialValue: medicallUser.email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  validators: [
                    FormBuilderValidators.email(),
                    FormBuilderValidators.required(),
                  ],
                ),
                SizedBox(
                  height: formSpacing,
                ),
                FormBuilderTextField(
                  attribute: "Password",
                  initialValue: "",
                  maxLines: 1,
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText:
                          'Must be 8 characters or more and have at least one uppercase, a lowercase, a number, special character \(\!\@\#\$\&\*\~\)',
                      hintMaxLines: 2,
                      errorMaxLines: 2,
                      hintStyle: TextStyle(fontSize: 12),
                      labelText: 'Password',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  validators: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.min(8),
                    FormBuilderValidators.pattern(
                        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                        errorText:
                            'Requires at least one uppercase, a lowercase, a number, special character \(\!\@\#\$\&\*\~\)'),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                FormBuilderTextField(
                  attribute: "ConfirmPassword",
                  initialValue: "",
                  maxLines: 1,
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText: 'Must match your password exactly',
                      hintStyle: TextStyle(fontSize: 12),
                      labelText: 'Confirm Password',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  validators: [
                    FormBuilderValidators.required(),
                    (val) {
                      var _passW = _userRegKey
                          .currentState.fields['Password'].currentState.value;
                      if (val == _passW)
                        return null;
                      else
                        return "What you entered is not matching your password";
                    },
                  ],
                ),
                SizedBox(
                  height: formSpacing,
                ),
                TypeAheadFormField(
                  hideOnEmpty: true,
                  suggestionsBoxVerticalOffset: 5.0,
                  hideOnError: true,
                  suggestionsBoxDecoration: SuggestionsBoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  textFieldConfiguration: TextFieldConfiguration(
                    onEditingComplete: () {
                      if (_addressList.length == 0) {
                        this._typeAheadController.clear();
                      }
                    },
                    onSubmitted: (v) {
                      if (_addressList.length == 0) {
                        this._typeAheadController.clear();
                      }
                      if (_addressList.indexOf(v) == -1) {
                        this._typeAheadController.clear();
                      }
                    },
                    controller: this._typeAheadController,
                    decoration: InputDecoration(
                        labelText: 'Street Address',
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none),
                  ),
                  suggestionsCallback: (pattern) async {
                    _addressList = [];
                    if (pattern.length > 0) {
                      return await _places.searchByText(pattern).then((val) {
                        _addressList.add(val.results.first.formattedAddress);
                        return _addressList;
                      });
                    } else {
                      return _addressList;
                    }
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  onSuggestionSelected: (suggestion) {
                    this._typeAheadController.text = suggestion;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter valid address';
                    } else {
                      if (_addressList.indexOf(value) == -1) {
                        this._typeAheadController.clear();
                      } else {
                        medicallUser.address = value;
                      }
                      return null;
                    }
                  },
                  onSaved: (value) => medicallUser.address = value,
                ),
                SizedBox(
                  height: 10.0,
                ),
                FormBuilderCheckbox(
                  attribute: 'Terms and conditions',
                  initialValue: medicallUser.terms,
                  leadingInput: true,
                  decoration: InputDecoration(
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  label: FlatButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 62, 0),
                      onPressed: () {
                        Navigator.pushNamed(context, '/terms');
                      },
                      child: Text('Terms & Conditions',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ))),
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                ),
                FormBuilderCheckbox(
                  attribute: 'accept_privacy_switch',
                  initialValue: medicallUser.policy,
                  leadingInput: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  label: FlatButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 62, 0),
                      onPressed: () {
                        Navigator.pushNamed(context, '/privacy');
                      },
                      child: Text('Privacy Policy',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ))),
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() {
    setState(() {
      var _userN = _userRegKey.currentState.value['Email'];
      var _userP = _userRegKey.currentState.value['Password'];
      firebaseAnonymouslyUtil
          .createUser(_userN, _userP)
          .then((String user) => login(_userN, _userP))
          .catchError((e) => loginError(getErrorMessage(error: e)));
    });
  }

  login(String email, String pass) {
    firebaseAnonymouslyUtil
        .signIn(email, pass)
        .then((FirebaseUser user) => moveUserDashboardScreen(user))
        .catchError((e) => loginError(getErrorMessage(error: e)));
  }

  String getErrorMessage({dynamic error}) {
    _isLoading = false;
    if (error.code == FirebaseAuthCodes.ERROR_USER_NOT_FOUND) {
      return "A user with this email does not exist. Register first.";
    } else if (error.code == FirebaseAuthCodes.ERROR_USER_DISABLED) {
      return "This user account has been disabled.";
    } else if (error.code == FirebaseAuthCodes.ERROR_USER_TOKEN_EXPIRED) {
      return "A password change is in the process.";
    } else {
      return error.message;
    }
  }

  loginError(e) {
    setState(() {
      AppUtil().showAlert(e, 5);
    });
  }
}

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
                  '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
              statusBarColor:
                  '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
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
                  '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
              statusBarColor:
                  '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
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
    var ref = Firestore.instance.document("users/" + medicallUser.id);
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
          .child("profile/" + medicallUser.id + '/' + assets[i].name);
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
            ? Theme.of(context).colorScheme.primary
            : Colors.grey,
        onPressed: () async {
          //await setConsult();
          // _consult.media = images;
          // Navigator.pushNamed(context, '/consultReview',
          //     arguments: {'consult': _consult, 'user': medicallUser});
          if (profileImage.length == 1 && govIdImage.length == 1) {
            setState(() {
              _isLoading = true;
            });
            await _addUserImages();
            Navigator.pushNamed(context, '/consent',
                arguments: {'user': medicallUser});
          }
        },
        //Navigator.pushNamed(context, '/history'), // Switch tabs

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
