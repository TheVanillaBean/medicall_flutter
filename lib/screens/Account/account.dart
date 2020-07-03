import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserProvider _userProvider = Provider.of<UserProvider>(context);
    ExtImageProvider _extImageProvider = Provider.of<ExtImageProvider>(context);

    final User medicallUser = _userProvider.user;

    return Scaffold(
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
        child: _buildChildren(
          medicallUser: medicallUser,
          extImageProvider: _extImageProvider,
          userProvider: _userProvider,
          context: context,
        ),
      ),
    );
  }

  Column _buildChildren({
    User medicallUser,
    ExtImageProvider extImageProvider,
    UserProvider userProvider,
    BuildContext context,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 20),
        _buildAvatarWidget(medicallUser, extImageProvider, userProvider),
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
          userProvider.user.type.toUpperCase(),
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
        _buildEmailCard(medicallUser),
        _buildPhoneCard(medicallUser),
        _buildPaymentMethodsCard(context),
      ],
    );
  }

  Widget _buildPaymentMethodsCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
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
    );
  }

  Widget _buildPhoneCard(User medicallUser) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
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
    );
  }

  Widget _buildEmailCard(User medicallUser) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
      child: ListTile(
        enabled: false,
        title: Text(
          medicallUser.email,
          style: TextStyle(color: Colors.grey),
        ),
        leading: Icon(Icons.email, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _buildAvatarWidget(User medicallUser,
      ExtImageProvider extImageProvider, UserProvider userProvider) {
    return Flexible(
      child: Container(
        width: 200.0,
        height: 200.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black12,
            width: 1.0,
          ),
        ),
        child: ClipOval(
          child: _buildAvatar(
            medicallUser,
            extImageProvider,
            userProvider,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(User medicallUser, ExtImageProvider _extImageProvider,
      UserProvider _userProvider) {
    return medicallUser != null && medicallUser.profilePic.length > 0
        ? _extImageProvider.returnNetworkImage(_userProvider.user.profilePic,
            fit: BoxFit.cover, cache: true)
        : Icon(
            Icons.account_circle,
            color: Colors.grey[200],
            size: 200,
          );
  }
}
