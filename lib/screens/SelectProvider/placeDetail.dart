
import 'package:google_maps_flutter/google_maps_flutter.dart';

const kGoogleApiKey = 'AIzaSyBx8brcoVisQ4_5FUD-xJlS1i4IwjSS-Hc';
Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
MarkerId selectedMarker;

// class PlaceDetailWidget extends StatefulWidget {
//   String placeId;

//   PlaceDetailWidget(String placeId) {
//     this.placeId = placeId;
//   }

//   @override
//   State<StatefulWidget> createState() {
//     return PlaceDetailState();
//   }
// }

// class PlaceDetailState extends State<PlaceDetailWidget> {
//   GoogleMapController mapController;
//   PlacesDetailsResponse place;
//   bool isLoading = false;
//   String errorLoading;

//   @override
//   void initState() {
//     fetchPlaceDetail();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget bodyChild;
//     String title;
//     if (isLoading) {
//       title = 'Loading';
//       bodyChild = Center(
//         child: CircularProgressIndicator(
//           value: null,
//         ),
//       );
//     } else if (errorLoading != null) {
//       title = '';
//       bodyChild = Center(
//         child: Text(errorLoading),
//       );
//     } else {
//       final placeDetail = place.result;
//       final location = place.result.geometry.location;
//       final lat = location.lat;
//       final lng = location.lng;
//       final center = LatLng(lat, lng);

//       title = placeDetail.name;
//       bodyChild = Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           Container(
//               child: SizedBox(
//             height: 200.0,
//             child: GoogleMap(
//               //onMapCreated: _onMapCreated,
//               markers: Set<Marker>.of(markers.values),
//               myLocationEnabled: true,
//               initialCameraPosition: CameraPosition(target: center, zoom: 15.0),
//             ),
//           )),
//           Expanded(
//             child: buildPlaceDetailList(placeDetail),
//           )
//         ],
//       );
//     }

//     return Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title: Text(title),
//         ),
//         body: bodyChild);
//   }

//   void fetchPlaceDetail() async {
//     setState(() {
//       this.isLoading = true;
//       this.errorLoading = null;
//     });

//     PlacesDetailsResponse place =
//         await _places.getDetailsByPlaceId(widget.placeId);

//     if (mounted) {
//       setState(() {
//         this.isLoading = false;
//         if (place.status == 'OK') {
//           this.place = place;
//         } else {
//           this.errorLoading = place.errorMessage;
//         }
//       });
//     }
//   }

//   //void _onMapCreated(GoogleMapController controller) {
//   //mapController = controller;
//   // final placeDetail = place.result;
//   // final location = place.result.geometry.location;
//   // final lat = location.lat;
//   // final lng = location.lng;
//   // final center = LatLng(lat, lng);
//   // var markerOptions = MarkerOptions(
//   //     position: center,
//   //     infoWindowText: InfoWindowText(
//   //         '${placeDetail.name}', '${placeDetail.formattedAddress}'));
//   // mapController.addMarker(markerOptions);
//   // var markerIdVal = this.widget.placeId;
//   // final MarkerId markerId = MarkerId(markerIdVal);
//   // final Marker marker = Marker(
//   //   markerId: markerId,
//   //   position: center,
//   //   infoWindow: InfoWindow(
//   //       title: '${placeDetail.name}',
//   //       snippet: '${placeDetail.formattedAddress}'),
//   // );

//   // setState(() {
//   //   // adding a new marker to map
//   //   markers[markerId] = marker;
//   // });

//   // mapController.animateCamera(CameraUpdate.newCameraPosition(
//   //     CameraPosition(target: center, zoom: 15.0)));
//   //}

//   String buildPhotoURL(String photoReference) {
//     return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$kGoogleApiKey';
//   }

//   ListView buildPlaceDetailList(PlaceDetails placeDetail) {
//     List<Widget> list = [];
//     if (placeDetail.photos != null) {
//       final photos = placeDetail.photos;
//       list.add(SizedBox(
//           height: 100.0,
//           child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: photos.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                     padding: EdgeInsets.only(right: 1.0),
//                     child: SizedBox(
//                       height: 100,
//                       child: Image.network(
//                           buildPhotoURL(photos[index].photoReference)),
//                     ));
//               })));
//     }

//     list.add(
//       Padding(
//           padding:
//               EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
//           child: Text(
//             placeDetail.name,
//             style: Theme.of(context).textTheme.subtitle,
//           )),
//     );

//     if (placeDetail.formattedAddress != null) {
//       list.add(
//         Padding(
//             padding:
//                 EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
//             child: Text(
//               placeDetail.formattedAddress,
//               style: Theme.of(context).textTheme.body1,
//             )),
//       );
//     }

//     // if (placeDetail.types?.first != null) {
//     //   list.add(
//     //     Padding(
//     //         padding:
//     //             EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 0.0),
//     //         child: Text(
//     //           placeDetail.types.first.toUpperCase(),
//     //           style: Theme.of(context).textTheme.caption,
//     //         )),
//     //   );
//     // }

//     // if (placeDetail.formattedPhoneNumber != null) {
//     //   list.add(
//     //     Padding(
//     //         padding:
//     //             EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
//     //         child: Text(
//     //           placeDetail.formattedPhoneNumber,
//     //           style: Theme.of(context).textTheme.button,
//     //         )),
//     //   );
//     // }

//     // if (placeDetail.openingHours != null) {
//     //   final openingHour = placeDetail.openingHours;
//     //   var text = '';
//     //   if (openingHour.openNow) {
//     //     text = 'Opening Now';
//     //   } else {
//     //     text = 'Closed';
//     //   }
//     //   list.add(
//     //     Padding(
//     //         padding:
//     //             EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
//     //         child: Text(
//     //           text,
//     //           style: Theme.of(context).textTheme.caption,
//     //         )),
//     //   );
//     // }

//     // if (placeDetail.website != null) {
//     //   list.add(
//     //     Padding(
//     //         padding:
//     //             EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
//     //         child: Text(
//     //           placeDetail.website,
//     //           style: Theme.of(context).textTheme.caption,
//     //         )),
//     //   );
//     // }

//     // if (placeDetail.rating != null) {
//     //   list.add(
//     //     Padding(
//     //         padding:
//     //             EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
//     //         child: Text(
//     //           'Rating: ${placeDetail.rating}',
//     //           style: Theme.of(context).textTheme.caption,
//     //         )),
//     //   );
//     // }

//     return ListView(
//       shrinkWrap: true,
//       children: list,
//     );
//   }
// }
