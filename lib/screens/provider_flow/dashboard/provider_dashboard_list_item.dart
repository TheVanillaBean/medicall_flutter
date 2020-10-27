import 'package:Medicall/common_widgets/reusable_card.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:badges/badges.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderDashboardListItem extends StatelessWidget {
  const ProviderDashboardListItem({
    @required this.consult,
    this.onTap,
    this.showBadge = true,
  });
  final bool showBadge;
  final Consult consult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);
    if (consult.patientUser != null) {
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
          showBadge: showBadge &&
                  (consult.providerReviewNotifications != 0 ||
                      consult.providerMessageNotifications != 0)
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
          child: ReusableCard(
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
                SizedBox(height: 2),
              ],
            ),
            subtitle: '${consult.parsedDate}',
            trailing: Container(
              width: 80,
              alignment: Alignment.centerLeft,
              child: Text(
                  EnumToString.convertToString(consult.state,
                          camelCase: true) ??
                      "",
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
