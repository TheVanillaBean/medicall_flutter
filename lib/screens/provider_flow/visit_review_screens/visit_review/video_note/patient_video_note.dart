import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/video_note/patient_video_note_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../visit_review_view_model.dart';

class PatientVideoNote extends StatefulWidget {
  final PatientVideoNoteViewModel model;
  const PatientVideoNote({@required this.model});

  static Widget create(
    BuildContext context,
    VisitReviewViewModel visitReviewViewModel,
  ) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider<PatientVideoNoteViewModel>(
      create: (context) => PatientVideoNoteViewModel(
        database: database,
        userProvider: provider,
      ),
      child: Consumer<PatientVideoNoteViewModel>(
        builder: (_, model, __) => PatientVideoNote(model: model),
      ),
    );
  }

  @override
  _PatientVideoNoteState createState() => _PatientVideoNoteState();

  static Future<void> show({
    BuildContext context,
    VisitReviewViewModel visitReviewViewModel,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.patientVideoNote,
      arguments: {
        'visitReviewViewModel': visitReviewViewModel,
      },
    );
  }
}

class _PatientVideoNoteState extends State<PatientVideoNote> {
  bool _isRecording = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Provider Video Notes",
          theme: Theme.of(context),
        ),
        body: Column(
          children: [
            _buildProviderCardButton(
              context,
              'Recorded on:',
              'Nov 6, 2020, 2:30p',
              null,
            ),
            SizedBox(height: 50),
            Center(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _isRecording = !_isRecording;
                  });
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 5.0, color: Colors.black12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      child: Container(
                        decoration: new BoxDecoration(
                          color: Colors.red,
                          shape: _isRecording
                              ? BoxShape.rectangle
                              : BoxShape.circle,
                          borderRadius: _isRecording
                              ? BorderRadius.all(Radius.circular(8.0))
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildProviderCardButton(
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
