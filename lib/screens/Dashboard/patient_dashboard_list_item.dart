import 'package:Medicall/common_widgets/reusable_card.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
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
      return ReusableCard(
        leading: consult.providerUser.profilePic.length > 0
            ? displayProfilePicture(
                extImageProvider, consult.providerUser.profilePic)
            : Icon(
                Icons.account_circle,
                size: 40,
                color: Colors.grey,
              ),
        title: 'Dr. ${consult.providerUser.fullName}',
        subtitle: "${consult.symptom}",
        trailing: Text(
          EnumToString.parseCamelCase(consult.state) ?? "",
          style: Theme.of(context).textTheme.caption,
        ),
        onTap: onTap,
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
