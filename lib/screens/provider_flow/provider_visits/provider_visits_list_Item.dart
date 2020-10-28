import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:badges/badges.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviousVisitsListItem extends StatelessWidget {
  const PreviousVisitsListItem({Key key, this.consult, this.onTap})
      : super(key: key);
  final Consult consult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);
    if (consult.patientUser != null) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Badge(
          padding: EdgeInsets.all(8),
          showBadge: consult.providerReviewNotifications != 0 ||
                  consult.providerMessageNotifications != 0
              ? true
              : false,
          shape: BadgeShape.circle,
          position: BadgePosition.topEnd(top: -6, end: -2),
          badgeColor: Theme.of(context).colorScheme.primary,
          badgeContent: Text(
            '${consult.providerReviewNotifications + consult.providerMessageNotifications}',
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
          ),
          animationType: BadgeAnimationType.scale,
          animationDuration: Duration(milliseconds: 300),
          child: Card(
            elevation: 2,
            borderOnForeground: false,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
              dense: true,
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
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 2),
                  Text('${consult.symptom} visit',
                      style: Theme.of(context).textTheme.caption),
                ],
              ),
              subtitle: Text('${consult.parsedDate}'),
              trailing: Container(
                alignment: Alignment.centerLeft,
                width: 80,
                child: Text(
                    EnumToString.convertToString(consult.state,
                            camelCase: true) ??
                        "",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.caption.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold)),
              ),
              onTap: onTap,
            ),
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
