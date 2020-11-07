import 'package:Medicall/common_widgets/reusable_card.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:badges/badges.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PatientDashboardListItem extends StatelessWidget {
  const PatientDashboardListItem({Key key, @required this.consult, this.onTap})
      : super(key: key);
  final Consult consult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);
    if (consult.providerUser != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Badge(
          padding: EdgeInsets.all(8),
          showBadge: consult.patientReviewNotifications != 0 ||
                  consult.patientMessageNotifications != 0
              ? true
              : false,
          shape: BadgeShape.circle,
          position: BadgePosition.topEnd(top: -6, end: -2),
          badgeColor: Theme.of(context).colorScheme.primary,
          badgeContent: Text(
            '${consult.patientReviewNotifications + consult.patientMessageNotifications}',
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
          ),
          animationType: BadgeAnimationType.scale,
          animationDuration: Duration(milliseconds: 300),
          child: ReusableCard(
            leading: consult.providerUser.profilePic.length > 0
                ? displayProfilePicture(
                    extImageProvider, consult.providerUser.profilePic)
                : Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Colors.grey,
                  ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${consult.providerUser.fullName}, ${consult.providerUser.professionalTitle}',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: 2),
                Text('${consult.symptom} visit',
                    style: Theme.of(context).textTheme.caption),
                SizedBox(height: 2),
              ],
            ),
            subtitle: '${consult.parsedDate}',
            trailing: Container(
              width: 75,
              alignment: Alignment.centerLeft,
              child: Text(getStatus(),
                  style: Theme.of(context).textTheme.caption.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold)),
            ),
            onTap: onTap,
          ),
        ),
      );
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  String getStatus() {
    if (consult.state == ConsultStatus.Completed) {
      return EnumToString.convertToString(ConsultStatus.InReview,
              camelCase: true) ??
          "";
    } else if (consult.state == ConsultStatus.Signed) {
      return "Reviewed by your provider";
    } else {
      return EnumToString.convertToString(consult.state, camelCase: true) ?? "";
    }
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
