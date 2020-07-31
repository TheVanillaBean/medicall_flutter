import 'package:Medicall/common_widgets/reusable_card.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderVisitsListItem extends StatelessWidget {
  final Consult consult;
  final VoidCallback onTap;
  const ProviderVisitsListItem({Key key, this.consult, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ExtendedImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);
    if (consult.patientUser != null) {
      return ReusableCard(
        leading: consult.patientUser.profilePic.length > 0
            ? displayProfilePicture(
                extImageProvider, consult.patientUser.profilePic)
            : Icon(
                Icons.account_circle,
                size: 40,
                color: Colors.grey,
              ),
        title: '${consult.patientUser.fullName}',
        subtitle: '${consult.symptom} visit',
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      );
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
