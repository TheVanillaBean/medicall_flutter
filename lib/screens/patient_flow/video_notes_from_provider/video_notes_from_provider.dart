import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/video_notes_from_provider/video_notes_from_provider_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoNotesFromProvider extends StatelessWidget {
  final VideoNotesFromProviderViewModel model;

  const VideoNotesFromProvider({@required this.model});

  static Widget create(BuildContext context) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider<VideoNotesFromProviderViewModel>(
      create: (context) => VideoNotesFromProviderViewModel(
        database: database,
        userProvider: provider,
      ),
      child: Consumer<VideoNotesFromProviderViewModel>(
        builder: (_, model, __) => VideoNotesFromProvider(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.videoNotesFromProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Video Notes From Provider",
          theme: Theme.of(context),
        ),
        body: Column(
          children: [
            _buildVideoNotesCardButton(
              context,
              'Recorded on:',
              'Nov 6, 2020, 2:30p',
              null,
            ),
            SizedBox(height: 20),
          ],
        ));
  }

  Widget _buildVideoNotesCardButton(
      BuildContext context, String title, String subtitle, Function onTap) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Card(
        elevation: 2,
        borderOnForeground: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(15, 5, 5, 5),
          dense: true,
          leading: SizedBox(
            height: 50,
            width: 50,
            child: Image.network('https://picsum.photos/250?image=9'),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.caption,
          ),
          trailing: Icon(
            Icons.play_arrow_rounded,
            size: 50,
            color: Colors.teal,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
