import 'package:flutter/material.dart';
import 'package:flutter_framework/flutter_framework.dart';
import 'package:flutter_framework/view/refresh/bezier_circle_header.dart';
import 'package:flutter_framework/view/refresh/bezier_bounce_footer.dart';

class Learn extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _BezierCirclePageState();
}

class LearnTab extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.green,
      body: new Container(
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(
                Icons.adb,
                size: 160.0,
                color: Colors.white,
              ),
              new Text(
                "Second Tab",
                style: new TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _BezierCirclePageState extends State<Learn> {

  List<String> addStr=["1","2","3","4","5","6","7","8","9","0"];
  List<String> str=["1","2","3","4","5","6","7","8","9","0"];
  GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BezierCircle"),
      ),
      body: Center(
          child: new EasyRefresh(
            key: _easyRefreshKey,
            refreshHeader: BezierCircleHeader(
              key: _headerKey,
            ),
            refreshFooter: BezierBounceFooter(
              key: _footerKey,
            ),
            child: new ListView.builder(
              //ListView的Item
                itemCount: str.length,
                itemBuilder: (BuildContext context,int index){
                  return new Container(
                      height: 70.0,
                      child: Card(
                        child: new Center(
                          child: new Text(str[index],style: new TextStyle(fontSize: 18.0),),
                        ),
                      )
                  );
                }
            ),
            onRefresh: () async{
              await new Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  str.clear();
                  str.addAll(addStr);
                });
              });
            },
            loadMore: () async {
              await new Future.delayed(const Duration(seconds: 1), () {
                if (str.length < 20) {
                  setState(() {
                    str.addAll(addStr);
                  });
                }
              });
            },
          )
      ),
    );
  }
}