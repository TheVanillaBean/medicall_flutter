import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/services/database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class ViewPatientID extends StatelessWidget {
  final Consult consult;

  const ViewPatientID({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.viewPatientID,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        centerTitle: true,
        title: Text("Patient Photo ID"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: _buildPhotoView(db),
        ),
      ),
    );
  }

  Widget _buildPhotoView(FirestoreDatabase db) {
    return FutureBuilder<MedicallUser>(
      future: db.userStream(USER_TYPE.PATIENT, consult.patientId).first,
      builder: (BuildContext context, AsyncSnapshot<MedicallUser> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData) {
            return PhotoView(
              backgroundDecoration: BoxDecoration(color: Colors.white),
              imageProvider: CachedNetworkImageProvider(snapshot.data.photoID),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 3,
            );
          } else {
            return Center(
              child: Text("Photo ID could not be retrieved..."),
            );
          }
        }
      },
    );
  }
}
