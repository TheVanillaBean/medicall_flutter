import 'dart:convert';

import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/secrets.dart' as secrets;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: secrets.kGoogleApiKey);

class SelectProviderScreen extends StatefulWidget {
  final data;

  const SelectProviderScreen({Key key, @required this.data}) : super(key: key);
  @override
  _SelectProviderScreenState createState() => _SelectProviderScreenState();
}

class _SelectProviderScreenState extends State<SelectProviderScreen> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;
  List<PlacesSearchResult> places = [];
  List<String> addresses = [];
  List<String> providers = [];
  bool isLoading = true;
  var selectedProvider = '';
  var providerTitles = '';
  LatLng bounds = LatLng(41.850033, -87.6500523);
  String errorMessage;
  ConsultData _consult = ConsultData();

  @override
  void initState() {
    super.initState();
    medicallUser = widget.data['user'];
    _consult = widget.data['consult'];
    getAddresses();
    getConsult();
  }

  Future getConsult() async {
    if (_consult.provider != null && _consult.provider.length > 0) {
      selectedProvider = _consult.provider;
    }
  }

  setConsult() async {
    SharedPreferences _thisConsult = await SharedPreferences.getInstance();
    _consult.provider = selectedProvider;
    _consult.providerTitles = providerTitles;
    String currentConsultString = jsonEncode(_consult);
    await _thisConsult.setString("consult", currentConsultString);
  }

  Future getAddresses() async {
    addresses = [];
    return Firestore.instance
        .collection('users')
        .where("type", isEqualTo: "provider")
        .snapshots()
        .forEach((snap) {
      snap.documents.forEach((doc) =>
          medicallUser.displayName != doc.data["name"]
              ? addresses.add(doc.data["address"])
              : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Widget expandedChild;
    // if (isLoading) {
    //   expandedChild = Center(child: CircularProgressIndicator(value: null));
    // } else if (errorMessage != null) {
    //   expandedChild = Center(
    //     child: Text(errorMessage),
    //   );
    // } else {
    //   expandedChild = buildPlacesList();
    // }
    return Scaffold(
        key: homeScaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Select Provider'),
          // actions: <Widget>[
          //   isLoading
          //       ? IconButton(
          //           icon: Icon(Icons.timer),
          //           onPressed: () {},
          //         )
          //       : IconButton(
          //           icon: Icon(Icons.refresh),
          //           onPressed: () {
          //             refresh();
          //           },
          //         ),
          // ],
        ),
        bottomNavigationBar: FlatButton(
          padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            if (selectedProvider.length > 0) {
              //await setConsult();
              GlobalNavigatorKey.key.currentState.pushNamed('/consultReview',
                  arguments: {'consult': _consult, 'user': medicallUser});
            } else {
              _showMessageDialog();
            }
          },
          child: Text(
            'CONTINUE',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              letterSpacing: 2,
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            // Expanded(
            //     flex: 1,
            //     child: GoogleMap(
            //         onMapCreated: _onMapCreated,
            //         myLocationEnabled: false,
            //         markers: Set<Marker>.of(markers.values),
            //         initialCameraPosition: CameraPosition(
            //           target: bounds,
            //         ))),
            Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: StreamBuilder(
                      stream:
                          Firestore.instance.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return new Text("Loading");
                        }
                        var userDocuments = snapshot.data.documents;
                        List<Widget> historyList = [];
                        for (var i = 0; i < userDocuments.length; i++) {
                          if (userDocuments[i].data['type'] == 'provider' &&
                              medicallUser.displayName !=
                                  userDocuments[i].data['name']) {
                            providers.add(userDocuments[i].data['name']);
                            historyList.add(Container(
                              height: 75,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                    '${userDocuments[i].data['name'].split(" ")[0][0].toUpperCase()}${userDocuments[i].data['name'].split(" ")[0].substring(1)} ${userDocuments[i].data['name'].split(" ")[1][0].toUpperCase()}${userDocuments[i].data['name'].split(" ")[1].substring(1)}' +
                                        " " +
                                        userDocuments[i].data['titles']),
                                subtitle: Text(userDocuments[i]
                                    .data['address']
                                    .toString()),
                                trailing: FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      _consult.provider =
                                          userDocuments[i].data['name'];
                                      _consult.providerTitles =
                                          userDocuments[i].data['titles'];
                                      _consult.providerDevTokens =
                                          userDocuments[i].data['dev_tokens'];
                                      _consult.providerId =
                                          userDocuments[i].documentID;
                                      _selectProvider(
                                          userDocuments[i].data['name'],
                                          userDocuments[i].data['titles']);
                                    });
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Select',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      Icon(
                                          selectedProvider.toLowerCase() ==
                                                  userDocuments[i]
                                                      .data['name']
                                                      .toString()
                                                      .toLowerCase()
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 20.0)
                                    ],
                                  ),
                                ),
                                leading: Icon(
                                  Icons.account_circle,
                                  size: 50,
                                ),
                              ),
                            ));
                          }
                        }
                        return Column(children: historyList);
                      }),
                ))
          ],
        ));
  }

  void _showMessageDialog() {
    showToast('Please select one of the providers in order to continue',
        duration: Duration(seconds: 4), backgroundColor: Colors.deepOrange);
  }

  void refresh() async {
    final center = null;
    getNearbyPlaces(center);
  }

  // void _onMapCreated(GoogleMapController controller) async {
  //   mapController = controller;
  //   refresh();
  // }

  Future _selectProvider(provider, titles) async {
    selectedProvider = provider;
    providerTitles = titles;
    _consult.provider = selectedProvider;
    _consult.providerTitles = providerTitles;
    //await setConsult();
  }

  Future<LatLng> getUserLocation() async {
    LocationManager.LocationData currentLocation;
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();
      final lat = currentLocation.latitude;
      final lng = currentLocation.longitude;
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  void getNearbyPlaces(LatLng center) async {
    var placesList = [];
    double minLat = 9999.9;
    double minLng = 9999.9;
    double maxLat = -9999.9;
    double maxLng = -9999.9;
    LatLngBounds bound;

    for (var i = 0; i < addresses.length; i++) {
      placesList.add(await _places.searchByText(addresses[i]));

      if (placesList[i].status == 'OK') {
        placesList[i].results.first.types.first = providers[i];
        this.places.add(placesList[i].results.first);

        placesList[i].results.forEach((f) {
          if (f.geometry.location.lat < minLat) {
            minLat = f.geometry.location.lat;
          }
          if (f.geometry.location.lng < minLng) {
            minLng = f.geometry.location.lng;
          }
          if (f.geometry.location.lat > maxLat) {
            maxLat = f.geometry.location.lat;
          }
          if (f.geometry.location.lng > maxLng) {
            maxLng = f.geometry.location.lng;
          }
          final String markerIdVal = 'marker_id_$_markerIdCounter';
          _markerIdCounter++;
          final MarkerId markerId = MarkerId(markerIdVal);

          final Marker marker = Marker(
            markerId: markerId,
            position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
            infoWindow:
                InfoWindow(title: '${f.name}', snippet: '${f.types?.first}'),
          );
          markers[markerId] = marker;

          LatLng latLng_1 = LatLng(minLat, minLng);
          LatLng latLng_2 = LatLng(maxLat, maxLng);
          bound = LatLngBounds(southwest: latLng_1, northeast: latLng_2);
          CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
          this.mapController.animateCamera(u2);
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    print(l1.toString());
    print(l2.toString());
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<Null> showDetailPlace(String placeId) async {
    if (placeId != null) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => PlaceDetailWidget(placeId)),
      // );
    }
  }
}
