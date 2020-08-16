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
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.transparent,
            width: 0.5,
          ),
        ),
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
                '${consult.providerUser.fullName}',
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
            width: 60,
            alignment: Alignment.bottomCenter,
            child: Text(EnumToString.parseCamelCase(consult.state) ?? "",
                style: Theme.of(context).textTheme.caption.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold)),
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
