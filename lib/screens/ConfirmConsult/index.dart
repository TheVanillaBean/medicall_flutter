import 'package:Medicall/screens/QuestionsUpload/asset_view.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/globals.dart' as globals;
import 'package:multi_image_picker/multi_image_picker.dart';

class ConfirmConsultScreen extends StatefulWidget {
  final globals.ConsultData data;

  const ConfirmConsultScreen({Key key, @required this.data}) : super(key: key);
  @override
  _ConfirmConsultScreenState createState() => _ConfirmConsultScreenState();
}

class _ConfirmConsultScreenState extends State<ConfirmConsultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Consult Review',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/history', arguments: widget.data);
        },
        //Navigator.pushNamed(context, '/history'), // Switch tabs
        child: Text(
          'SUBMIT',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              child: Text(
            widget.data.consultType,
            style: Theme.of(context).textTheme.headline,
          )),
          Container(child: Text(widget.data.provider)),
          Expanded(
            flex: 4,
            child: ListView.builder(
              itemCount: widget.data.screeningQuestions.length,
              itemBuilder: (context, index) {
                final item = widget.data.screeningQuestions[index];
                return ListTile(
                  title: Text(
                    item,
                  ),
                );
              },
            ),
          ),
          Container(
            height: 112,
            decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.secondaryVariant)),
            child: GridView.count(
                crossAxisCount: 4,
                padding: EdgeInsets.all(10),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: List.generate(widget.data.media.length, (index) {
                  //var data = globals.ConsultData;
                  Asset asset = widget.data.media[index];
                  return AssetView(
                    index,
                    asset,
                  );
                })),
          ),
          Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(border: Border.all()),
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: ListView.builder(
                  itemCount: widget.data.historyQuestions.length,
                  itemBuilder: (context, index) {
                    final item = widget.data.historyQuestions[index];
                    return ListTile(
                      title: Text(
                        item,
                      ),
                    );
                  },
                ),
              )),
        ],
      ),

      // Container(
      //   margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
      //   child: GridView.count(
      //       crossAxisCount: 4,
      //       padding: EdgeInsets.all(10),
      //       crossAxisSpacing: 10,
      //       mainAxisSpacing: 10,
      //       children: List.generate(widget.data.media.length, (index) {
      //         //var data = globals.ConsultData;
      //         Asset asset = widget.data.media[index];
      //         return AssetView(
      //           index,
      //           asset,
      //         );
      //       })),
      // ),
      // Container(
      //   decoration: BoxDecoration(border: Border.all()),
      //   height: 300,
      //   margin: EdgeInsets.fromLTRB(10, 220, 10, 10),
      //   child:
      // ),
    );
  }
}
