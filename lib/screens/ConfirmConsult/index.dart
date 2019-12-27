import 'dart:typed_data';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/secrets.dart';
import 'package:Medicall/util/stripe_payment_handler.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
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
  bool hasReviewed = false;
  ConsultData _consult;
  TabController _confirmTabCntrl;
  @override
  void initState() {
    super.initState();
    _consult = widget.data['consult'];
    medicallUser = widget.data['user'];
    _confirmTabCntrl = TabController(length: 2, vsync: this);
    StripeSource.setPublishableKey(stripeKey);
  }

  Future getConsult() async {
    // SharedPreferences pref = await SharedPreferences.getInstance();
    // var perfConsult = jsonDecode(pref.getString('consult'));
    // _consult.consultType = perfConsult["consultType"];
    // _consult.provider = perfConsult["provider"];
    // _consult.providerTitles = perfConsult["providerTitles"];
    // _consult.screeningQuestions = perfConsult["screeningQuestions"];
    // _consult.historyQuestions = perfConsult["historyQuestions"];
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _consult != null
                  ? 'Review ' + _consult.consultType + ' Consult'
                  : _consult != null ? _consult.provider : '',
              style: TextStyle(
                fontSize: Theme.of(context).platform == TargetPlatform.iOS
                    ? 17.0
                    : 20.0,
              ),
            ),
            Text(
              _consult != null
                  ? 'With ${_consult.provider.split(" ")[0][0].toUpperCase()}${_consult.provider.split(" ")[0].substring(1)} ${_consult.provider.split(" ")[1][0].toUpperCase()}${_consult.provider.split(" ")[1].substring(1)} ' +
                      _consult.providerTitles
                  : _consult != null ? _consult.provider : '',
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
      bottomNavigationBar: !isLoading
          ? Container(
              padding: hasReviewed
                  ? EdgeInsets.fromLTRB(0, 0, 0, 0)
                  : EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: BoxDecoration(
                  color: Colors.blue[100].withAlpha(50),
                  border: Border(
                      top: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: hasReviewed ? 2 : 0))),
              height: hasReviewed ? 250 : 56,
              child: hasReviewed
                  ? Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              color: Theme.of(context).colorScheme.primary,
                              padding: EdgeInsets.fromLTRB(0, 18, 0, 10),
                              height: 58,
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                'Consult Review and Payment',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                          padding: EdgeInsets.fromLTRB(10, 85, 10, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _consult.consultType != 'Lesion'
                                        ? 'Contact ' +
                                            _consult.provider +
                                            ' ' +
                                            _consult.providerTitles +
                                            '\nabout your ' +
                                            _consult.consultType
                                        : 'Spot' +
                                            ' consultation with \n' +
                                            _consult.provider +
                                            ' ' +
                                            _consult.providerTitles,
                                    style: TextStyle(
                                        letterSpacing: 1.3,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                  SizedBox(
                                    width: 280,
                                    child: Text(
                                      '*Does not include the cost of any recommended prescriptions. If the provider recommends a prescription, we can send it to a local pharmacy or ship it directly to your door.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    _consult.price,
                                    style: TextStyle(
                                        fontSize: 28,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(25, 0, 25, 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                  child: SafeArea(
                                child: FlatButton(
                                  padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  onPressed: () async {
                                    setState(() {
                                      hasReviewed = true;
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
                        )
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                            child: SafeArea(
                          child: FlatButton(
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(250),
                            onPressed: () async {
                              setState(() {
                                hasReviewed = true;
                                //isLoading = true;
                              });
                            },
                            child: Text(
                              'REVIEW ORDER',
                              style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ))
                      ],
                    ),
            )
          : FlatButton(
              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {},
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
      body: !isLoading
          ? TabBarView(
              // Add tabs as widgets
              children: <Widget>[
                _buildTab(_consult.screeningQuestions),
                //_buildTab(_consult.historyQuestions),
                _buildTab(_consult.uploadQuestions),
              ],
              // set the _confirmTabCntrl
              controller: _confirmTabCntrl,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Thank you for your consult, \n your doctor will be with you shorlty.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
                SizedBox(
                  height: 60,
                ),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
    );
  }

  Future _addConsult() async {
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
      Future.delayed(const Duration(milliseconds: 5000), () {
        return Navigator.pushReplacementNamed(context, '/history',
            arguments: {'consult': _consult, 'user': medicallUser});
      });

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
      _consult.media = questionsList;
      return Scaffold(
        body: Container(
          child: questions[0].containsKey('image')
              ? GridView.count(
                  crossAxisCount: 2,
                  children: List.generate(questionsList.length, (index) {
                    //List<Widget> returnList = [];
                    //returnList.add();
                    return AssetThumb(
                      asset: questionsList[index],
                      width: 300,
                      height: 300,
                    );
                  }),
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
