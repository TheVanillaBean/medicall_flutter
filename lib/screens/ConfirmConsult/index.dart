import 'package:Medicall/common_widgets/carousel/carousel_with_indicator.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/ConfirmConsult/routeUserOrder.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
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
  Database _db;
  User _medicallUser;
  ExtImageProvider _extImageProvider;
  StripeProvider _stripeProvider;
  TabController _confirmTabCntrl;
  @override
  void initState() {
    super.initState();
    _confirmTabCntrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose of the Tab _confirmTabCntrl
    _confirmTabCntrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _db = Provider.of<Database>(context);
    _medicallUser = Provider.of<UserProvider>(context).user;
    _extImageProvider = Provider.of<ExtImageProvider>(context);
    _stripeProvider = Provider.of<StripeProvider>(context);
    _db.newConsult.media = [];
    var _mediaList = [];
    if (_db.newConsult.uploadQuestions.length > 0) {
      for (var i = 0; i < _db.newConsult.uploadQuestions.length; i++) {
        if (_db.newConsult.uploadQuestions[i].containsKey('image') &&
            _db.newConsult.uploadQuestions[i]['visible']) {
          for (var x = 0;
              x < _db.newConsult.uploadQuestions[i]['image'].length;
              x++) {
            _mediaList.add(_db.newConsult.uploadQuestions[i]['image'][x]);
          }
        }
      }
      _db.newConsult.media = _mediaList;
    }
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
                  ? '${_db.newConsult.provider} ${_db.newConsult.providerTitles}'
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
          tabs: <Tab>[
            Tab(
              // set icon to the tab
              icon: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[Icon(Icons.local_pharmacy), Text('Symptom')],
              ),
            ),
            // Tab(
            //   text: 'History',
            //   icon: Icon(Icons.assignment_ind),
            // ),
            Tab(
              icon: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[Icon(Icons.perm_media), Text('Photos')],
              ),
            ),
          ],
          // setup the _confirmTabCntrl
          controller: _confirmTabCntrl,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: !_isLoading
          ? Container(
              padding: _hasReviewed
                  ? EdgeInsets.fromLTRB(0, 0, 0, 0)
                  : EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              height: _hasReviewed ? MediaQuery.of(context).size.height : 56,
              child: _hasReviewed
                  ? Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.fromLTRB(4, 0, 0, 5),
                                height: 77,
                                width: MediaQuery.of(context).size.width,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            'Consult Review and Payment',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              letterSpacing: 1.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        IconButton(
                                          alignment: Alignment.bottomCenter,
                                          iconSize: 24,
                                          icon: Icon(Icons.arrow_back),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
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
                              padding: EdgeInsets.fromLTRB(20, 12, 20, 5),
                              child: Text(
                                'Please review and confirm payment below.',
                                style: TextStyle(
                                    color: Colors.black45, fontSize: 12),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(25, 2, 25, 20),
                              child: Text(
                                '*Does not include the cost of any recommended prescriptions. If the provider recommends a prescription, we can send it to a local pharmacy or ship it directly to your door.',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(30, 180, 45, 10),
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
                                        letterSpacing: 1.1,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black.withAlpha(150)),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    _db.newConsult.price,
                                    style: TextStyle(
                                        fontSize: 28,
                                        color: Colors.black.withAlpha(150),
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
                                            .secondaryVariant,
                                        onPressed: !_isLoading
                                            ? () async {
                                                await confirmPaymentPressed(
                                                  context,
                                                );
                                              }
                                            : () {},
                                        child: Text(
                                          'CONFIRM & PAY',
                                          style: TextStyle(
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.bold),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () async {
                            setState(() {
                              _hasReviewed = true;
                              //_isLoading = true;
                            });
                          },
                          child: Text(
                            'REVIEW ORDER',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
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
              color: Theme.of(context).primaryColorDark,
              onPressed: () {},
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
      body: TabBarView(
        // Add tabs as widgets
        children: <Widget>[
          _buildQuestions(),
          CarouselWithIndicator(
            imgList: _db.newConsult.media,
            from: 'consultReview',
          ),
          //_buildTab(_db.newConsult.historyQuestions),
        ],
        // set the _confirmTabCntrl
        controller: _confirmTabCntrl,
      ),
    );
  }

  _buildQuestions() {
    return Container(
      child: ListView.builder(
          itemCount: _db.newConsult.screeningQuestions.length,
          itemBuilder: (context, i) {
            return _db.newConsult.screeningQuestions[i]['visible']
                ? ListTile(
                    title: Text(
                      _db.newConsult.screeningQuestions[i]['question'],
                      style: TextStyle(fontSize: 14.0, color: Colors.black38),
                    ),
                    subtitle: Text(
                      _db.newConsult.screeningQuestions[i]['answer']
                          .toString()
                          .replaceAll(']', '')
                          .replaceAll('[', '')
                          .replaceAll('null', '')
                          .replaceFirst(', ', ''),
                      style: TextStyle(
                          letterSpacing: 1.0,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                  )
                : SizedBox();
          }),
    );
  }

  Future confirmPaymentPressed(BuildContext context) async {
    setState(() {
      _hasReviewed = true;
      //_isLoading = true;
    });
    //await _addProviderConsult();

    List<dynamic> sources = (await _db.getUserCardSources(_medicallUser.uid));

    if (sources.length == 0) {
      PaymentIntent setupIntent = await _stripeProvider.addSource();
      bool addCard = await _stripeProvider.addCard(setupIntent: setupIntent);
      if (addCard) {
        return await chargeUsersCard(
            paymentMethodId: setupIntent.paymentMethodId, context: context);
      }
    }

    return await chargeUsersCard(
        paymentMethodId: sources.first.id, context: context);
  }

  chargeUsersCard({String paymentMethodId, BuildContext context}) async {
    setState(() {
      _isLoading = true;
    });

    String price = _db.newConsult.price.replaceAll("\$", "");
    _stripeProvider.chargePaymentForPrescription(
      price: int.tryParse(price),
      paymentMethodId: paymentMethodId,
    );
    await _db.addConsult(
      context,
      _db.newConsult,
      _extImageProvider,
      medicallUser: _medicallUser,
    );
    _extImageProvider.clearImageMemory();

    Route route = MaterialPageRoute(
        builder: (context) => RouteUserOrderScreen(
              data: {'user': _medicallUser, 'consult': _db.newConsult},
            ));
    return Navigator.of(context).pushReplacement(route);
  }
}
