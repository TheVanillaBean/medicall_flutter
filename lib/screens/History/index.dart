import 'package:flutter/material.dart';
import 'package:medicall/components/DrawerMenu.dart';
import '../../presentation/medicall_app_icons.dart' as CustomIcons;
import '../../globals.dart' as globals;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:medicall/queries/readRepositories.dart' as queries;
import 'package:medicall/mutations/addStar.dart' as mutations;

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(35, 179, 232, 1),
        title: new Text(
          'History',
          style: new TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        leading: new Text('', style: TextStyle(color: Colors.black26)),
      ),
      drawer: new DrawerMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Builder(builder: (BuildContext context) {
        return new FloatingActionButton(
          child: new Icon(
            CustomIcons.MedicallApp.logo_m,
            size: 35.0,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          backgroundColor: Color.fromRGBO(241, 100, 119, 0.8),
          foregroundColor: Colors.white,
        );
      }),
      body: Query(
        queries.readRepositories,
        pollInterval: 1,
        builder: ({
          bool loading,
          Map data,
          Exception error,
        }) {
          if (error != null) {
            return Text(error.toString());
          }

          if (loading) {
            return Text('Loading');
          }

          // it can be either Map or List
          List repositories = data['viewer']['repositories']['nodes'];

          return ListView.builder(
            itemCount: repositories.length,
            itemBuilder: (context, index) {
              final repository = repositories[index];

              return Mutation(
                mutations.addStar,
                builder: (
                  addStar, {
                  bool loading,
                  Map data,
                  Exception error,
                }) {
                  if (data.isNotEmpty) {
                    repository['viewerHasStarred'] =
                        data['addStar']['starrable']['viewerHasStarred'];
                  }

                  return ListTile(
                    leading: repository['viewerHasStarred']
                        ? const Icon(Icons.star, color: Colors.amber)
                        : const Icon(Icons.star_border),
                    title: Text(repository['name']),
                    // NOTE: optimistic ui updates are not implemented yet, therefore changes may take upto 1 second to show.
                    onTap: () {
                      addStar({
                        'starrableId': repository['id'],
                      });
                    },
                  );
                },
                onCompleted: (Map<String, dynamic> data) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Thanks for your star!'),
                        actions: <Widget>[
                          SimpleDialogOption(
                            child: Text('Dismiss'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
