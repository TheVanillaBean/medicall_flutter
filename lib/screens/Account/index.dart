import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserProvider _userProvider;
    ExtImageProvider _extImageProvider;
    _userProvider = Provider.of<UserProvider>(context);
    _extImageProvider = Provider.of<ExtImageProvider>(context);
    final MedicallUser medicallUser = _userProvider.medicallUser;

    return Scaffold(
      //App Bar
      appBar: AppBar(
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.home,
                color: Colors.grey,
              ),
            );
          },
        ),
        title: Text(
          'Account',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
      ),
      drawer: DrawerMenu(),
      //Content of tabs
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            CircleAvatar(
              backgroundColor: Colors.grey[50],
              radius: 80.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: _buildAvatar(
                  medicallUser,
                  _extImageProvider,
                  _userProvider,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              medicallUser.displayName,
              style: TextStyle(
                fontFamily: 'SourceSansPro',
                fontSize: 30.0,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _userProvider.medicallUser.type.toUpperCase(),
              style: TextStyle(
                fontFamily: 'SourceSansPro',
                fontSize: 16.0,
                letterSpacing: 2.5,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
              width: 150,
              child: Divider(
                color: Colors.grey[300],
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
              child: ListTile(
                enabled: false,
                title: Text(
                  medicallUser.email,
                  style: TextStyle(color: Colors.grey),
                ),
                leading: Icon(Icons.email, color: Colors.grey),
                onTap: () {},
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
              child: ListTile(
                enabled: false,
                title: Text(medicallUser.phoneNumber != null
                    ? medicallUser.phoneNumber
                    : '(xxx)xxx-xxxx'),
                leading: Icon(
                  Icons.phone,
                  color: Colors.grey,
                ),
                onTap: () {},
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
              child: ListTile(
                title: Text(
                  'Payment Cards',
                  style: TextStyle(color: Colors.grey),
                ),
                leading: Icon(
                  Icons.payment,
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.of(context).pushNamed('/paymentDetail');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(MedicallUser medicallUser,
      ExtImageProvider _extImageProvider, UserProvider _userProvider) {
    return medicallUser != null && medicallUser.profilePic.length > 0
        ? _extImageProvider.returnNetworkImage(
            _userProvider.medicallUser.profilePic,
            fit: BoxFit.cover,
            cache: true)
        : Icon(
            Icons.account_circle,
            color: Colors.grey[300],
            size: 150,
          );
  }
}
