import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviousConsultsListItem extends StatelessWidget {
  const PreviousConsultsListItem({Key key, this.consult, this.onTap})
      : super(key: key);
  final Consult consult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);
    if (consult.providerUser != null) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Card(
          elevation: 2,
          borderOnForeground: false,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            dense: true,
            leading: consult.providerUser.profilePic.length > 0
                ? displayProfilePicture(
                    extImageProvider, consult.providerUser.profilePic)
                : Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Colors.grey,
                  ),
            title: Text(
              'Dr. ${consult.providerUser.fullName}',
            ),
            subtitle: Text('${consult.symptom} visit'),
            trailing: Icon(Icons.chevron_right, color: Colors.grey),
            onTap: onTap,
          ),
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
