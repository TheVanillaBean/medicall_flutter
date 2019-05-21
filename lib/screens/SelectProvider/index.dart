import 'package:flutter/material.dart';
// import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
// import 'package:Medicall/models/providers_model.dart';
import 'package:flutter_alert/flutter_alert.dart';

import 'dart:async';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:Medicall/screens/SelectProvider/placeDetail.dart';
import 'package:Medicall/globals.dart' as globals;


const kGoogleApiKey = 'AIzaSyBx8brcoVisQ4_5FUD-xJlS1i4IwjSS-Hc';
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class SelectProviderScreen extends StatefulWidget {
  final globals.ConsultData data;

  const SelectProviderScreen({Key key, @required this.data})
      : super(key: key);
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
  bool isLoading = false;
  var selectedProvider = '';
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    Widget expandedChild;
    if (isLoading) {
      expandedChild = Center(child: CircularProgressIndicator(value: null));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = buildPlacesList();
    }

    return Scaffold(
        key: homeScaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Select Provider'),
          actions: <Widget>[
            isLoading
                ? IconButton(
                    icon: Icon(Icons.timer),
                    onPressed: () {},
                  )
                : IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      refresh();
                    },
                  ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _handlePressButton();
              },
            ),
          ],
        ),
        bottomNavigationBar: FlatButton(
          padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            if (selectedProvider.length > 0) {
              Navigator.pushNamed(
                context,
                '/questionsHistory',
                arguments: widget.data,
              );
            } else {
              _showMessageDialog();
            }
          },
          child: Text(
            'CONTINUE',
            style: TextStyle(
              letterSpacing: 2,
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Container(
              child: SizedBox(
                  height: 400.0,
                  child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: true,
                      markers: Set<Marker>.of(markers.values),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(0.0, 0.0),
                      ))),
            ),
            Expanded(child: expandedChild)
          ],
        ));
  }

  void _showMessageDialog() {
    showAlert(
        context: context,
        title: 'Notice',
        body: 'Please select one of the providers in order to continue');
  }

  void refresh() async {
    final center = await getUserLocation();

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: center == null ? LatLng(0, 0) : center, zoom: 15.0)));
    getNearbyPlaces(center);
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    refresh();
  }

  void _selectProvider(provider) {
    selectedProvider = provider;
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
    setState(() {
      this.isLoading = true;
      this.errorMessage = null;
    });

    final practice0 =
        await _places.searchByText('281 Lincoln Street Worchester, MA');
    final practice1 =
        await _places.searchByText('1493 Cambridge Street, Cambridge MA');
    final practice2 =
        await _places.searchByText('1244 Boyston Street, Chestnut Hill, MA');
    //final location = Location(center.latitude, center.longitude);
    //final result = await _places.searchByText('281 Lincoln Street Worchester, MA ; ');
    // final result = Future.wait([
    //   _places.searchByText('281 Lincoln Street Worchester, MA'),
    //   _places.searchByText('281 Lincoln Street Worchester, MA'),
    // ]);
    setState(() {
      this.isLoading = false;
      if (practice0.status == 'OK' &&
          practice1.status == 'OK' &&
          practice2.status == 'OK') {
        var newResults = practice0;
        newResults.results.add(practice1.results[0]);
        newResults.results.add(practice2.results[0]);
        this.places = newResults.results;
        newResults.results.forEach((f) {
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
        
          mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target:
                      LatLng(f.geometry.location.lat, f.geometry.location.lng),
                  zoom: 8.0)));
        });
      } else {
        this.errorMessage = practice0.errorMessage +
            practice1.errorMessage +
            practice2.errorMessage;
      }
    });
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<void> _handlePressButton() async {
    try {
      final center = await getUserLocation();
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          strictbounds: center == null ? false : true,
          apiKey: kGoogleApiKey,
          onError: onError,
          mode: Mode.fullscreen,
          language: 'en',
          location: center == null
              ? null
              : Location(center.latitude, center.longitude),
          radius: center == null ? null : 10000);

      showDetailPlace(p.placeId);
    } catch (e) {
      return;
    }
  }

  Future<Null> showDetailPlace(String placeId) async {
    if (placeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceDetailWidget(placeId)),
      );
    }
  }

  ListView buildPlacesList() {
    final doctorNames = [
      'Dr. Omar Badri',
      'Dr. Jeffery Dover',
      'Dr. Robert Stavert'
    ];
    final displayNames = [
      'University of Massachusetts',
      'Cambridge Health Alliance',
      'Skincare Physicians'
    ];
    final placesWidget = places.map((f) {
      List<Widget> list = [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.all(0),
          leading: Icon(
            Icons.account_circle,
            color: Colors.blue,
            size: 50,
          ),
          trailing: Container(
            child: FlatButton(
              onPressed: () {
                setState(() {
                  widget.data.provider = doctorNames[places.indexOf(f)];
                  _selectProvider(doctorNames[places.indexOf(f)]);
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Select',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Icon(
                      selectedProvider == doctorNames[places.indexOf(f)]
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20.0)
                ],
              ),
            ),
          ),
          title: Text(
            doctorNames[places.indexOf(f)],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // subtitle: Text('Intermediate', style: TextStyle(color: Colors.white)),

          subtitle: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    displayNames[places.indexOf(f)],
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    f.formattedAddress.split(',')[0] +
                        f.formattedAddress.split(',')[1],
                  ),
                ],
              ),
            ],
          ),
        ),
      ];

      return Padding(
        padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
        child: Card(
          child: InkWell(
            onTap: () {
              showDetailPlace(f.placeId);
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return ListView(shrinkWrap: true, children: placesWidget);
  }
}
