import 'package:flutter/material.dart';
import 'package:medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:medicall/models/providers_model.dart';

class SelectProviderScreen extends StatefulWidget {
  @override
  _SelectProviderScreenState createState() => _SelectProviderScreenState();
}

class _SelectProviderScreenState extends State<SelectProviderScreen> {
  Providers _providers = Providers(providers: [
    Provider(
        prefix: 'Dr.',
        firstName: 'Layla',
        lastName: 'Smith',
        address: '2131 S Sunset Dr California 82934',
        rating: '5'),
  ]);
  _providerBuilder(context, index) {
    final item = _providers.providers[index];
    
    if (item.firstName != '') {
       return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 6.0),
                  child: Text(
                    item.prefix + ' ' + item.firstName + ' ' + item.lastName,
                    style: TextStyle(
                        fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(5.0, 6.0, 5.0, 5.0),
                  child: Text(
                    item.address,
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "5m",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.star_border,
                      size: 35.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(
          height: 2.0,
          color: Colors.grey,
        )
      ],
    );
    }
  }

  _buildProviders(context) {
    return ListView.builder(
      // Let the ListView know how many items it needs to build
      itemCount: _providers.providers.length,
      // Provide a builder function. This is where the magic happens! We'll
      // convert each item into a Widget based on the type of item it is.
      itemBuilder: (context, index) => _providerBuilder(context, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color.fromRGBO(35, 179, 232, 1),
          title: new Text(
            'Select Provider',
            style: new TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: new FlatButton(
          padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
          color: Color.fromRGBO(35, 179, 232, 1),
          onPressed: () => Navigator.pushNamed(context, '/questionsHistory'), // Switch tabs

          child: Text(
            'CONTINUE',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        body: new Container(
          child: _buildProviders(context),
        ),
      );
  }
}
