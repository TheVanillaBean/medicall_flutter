import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class RouteUserOrderScreen extends StatefulWidget {
  final data;
  RouteUserOrderScreen({Key key, @required this.data}) : super(key: key);

  @override
  _RouteUserOrderScreenState createState() => _RouteUserOrderScreenState();
}

class _RouteUserOrderScreenState extends State<RouteUserOrderScreen> {
  ConsultData _consult;
  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  void initState() {
    _consult = widget.data['consult'];
    medicallUser = widget.data['user'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            leading: Container(),
            centerTitle: true,
            title: Text('Order Confirmation'),
            elevation:
                Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          ),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Thank you for your payment of ${_consult.price},',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 60,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Doctor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(160.0),
                          child: medicallUser.profilePic != null
                              ? CachedNetworkImage(
                                  height: 160,
                                  width: 160,
                                  fit: BoxFit.cover,
                                  imageUrl: medicallUser.profilePic,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 160,
                                ),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        _consult.provider + ' ' + _consult.providerTitles,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        'will provide care for your',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        _consult.consultType == 'Lesion'
                            ? 'Spot'
                            : _consult.consultType,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 60,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text(
                          'We will now take you to your history where you can view the status of your orders, interact with doctors, and order prescriptions. Please allow 24 hours for the doctor to respond.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/history',
                        arguments: {'consult': _consult, 'user': medicallUser});
                  },
                  child: Text('Go to History'),
                )
              ]),
        ));
  }
}