import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/routing/router.dart';
import 'package:flutter/material.dart';

class VisitDetailsOverview extends StatelessWidget {
  final String consultId;

  const VisitDetailsOverview({@required this.consultId});

  static Future<void> show({
    BuildContext context,
    String consultId,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitDetailsOverview,
      arguments: {
        'consultId': consultId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back, title: "Visit Overview"),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildCardButton("Review Information", Icons.assignment, () => {}),
            _buildCardButton("Prescriptions", Icons.local_pharmacy, () => {}),
            _buildCardButton("Doctor Note", Icons.note, () => {}),
            _buildCardButton("Educational Content", Icons.smartphone, () => {}),
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
          contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          dense: true,
          leading: Icon(
            icon,
            size: 40,
            color: Colors.grey,
          ),
          title: Text(title),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 15.0,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
