import 'package:Medicall/common_widgets/flat_button.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/drivers_license/photo_id.dart';
import 'package:Medicall/services/database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class UpdatePhotoID extends StatelessWidget {
  final PatientUser user;

  const UpdatePhotoID({@required this.user});

  static Future<void> show({
    BuildContext context,
    PatientUser user,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.updatePatientID,
      arguments: {
        'user': user,
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
        title: Text("Your Photo ID"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: _buildPhotoView(context: context, db: db),
        ),
      ),
    );
  }

  Widget _buildPhotoView({BuildContext context, FirestoreDatabase db}) {
    return Column(
      children: [
        Expanded(
          child: PhotoView(
            backgroundDecoration: BoxDecoration(color: Colors.white),
            imageProvider: CachedNetworkImageProvider(
              user.photoID,
            ),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 3,
            loadFailedChild: Center(
              child: Text("Failed to retrieve photo ID image..."),
            ),
          ),
        ),
        SizedBox(height: 16),
        CustomFlatButton(
          text: "Update Photo ID",
          trailingIcon: Icons.chevron_right,
          onPressed: () => PhotoIDScreen.show(
            context: context,
            pushReplaceNamed: true,
            consult: null,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
