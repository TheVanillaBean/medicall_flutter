import 'dart:typed_data';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/ConfirmConsult/routeUserOrder.dart';
import 'package:Medicall/screens/History/carouselWithIndicator.dart';
import 'package:Medicall/secrets.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/stripe_payment_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

class ConfirmConsultScreen extends StatefulWidget {
  const ConfirmConsultScreen({Key key}) : super(key: key);
  @override
  _ConfirmConsultScreenState createState() => _ConfirmConsultScreenState();
}

class _ConfirmConsultScreenState extends State<ConfirmConsultScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _hasReviewed = false;
  var _db;
  MedicallUser _medicallUser;

  TabController _confirmTabCntrl;
  @override
  void initState() {
    super.initState();
    _confirmTabCntrl = TabController(length: 2, vsync: this);
    StripeSource.setPublishableKey(stripeKey);
  }

  @override
  void dispose() {
    // Dispose of the Tab _confirmTabCntrl
    _confirmTabCntrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _db = Provider.of<Database>(context);
    _medicallUser = Provider.of<UserProvider>(context).medicallUser;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _db.newConsult != null
                  ? _db.newConsult.consultType == 'Lesion'
                      ? 'Review Spot Consult'
                      : 'Review ' + _db.newConsult.consultType + ' Consult'
                  : _db.newConsult != null ? _db.newConsult.provider : '',
              style: TextStyle(
                fontSize: Theme.of(context).platform == TargetPlatform.iOS
                    ? 17.0
                    : 20.0,
              ),
            ),
            Text(
              _db.newConsult != null
                  ? 'With ${_db.newConsult.provider.split(" ")[0][0].toUpperCase()}${_db.newConsult.provider.split(" ")[0].substring(1)} ${_db.newConsult.provider.split(" ")[1][0].toUpperCase()}${_db.newConsult.provider.split(" ")[1].substring(1)} ' +
                      _db.newConsult.providerTitles
                  : _db.newConsult != null ? _db.newConsult.provider : '',
              style: TextStyle(
                fontSize: Theme.of(context).platform == TargetPlatform.iOS
                    ? 12.0
                    : 14.0,
              ),
            )
          ],
        ),
        bottom: TabBar(
          indicatorColor: Colors.white,
          tabs: <Tab>[
            Tab(
              // set icon to the tab
              text: 'Symptom',
              icon: Icon(Icons.local_pharmacy),
            ),
            // Tab(
            //   text: 'History',
            //   icon: Icon(Icons.assignment_ind),
            // ),
            Tab(
              text: 'Pictures',
              icon: Icon(Icons.perm_media),
            ),
          ],
          // setup the _confirmTabCntrl
          controller: _confirmTabCntrl,
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: !_isLoading
          ? Container(
              padding: _hasReviewed
                  ? EdgeInsets.fromLTRB(0, 0, 0, 0)
                  : EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: _hasReviewed ? 2 : 0))),
              height: _hasReviewed ? 280 : 56,
              child: _hasReviewed
                  ? Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                                color: Theme.of(context).primaryColor,
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                height: 58,
                                width: MediaQuery.of(context).size.width,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          'Consult Review and Payment',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            letterSpacing: 1.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        IconButton(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(5),
                                          iconSize: 28,
                                          icon: Icon(Icons.close),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          onPressed: () {
                                            setState(() {
                                              _hasReviewed = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 2, 20, 10),
                              child: Text(
                                'Please review and confirm payment below.',
                                style: TextStyle(
                                    color: Colors.black45, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(35, 85, 55, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _db.newConsult.consultType != 'Lesion'
                                        ? 'Contact ' +
                                            _db.newConsult.provider +
                                            ' ' +
                                            _db.newConsult.providerTitles +
                                            '\nabout your ' +
                                            _db.newConsult.consultType
                                        : 'Spot' +
                                            ' consultation with \n' +
                                            _db.newConsult.provider +
                                            ' ' +
                                            _db.newConsult.providerTitles,
                                    style: TextStyle(
                                        letterSpacing: 1.3,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    _db.newConsult.price,
                                    style: TextStyle(
                                        fontSize: 28,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(25, 0, 25, 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  '*Does not include the cost of any recommended prescriptions. If the provider recommends a prescription, we can send it to a local pharmacy or ship it directly to your door.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Expanded(
                                        child: SafeArea(
                                      child: FlatButton(
                                        padding:
                                            EdgeInsets.fromLTRB(40, 20, 40, 20),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        onPressed: () async {
                                          setState(() {
                                            _hasReviewed = true;
                                            //_isLoading = true;
                                          });
                                          //await _addProviderConsult();
                                          Firestore.instance
                                              .collection('cards')
                                              .document(_medicallUser.uid)
                                              .collection('sources')
                                              .getDocuments()
                                              .then((snap) async {
                                            if (snap.documents.length == 0) {
                                              await StripeSource.addSource()
                                                  .then((String token) async {
                                                await PaymentService()
                                                    .addCard(token);
                                                //return await _addConsult();
                                              });
                                            } else {
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              await PaymentService()
                                                  .chargePayment(
                                                      _db.newConsult.price,
                                                      _db.newConsult
                                                              .consultType +
                                                          ' consult with ' +
                                                          _db.newConsult
                                                              .provider);
                                              _addConsult(context);

                                              // await PaymentService()
                                              //     .chargePayment(
                                              //         price,
                                              //         _db.newConsult.consultType +
                                              //             ' consult with ' +
                                              //             _db.newConsult.provider);
                                              // return await _addConsult();
                                            }
                                            // return Navigator.pushNamed(
                                            //     context, '/history',
                                            //     arguments: {
                                            //       'consult': _db.newConsult,
                                            //       'user': _medicallUser
                                            //     });
                                          });
                                        },
                                        child: Text(
                                          'CONFIRM & PAY',
                                          style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ))
                                  ],
                                ),
                              ],
                            ))
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                            child: FlatButton(
                          padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(100),
                          onPressed: () async {
                            setState(() {
                              _hasReviewed = true;
                              //_isLoading = true;
                            });
                          },
                          child: Text(
                            'REVIEW ORDER',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ))
                      ],
                    ),
            )
          : FlatButton(
              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
              color: Theme.of(context).primaryColor,
              onPressed: () {},
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
      body: TabBarView(
        // Add tabs as widgets
        children: <Widget>[
          _buildTab(_db.newConsult.screeningQuestions),
          _buildTab(_db.newConsult.uploadQuestions),
          //_buildTab(_db.newConsult.historyQuestions),
        ],
        // set the _confirmTabCntrl
        controller: _confirmTabCntrl,
      ),
    );
  }

  Future _addConsult(context) async {
    var ref = Firestore.instance.collection('consults').document();

    var imagesList = await saveImages(_db.newConsult.media, ref.documentID);
    Map<String, dynamic> data = <String, dynamic>{
      "screening_questions": _db.newConsult.screeningQuestions,
      //"medical_history_questions": _db.newConsult.historyQuestions,
      "type": _db.newConsult.consultType,
      "chat": [],
      "state": "new",
      "date": DateTime.now(),
      "medication_name": "",
      "provider": _db.newConsult.provider,
      "providerTitles": _db.newConsult.providerTitles,
      "patient": _medicallUser.displayName,
      "provider_profile": _db.newConsult.providerProfilePic,
      "patient_profile": _medicallUser.profilePic,
      "consult_price": _db.newConsult.price,
      "provider_id": _db.newConsult.providerId,
      "patient_id": _medicallUser.uid,
      "media": _db.newConsult.media.length > 0 ? imagesList : "",
    };
    ref.setData(data).whenComplete(() {
      print("Consult Added");
      // Future.delayed(const Duration(milliseconds: 5000), () {
      //   return Navigator.pushReplacementNamed(context, '/history',
      //       arguments: {'consult': _db.newConsult, 'user': _medicallUser});
      // });
      imageCache.clear();
      Route route = MaterialPageRoute(
          builder: (context) => RouteUserOrderScreen(
                data: {'user': _medicallUser, 'consult': _db.newConsult},
              ));
      return Navigator.of(context).pushReplacement(route);

      //_addProviderConsult(ref.documentID, imagesList);
    }).catchError((e) => print(e));
  }

  Future saveImages(assets, consultId) async {
    var allMediaList = [];
    var allFileNames = [];
    for (var i = 0; i < assets.length; i++) {
      if (!allFileNames.contains(assets[i].name)) {
        allFileNames.add(assets[i].name);
      } else {
        allFileNames.add(assets[i].name.split('.')[0] +
            '_' +
            i.toString() +
            '.' +
            assets[i].name.split('.')[1]);
      }
    }
    for (var i = 0; i < assets.length; i++) {
      ByteData byteData = await assets[i].requestOriginal();
      List<int> imageData = byteData.buffer.asUint8List();
      StorageReference ref = FirebaseStorage.instance.ref().child("consults/" +
          _medicallUser.uid +
          '/' +
          consultId +
          "/" +
          allFileNames[i]);
      StorageUploadTask uploadTask = ref.putData(imageData);

      allMediaList
          .add(await (await uploadTask.onComplete).ref.getDownloadURL());
    }
    return allMediaList;
  }

  _buildTab(questions) {
    List<Asset> questionsList = [];
    if (questions.length > 0) {
      for (var i = 0; i < questions.length; i++) {
        if (questions[i].containsKey('image') &&
            questions[i]['visible'] &&
            questions[i]['image'].length > 1) {
          for (var x = 0; x < questions[i]['image'].length; x++) {
            questionsList.add(questions[i]['image'][x]);
          }
        }
        if (questions[i].containsKey('image') &&
            questions[i]['visible'] &&
            questions[i]['image'].length == 1) {
          for (var x = 0; x < questions[i]['image'].length; x++) {
            questionsList.add(questions[i]['image'][x]);
          }
        }
      }
      _db.newConsult.media = questionsList;

      return Scaffold(
        body: Container(
          child: questions[0].containsKey('image')
              ? CarouselWithIndicator(
                  imgList: questionsList,
                  from: 'consultReview',
                )
              : ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, i) {
                    return questions[i]['visible']
                        ? ListTile(
                            title: Text(
                              questions[i]['question'],
                              style: TextStyle(fontSize: 14.0),
                            ),
                            subtitle: Text(
                              questions[i]['answer']
                                  .toString()
                                  .replaceAll(']', '')
                                  .replaceAll('[', '')
                                  .replaceAll('null', '')
                                  .replaceFirst(', ', ''),
                              style: TextStyle(
                                  letterSpacing: 1.0,
                                  height: 1.2,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          )
                        : SizedBox();
                  }),
        ),
      );
    } else {
      return Center(
        child: Icon(
          Icons.broken_image,
          size: 140,
          color: Theme.of(context).colorScheme.secondary.withAlpha(90),
        ),
      );
    }
  }
}
