import 'dart:convert';
import 'dart:typed_data';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/secrets.dart';
import 'package:Medicall/util/stripe_payment_handler.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart';

class ConfirmConsultScreen extends StatefulWidget {
  final data;

  const ConfirmConsultScreen({Key key, @required this.data}) : super(key: key);
  @override
  _ConfirmConsultScreenState createState() => _ConfirmConsultScreenState();
}

class _ConfirmConsultScreenState extends State<ConfirmConsultScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  double price = 39.00;
  ConsultData _consult;
  TabController _confirmTabCntrl;
  @override
  void initState() {
    super.initState();
    _consult = widget.data['consult'];
    medicallUser = widget.data['user'];
    _confirmTabCntrl = TabController(length: 3, vsync: this);
    StripeSource.setPublishableKey(stripeKey);
  }

  Future getConsult() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var perfConsult = jsonDecode(pref.getString('consult'));
    _consult.consultType = perfConsult["consultType"];
    _consult.provider = perfConsult["provider"];
    _consult.providerTitles = perfConsult["providerTitles"];
    _consult.screeningQuestions = perfConsult["screeningQuestions"];
    _consult.historyQuestions = perfConsult["historyQuestions"];
    return _consult;
  }

  @override
  void dispose() {
    // Dispose of the Tab _confirmTabCntrl
    _confirmTabCntrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getConsult(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    width: 50,
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(),
                  )
                ],
              );
            case ConnectionState.none:
              return Text('Press button to start');
            case ConnectionState.waiting:
              break;
            default:
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              else {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              snapshot != null
                                  ? _consult.consultType + ' Consult'
                                  : snapshot != null ? _consult.provider : '',
                              style: TextStyle(
                                fontSize: Theme.of(context).platform ==
                                        TargetPlatform.iOS
                                    ? 17.0
                                    : 20.0,
                              ),
                            ),
                            Text(
                              snapshot != null
                                  ? '${_consult.provider.split(" ")[0][0].toUpperCase()}${_consult.provider.split(" ")[0].substring(1)} ${_consult.provider.split(" ")[1][0].toUpperCase()}${_consult.provider.split(" ")[1].substring(1)} ' +
                                      _consult.providerTitles
                                  : snapshot != null ? _consult.provider : '',
                              style: TextStyle(
                                fontSize: Theme.of(context).platform ==
                                        TargetPlatform.iOS
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
                            Tab(
                              text: 'History',
                              icon: Icon(Icons.assignment_ind),
                            ),
                            Tab(
                              text: 'Pictures',
                              icon: Icon(Icons.perm_media),
                            ),
                          ],
                          // setup the _confirmTabCntrl
                          controller: _confirmTabCntrl,
                        ),
                        elevation:
                            Theme.of(context).platform == TargetPlatform.iOS
                                ? 0.0
                                : 4.0,
                      ),
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.centerFloat,
                      bottomNavigationBar: !isLoading
                          ? Row(
                              children: <Widget>[
                                Expanded(
                                  child: FlatButton(
                                    padding:
                                        EdgeInsets.fromLTRB(40, 20, 40, 20),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    onPressed: () {},
                                    child: Text(
                                      'Total: \$39',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FlatButton(
                                    padding:
                                        EdgeInsets.fromLTRB(40, 20, 40, 20),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryVariant,
                                    onPressed: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      //await _addProviderConsult();
                                      Firestore.instance
                                          .collection('cards')
                                          .document(medicallUser.id)
                                          .collection('sources')
                                          .getDocuments()
                                          .then((snap) async {
                                        if (snap.documents.length == 0) {
                                          await StripeSource.addSource()
                                              .then((String token) async {
                                            PaymentService().addCard(token);
                                            setState(() {
                                              isLoading = true;
                                            });
                                            return await _addConsult();
                                          });
                                        } else {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await PaymentService().chargePayment(
                                              price,
                                              _consult.consultType +
                                                  ' consult with ' +
                                                  _consult.provider);
                                          return await _addConsult();
                                        }
                                        return Navigator.pushNamed(
                                            context, '/history', arguments: {
                                          'consult': _consult,
                                          'user': medicallUser
                                        });
                                      });
                                    },
                                    child: Text(
                                      'Pay',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : FlatButton(
                              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: () {},
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                      body: TabBarView(
                        // Add tabs as widgets
                        children: <Widget>[
                          _buildTab(_consult.screeningQuestions),
                          _buildTab(_consult.historyQuestions),
                          _buildTab(_consult.media),
                        ],
                        // set the _confirmTabCntrl
                        controller: _confirmTabCntrl,
                      ),
                    );
                  }
                }
              }
          }
          return Text('Press button to start');
        });
  }

  Future _addConsult() async {
    showToast('Please wait while we process your request.',
        duration: Duration(seconds: 5));
    var ref = Firestore.instance.collection('consults').document();

    var imagesList = await saveImages(_consult.media, ref.documentID);
    Map<String, dynamic> data = <String, dynamic>{
      "screening_questions": _consult.screeningQuestions,
      "medical_history_questions": _consult.historyQuestions,
      "type": _consult.consultType,
      "chat": [],
      "state": "new",
      "date": DateTime.now(),
      "consult": "",
      "provider": _consult.provider,
      "providerTitles": _consult.providerTitles,
      "patient": medicallUser.displayName,
      "provider_id": _consult.providerId,
      "patient_id": medicallUser.id,
      "media": _consult.media.length > 0 ? imagesList : "",
    };
    ref.setData(data).whenComplete(() {
      print("Document Added");
      return Navigator.pushReplacementNamed(context, '/history',
          arguments: {'consult': _consult, 'user': medicallUser});
      //_addProviderConsult(ref.documentID, imagesList);
    }).catchError((e) => print(e));
  }

  Future saveImages(assets, consultId) async {
    var allMediaList = [];
    for (var i = 0; i < assets.length; i++) {
      ByteData byteData = await assets[i].requestOriginal();
      List<int> imageData = byteData.buffer.asUint8List();
      StorageReference ref = FirebaseStorage.instance.ref().child("consults/" +
          medicallUser.id +
          '/' +
          consultId +
          "/" +
          assets[i].name);
      StorageUploadTask uploadTask = ref.putData(imageData);

      allMediaList
          .add(await (await uploadTask.onComplete).ref.getDownloadURL());
    }
    return allMediaList;
  }

  _buildTab(questions) {
    if (questions.length > 0) {
      return Scaffold(
        body: Container(
          child: questions[0].runtimeType == Asset
              ? GridView.count(
                  crossAxisCount: 2,
                  children: List.generate(questions.length, (index) {
                    Asset asset = questions[index];
                    return AssetThumb(
                      asset: asset,
                      width: 300,
                      height: 300,
                    );
                  }),
                )
              : ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, i) {
                    return ListTile(
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
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      leading: Text((i + 1).toString() + '.'),
                    );
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
