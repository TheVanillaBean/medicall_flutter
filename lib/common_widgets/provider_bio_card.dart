import 'package:flutter/material.dart';

class ProviderBioCard extends StatelessWidget {
  final String leading;
  final IconButton trailing;
  final String bioText;
  final VoidCallback onTap;

  const ProviderBioCard({
    @required this.leading,
    @required this.bioText,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 5),
            dense: true,
            leading: Text(
              leading ?? '',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: trailing,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
            child: Text(
              bioText ??
                  'Please add a short bio to your profile. '
                      'Highlighting your specialized areas and qualifications '
                      '(including education, board certification, published works, and years of experience) '
                      'imparts professionalism and helps prospective patients feel more confident choosing '
                      'you as their provider.',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          )
        ],
      ),
    );
  }
}
