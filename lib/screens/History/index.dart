import 'package:flutter/material.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:Medicall/globals.dart' as globals;

//import 'package:Medicall/globals.dart' as globals;
// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:Medicall/queries/readRepositories.dart' as queries;
// import 'package:Medicall/mutations/addStar.dart' as mutations;

class HistoryScreen extends StatefulWidget {
  final globals.ConsultData data;

  const HistoryScreen({Key key, @required this.data}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    //Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'History',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        leading: Text('', style: TextStyle(color: Colors.black26)),
      ),
      drawer: DrawerMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          child: Icon(
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
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text(widget.data.consultType),
            subtitle: Text(widget.data.provider),
            trailing: IconButton(
              icon: Icon(Icons.input),
              onPressed: () {},
            ),
            leading: Icon(
              Icons.account_circle,
              size: 50,
            ),
          ),
        ],
      ),
      // body: Query(
      //   queries.readRepositories,
      //   pollInterval: 1,
      //   builder: ({
      //     bool loading,
      //     Map data,
      //     Exception error,
      //   }) {
      //     if (error != null) {
      //       return Text(error.toString());
      //     }

      //     if (loading) {
      //       return Text('Loading');
      //     }

      //     // it can be either Map or List
      //     List repositories = data['viewer']['repositories']['nodes'];

      //     return ListView.builder(
      //       itemCount: repositories.length,
      //       itemBuilder: (context, index) {
      //         final repository = repositories[index];

      //         return Mutation(
      //           mutations.addStar,
      //           builder: (
      //             addStar, {
      //             bool loading,
      //             Map data,
      //             Exception error,
      //           }) {
      //             if (data.isNotEmpty) {
      //               repository['viewerHasStarred'] =
      //                   data['addStar']['starrable']['viewerHasStarred'];
      //             }

      //             return ListTile(
      //               leading: repository['viewerHasStarred']
      //                   ? const Icon(Icons.star, color: Colors.amber)
      //                   : const Icon(Icons.star_border),
      //               title: Text(repository['name']),
      //               // NOTE: optimistic ui updates are not implemented yet, therefore changes may take upto 1 second to show.
      //               onTap: () {
      //                 addStar({
      //                   'starrableId': repository['id'],
      //                 });
      //               },
      //             );
      //           },
      //           onCompleted: (Map<String, dynamic> data) {
      //             showDialog(
      //               context: context,
      //               builder: (BuildContext context) {
      //                 return AlertDialog(
      //                   title: Text('Thanks for your star!'),
      //                   actions: <Widget>[
      //                     SimpleDialogOption(
      //                       child: Text('Dismiss'),
      //                       onPressed: () {
      //                         Navigator.of(context).pop();
      //                       },
      //                     )
      //                   ],
      //                 );
      //               },
      //             );
      //           },
      //         );
      //       },
      //     );
      //   },
      // ),
    );
  }
}
