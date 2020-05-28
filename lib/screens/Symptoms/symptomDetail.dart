import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SymptomDetailScreen extends StatelessWidget {
  const SymptomDetailScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Database db = Provider.of<Database>(context);
    MedicallUser medicallUser = Provider.of<UserProvider>(context).medicallUser;
    return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
              );
            },
          ),
          centerTitle: true,
          title: Text(
            db.newConsult.consultType + ' Visit',
          ),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(40, 40, 40, 40),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text(
                      'Price',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Container(
                    child: Text(
                      db.newConsult.price,
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                ],
              ),
              SizedBox(height: 30),
              Container(
                child: Text(
                  db.newConsult.desc,
                  style: TextStyle(
                    height: 1.6,
                    fontSize: 14,
                    letterSpacing: 0.6,
                    wordSpacing: 1,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        title: Text(
                          "Prescriptions Information",
                          style: TextStyle(color: Colors.blue),
                        ),
                        content: Text(
                          "If a prescription is prescribed, we can send it to your local pharmacy or you can use our prescription service and have your medications delivered to your door with free 2-day shipping. Our prices are lower than most co-pays. Typical medications that are prescribed for hair loss include:",
                          style: TextStyle(fontSize: 12, height: 1.5),
                        ),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          FlatButton(
                            child: Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Text(
                    'Common medications',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ),
              SizedBox(height: 80),
              FlatButton(
                  onPressed: () {
                    // Navigator.of(context).pushNamed(
                    //   '/selectProvider',
                    // );
                    if (medicallUser.uid.length > 0) {
                      Navigator.of(context).pushNamed(
                        '/selectProvider',
                      );
                    } else {
                      Navigator.of(context).pushNamed(
                        '/zipCodeVerify',
                      );
                    }
                  },
                  color: Colors.blue,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0)),
                  child: Text(
                    'Explore Providers',
                    style: TextStyle(fontSize: 14),
                  ))
            ],
          ),
        ));
  }
}
