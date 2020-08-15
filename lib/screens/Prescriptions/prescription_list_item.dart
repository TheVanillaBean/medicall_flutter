import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:flutter/material.dart';

class PrescriptionListItem extends StatelessWidget {
  final TreatmentOptions treatment;

  const PrescriptionListItem({Key key, this.treatment}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Card(
        elevation: 2,
        borderOnForeground: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          dense: true,
          title: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '${treatment.medicationName}',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.left,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: IntrinsicHeight(
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${treatment.quantity}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                      VerticalDivider(thickness: 2, color: Colors.grey[300]),
                      Text(
                        'Refills: ${treatment.refills}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                      VerticalDivider(thickness: 2, color: Colors.grey[300]),
                      Text(
                        '${treatment.dose} ',
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Flexible(
                        child: Text(
                          '${treatment.form.toLowerCase()}',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Divider(
                thickness: 1,
              ),
              Text(
                'Instructions: ${treatment.instructions}',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
          onTap: null,
        ),
      ),
    );
  }
}
