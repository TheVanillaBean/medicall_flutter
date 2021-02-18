import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/util/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderListItem extends StatelessWidget {
  const ProviderListItem({
    Key key,
    @required this.provider,
    @required this.inNetwork,
    this.onTap,
  }) : super(key: key);

  final ProviderUser provider;
  final VoidCallback onTap;
  final bool inNetwork;

  @override
  Widget build(BuildContext context) {
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Card(
        elevation: 3,
        shadowColor: Colors.grey.withAlpha(120),
        borderOnForeground: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          dense: true,
          leading: provider.profilePic.length > 0
              ? displayProfilePicture(extImageProvider, provider.profilePic)
              : Icon(
                  Icons.account_circle,
                  size: 40,
                  color: Colors.grey,
                ),
          title: Text(
            StringUtils.getFormattedProviderName(
              firstName: provider.firstName,
              lastName: provider.lastName,
              professionalTitle: provider.professionalTitle,
            ),
            style: Theme.of(context).textTheme.bodyText1,
          ),
          subtitle: Text(
            provider.mailingAddressLine2 == ''
                ? '${provider.mailingAddress} \n${provider.mailingCity}, ${provider.mailingState} ${provider.mailingZipCode}'
                : '${provider.mailingAddress} \n${provider.mailingAddressLine2} \n${provider.mailingCity}, ${provider.mailingState} ${provider.mailingZipCode}',
            style: Theme.of(context).textTheme.caption,
          ),
          trailing: Container(
            width: 103,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          inNetwork ? "See Price" : "\$75",
                          style: Theme.of(context).textTheme.button,
                        ),
                      ],
                    ),
                    Text(
                      inNetwork ? "with insurance" : "out-of-network",
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(fontSize: 10),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 25.0,
                    ),
                  ],
                )
              ],
            ),
          ),
          onTap: onTap,
        ),
      ),
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
