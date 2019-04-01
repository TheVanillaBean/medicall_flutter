import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../tabs/dashboard.dart' as _dashboard;
import '../../presentation/medicall_app_icons.dart' as CustomIcons;


class Dashboard extends StatefulWidget {
  @override
  TabsState createState() => new TabsState();
}

class TabsState extends State<Dashboard> {
  PageController _tabController;

  var _title_app = null;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = new PageController();
    this._title_app = 'Welcome to Medicall!';
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(

      //App Bar
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(
          _title_app,
          style: new TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        leading: Builder(builder: (BuildContext context) {
          return new GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: new Container(
              child: new Icon(
                CustomIcons.MedicallApp.logo_m,
                size: 35.0,
              ),
            ),
          );
        }),
      ),

      //Content of tabs
      body: new PageView(
        // controller: _tabController,
        // onPageChanged: onTabChanged,
        children: <Widget>[
          new _dashboard.Dashboard(),
        ],
      ),

      //Tabs
      // bottomNavigationBar: Theme.of(context).platform == TargetPlatform.iOS ?
      //   new CupertinoTabBar(
      //     activeColor: Colors.deepOrange,
      //     currentIndex: _tab,
      //     onTap: onTap,
      //     items: TabItems.map((TabItem) {
      //       return new BottomNavigationBarItem(
      //         title: new Text(TabItem.title),
      //         icon: new Icon(TabItem.icon),
      //       );
      //     }).toList(),
      //   ):
      //   new BottomNavigationBar(
      //     currentIndex: _tab,
      //     onTap: onTap,
      //     items: TabItems.map((TabItem) {
      //       return new BottomNavigationBarItem(
      //         title: new Text(TabItem.title),
      //         icon: new Icon(TabItem.icon),
      //       );
      //     }).toList(),
      // ),

      //Drawer
      drawer: new Drawer(
          child: new ListView(
        children: <Widget>[
          new Container(
            height: 64.0,
            child: new DrawerHeader(
                padding: new EdgeInsets.all(0.0),
                decoration: new BoxDecoration(
                  color: Colors.lightBlue[50],
                ),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      flex: 1,
                      child: new Icon(CustomIcons.MedicallApp.logo,
                          size: 45.0, color: Colors.lightBlueAccent),
                    ),
                    new Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                        child: new Text('Medicall',
                            style: TextStyle(
                                fontSize: 24.0,
                                letterSpacing: 1.5,
                                color:
                                    new Color.fromARGB(1000, 241, 100, 119))),
                      ),
                    )
                  ],
                )),
          ),
          new ListTile(
              leading: new Icon(Icons.local_hospital),
              title: new Text('Doctors'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/doctors');
              }),
          new ListTile(
              leading: new Icon(Icons.chat),
              title: new Text('Chat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/chat');
              }),
          new ListTile(
              leading: new Icon(Icons.folder_shared),
              title: new Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/history');
              }),
          new ListTile(
              leading: new Icon(Icons.settings_applications),
              title: new Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/settings');
              }),
          new Divider(),
          new ListTile(
              leading: new Icon(Icons.exit_to_app),
              title: new Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
              }),
        ],
      )));
}
