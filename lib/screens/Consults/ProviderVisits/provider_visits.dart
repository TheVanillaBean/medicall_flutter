import 'package:Medicall/chat/chat_screen.dart';
import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/empty_content.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Consults/ProviderVisits/provider_visits_list_Item.dart';
import 'package:Medicall/screens/Consults/ProviderVisits/provider_visits_view_model.dart';
import 'package:Medicall/services/chat_provider.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderVisits extends StatelessWidget {
  final ProviderVisitsViewModel model;
  const ProviderVisits({@required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: 'Provider Visits',
        theme: Theme.of(context),
      ),
      body: StreamBuilder(
          stream: model.consultStream.stream,
          builder: (BuildContext context,
              AsyncSnapshot<List<Consult>> consultSnapshot) {
            return ListItemsBuilder<Consult>(
              scrollable: true,
              snapshot: consultSnapshot,
              emptyContentWidget: EmptyContent(
                title: "You do not have any patient visits yet",
                message: "",
              ),
              itemBuilder: (context, consult) => ProviderVisitsListItem(
                consult: consult,
                onTap: () => navigateToChatScreen(context, consult),
              ),
            );
          }),
    );
  }

  void navigateToChatScreen(BuildContext context, Consult consult) async {
    if (consult.state == ConsultStatus.Signed) {
      if (!model.isLoading) {
        model.updateWith(isLoading: true);
        ChatProvider chatProvider =
            Provider.of<ChatProvider>(context, listen: false);
        UserProvider userProvider =
            Provider.of<UserProvider>(context, listen: false);

        final channel =
            chatProvider.client.channel('messaging', id: consult.uid);

        await chatProvider.setUser(userProvider.user);

        await channel.watch();

        model.updateWith(isLoading: false);
        ChatScreen.show(context: context, channel: channel);
      }
    } else {
      AppUtil().showFlushBar(
          "You can only chat when you sign this consult", context);
    }
  }

  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.providerVisits,
    );
  }

  static Widget create(BuildContext context) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider<ProviderVisitsViewModel>(
      create: (context) => ProviderVisitsViewModel(
        database: database,
        userProvider: provider,
      ),
      child: Consumer<ProviderVisitsViewModel>(
        builder: (_, model, __) => ProviderVisits(
          model: model,
        ),
      ),
    );
  }
}
