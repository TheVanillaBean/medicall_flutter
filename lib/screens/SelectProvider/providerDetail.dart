import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProviderDetailScreen extends StatelessWidget {
  const ProviderDetailScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    Database db = Provider.of<Database>(context, listen: false);
    Auth auth = Provider.of<AuthBase>(context, listen: false);
    ScreenUtil.init(context);
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
            db.newConsult.providerTitles + ' ' + db.newConsult.provider,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            height:
                ScreenUtil.screenHeightDp - (ScreenUtil.statusBarHeight + 50),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50.0,
                        backgroundImage:
                            NetworkImage("${db.newConsult.providerProfilePic}"),
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Dermatologist',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Container(
                          alignment: Alignment.center,
                          width: 150,
                          child: Text(
                            db.newConsult.providerAddress,
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          )),
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
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: FlatButton(
                      onPressed: () {
                        // Navigator.of(context).pushNamed(
                        //   '/selectProvider',
                        // );
                        if (userProvider.medicallUser != null) {
                          auth.addUserToAuthStream(
                              user: userProvider.medicallUser);
                        } else {
                          Navigator.of(context).pushNamed(
                            '/registration',
                          );
                        }
                      },
                      color: Colors.blue,
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: Text(
                        'Start Visit',
                        style: TextStyle(fontSize: 14),
                      )),
                )
              ],
            ),
          ),
        ));
  }
}
