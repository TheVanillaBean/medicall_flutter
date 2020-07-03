import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/util/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderListItem extends StatelessWidget {
  const ProviderListItem({Key key, @required this.provider, this.onTap})
      : super(key: key);
  final User provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      leading: provider.profilePic.length > 0
          ? displayProfilePicture(extImageProvider, provider.profilePic)
          : Icon(
              Icons.account_circle,
              size: 40,
              color: Colors.grey,
            ),
      title: Text(StringUtils.getFormattedProviderName(
        firstName: provider.firstName,
        lastName: provider.lastName,
        titles: provider.titles,
      )),
      subtitle: Text(provider.address),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: 15.0,
      ),
      onTap: onTap,
      dense: true,
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
