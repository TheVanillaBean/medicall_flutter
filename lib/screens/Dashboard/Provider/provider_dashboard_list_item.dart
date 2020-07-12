import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderDashboardListItem extends StatelessWidget {
  const ProviderDashboardListItem({Key key, @required this.consult, this.onTap})
      : super(key: key);
  final Consult consult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);
    if (consult.patientUser != null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          leading: consult.patientUser.profilePic.length > 0
              ? displayProfilePicture(
                  extImageProvider, consult.patientUser.profilePic)
              : Icon(
                  Icons.account_circle,
                  size: 40,
                  color: Colors.grey,
                ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${consult.patientUser.fullName}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text("Reason: ${consult.symptom}"),
              SizedBox(height: 4),
              SizedBox(height: 16),
            ],
          ),
          subtitle: Text(consult.parsedDate),
          trailing: Text(
            "In Review",
            style: TextStyle(color: Colors.blue),
          ),
          onTap: onTap,
        ),
      );
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget displayProfilePicture(
      ExtendedImageProvider extImageProvider, String profilePicAddress) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey.withAlpha(100),
      child: ClipOval(
        child: extImageProvider.returnNetworkImage(
          profilePicAddress,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
