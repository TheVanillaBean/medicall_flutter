import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './tabs/dashboard.dart' as _dashboard;
import './screens/doctors.dart' as _doctorsPage;
import './screens/chat.dart' as _chatPage;
import './screens/history.dart' as _historyPage;
import './screens/settings.dart' as _settingsPage;
import './presentation/medicall_app_icons.dart' as CustomIcons;

void main() => runApp(new MaterialApp(
  title: 'Medicall',
  theme: new ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.blue, backgroundColor: Colors.white
  ),
  home: new Tabs(),
  onGenerateRoute: (RouteSettings settings) {
    switch (settings.name) {
      case '/doctors': return new FromRightToLeft(
        builder: (_) => new _doctorsPage.Doctors(),
        settings: settings,
      );
      case '/chat': return new FromRightToLeft(
        builder: (_) => new _chatPage.Chat(),
        settings: settings,
      );
      case '/history': return new FromRightToLeft(
        builder: (_) => new _historyPage.History(),
        settings: settings,
      );
      case '/settings': return new FromRightToLeft(
        builder: (_) => new _settingsPage.Settings(),
        settings: settings,
      );
    }
  },
  // routes: <String, WidgetBuilder> {
  //   '/about': (BuildContext context) => new _aboutPage.About(),
  // }
));

class FromRightToLeft<T> extends MaterialPageRoute<T> {
  FromRightToLeft({ WidgetBuilder builder, RouteSettings settings })
    : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {

    if (settings.isInitialRoute)
      return child;

    return new SlideTransition(
      child: new Container(
        decoration: new BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: Colors.black26,
              blurRadius: 25.0,
            )
          ]
        ),
        child: child,
      ),
      position: new Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      )
      .animate(
        new CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        )
      ),
    );
  }
  @override Duration get transitionDuration => const Duration(milliseconds: 400);
}

class Tabs extends StatefulWidget {
  @override
  TabsState createState() => new TabsState();
}

class TabsState extends State<Tabs> {
  
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
  void dispose(){
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build (BuildContext context) => new Scaffold(

    //App Bar
    appBar: new AppBar(
      centerTitle: true,
      title: new Text(
        _title_app,
        style: new TextStyle(
          fontSize: Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
        ),
      ),
      elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      leading: Builder(builder: (BuildContext context) {
      return new GestureDetector(
        onTap: (){
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
            height: 120.0,
            child: new DrawerHeader(
              padding: new EdgeInsets.all(0.0),
              decoration: new BoxDecoration(
                color: Colors.lightBlue[50],
              ),
              child: new Center(
                child: new Icon(
                  CustomIcons.MedicallApp.logo, 
                  size: 60.0,
                  color: Colors.lightBlueAccent),
              ),
            ),
          ),
          new ListTile(
            leading: new Icon(Icons.local_hospital),
            title: new Text('Doctors'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/doctors');
            }
          ),
          new ListTile(
            leading: new Icon(Icons.chat),
            title: new Text('Chat'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/chat');
            }
          ),
          new ListTile(
            leading: new Icon(Icons.folder_shared),
            title: new Text('History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/history');
            }
          ),
          new ListTile(
            leading: new Icon(Icons.settings_applications),
            title: new Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/settings');
            }
          ),
          new Divider(),
          new ListTile(
            leading: new Icon(Icons.exit_to_app),
            title: new Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
            }
          ),
        ],
      )
    )
  );

}
