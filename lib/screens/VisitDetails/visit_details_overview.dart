import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart';
import 'package:Medicall/routing/router.dart';
import 'package:intl/intl.dart';
import 'package:Medicall/screens/ConsultReview/review_visit_information.dart';
import 'package:Medicall/screens/VisitDetails/visit_doc_note.dart';
import 'package:Medicall/screens/VisitDetails/visit_education.dart';
import 'package:flutter/material.dart';

class VisitDetailsOverview extends StatelessWidget {
  final Consult consult;

  const VisitDetailsOverview({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitDetailsOverview,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: consult.symptom + ' visit',
        subtitle: 'with ' +
            consult.providerUser.titles +
            ' ' +
            consult.providerUser.fullName +
            ' on ' +
            DateFormat('MM-dd-yyyy').format(consult.date).toString(),
        theme: Theme.of(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildCardButton(
                "Review Information",
                Icons.assignment,
                () => {
                      ReviewVisitInformation.show(
                        context: context,
                        consult: consult,
                      )
                    }),
            _buildCardButton("Prescriptions", Icons.local_pharmacy, () => {}),
            _buildCardButton(
                "Doctor Note",
                MedicallIcons.clipboard_1,
                () => {
                      VisitDocNote.show(
                        context: context,
                        consult: consult,
                      )
                    }),
            _buildCardButton(
                "Education",
                Icons.school,
                () => {
                      VisitEducation.show(
                        context: context,
                        consult: consult,
                      )
                    }),
            _buildCardButton("Message Doctor", Icons.message, () => {}),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton(String title, IconData icon, Function onTap) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Card(
        elevation: 3,
        shadowColor: Colors.grey.withAlpha(120),
        borderOnForeground: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          dense: true,
          leading: Icon(
            icon,
            size: 25,
            color: Colors.grey,
          ),
          title: Text(title),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
