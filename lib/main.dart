import 'package:flutter/material.dart';
import 'package:zd112_flutter/base/splash.dart';
import 'package:zd112_flutter/base/guide.dart';
import 'package:zd112_flutter/war/war.dart';
import 'package:zd112_flutter/learn/learn.dart';
import 'package:zd112_flutter/ask/ask.dart';
import 'package:zd112_flutter/mine/mine.dart';
import 'package:flutter_framework/bar/bar.dart' as tb;
import 'package:flutter_framework/bar/bar_item.dart';
import 'base/application.dart';
import 'base/translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main(){
  runApp(MyApp());
  if(Platform.isAndroid){//设置android状态栏为透明的沉浸
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

}

class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Guide(),
    );
  }
}

class MyTab extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => MyTabState();
}

class MyTabState extends State<MyTab> with SingleTickerProviderStateMixin{
  SpecificLocalizationDelegate _localizationDelegate;

  TabController tabController;
  int _selectedIndex = 0;
  String badgeNo;
  var titles = ['战斗','学学','问问','我的'];
  var icons=[Icons.security, Icons.school, Icons.sms, Icons.supervisor_account];

  var tabs = [War(),Learn(),Ask(),MineTab()];

  @override
  void initState() {
    super.initState();
    _localizationDelegate = SpecificLocalizationDelegate(null);
    application.onLocaleChanged = onLocaleChange;

    tabController = TabController(length: titles.length, vsync: this,initialIndex: 1);
    badgeNo = '1';
  }

  onLocaleChange(Locale locale){
    setState(() {
      _localizationDelegate = SpecificLocalizationDelegate(locale);
    });
  }

  void _onItemSelected(index){
    setState(() {
      _selectedIndex = index;
      badgeNo='';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text('Bottom Tab Bar'),
//        actions: <Widget>[new Icon(Icons.photo_camera)],
//      ),
//      drawer: _,
//      floatingActionButtonAnimator: FloatingActionButton.extended(onPressed: null, icon: null, label: null),
      bottomNavigationBar: tb.TabBar(
        items: [
          TabBarItem(icon: Icon(icons[0]),title: Text(titles[0]),badgeNo: badgeNo),
          TabBarItem(icon: Icon(icons[1]), title: Text(titles[1])),
          TabBarItem(icon: Icon(icons[2]), title: Text(titles[2]),badgeNo: '8'),
          TabBarItem(icon: Icon(icons[3]),activeIcon: Icon(icons[3]),title: Text(titles[3])),
        ],
        fixedColor: Colors.orange,
        currentIndex: _selectedIndex,
        onTap: _onItemSelected,
        type: tb.TabBarType.fixed,
        isAnimation: true,
        isInkResponse: true,
        badgeColor: Colors.red,
      ),
      body: Center(
        child: tabs[_selectedIndex],
      ),
    );
  }
}