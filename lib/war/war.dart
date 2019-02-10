import 'package:flutter/material.dart';
import 'package:zd112_flutter/view/BannerView.dart';
import 'package:zd112_flutter/view/banner/Pair.dart';
import 'package:zd112_flutter/view/banner/factory/BannerItemFactory.dart';
import 'dart:ui';

import 'package:flutter_framework/flutter_framework.dart';
import 'package:flutter_framework/view/refresh/space_header.dart';
import 'package:flutter_framework/view/refresh/space_footer.dart';
import 'detail.dart';

class War extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SpacePageState();
}

class War1 extends StatelessWidget{
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      body: new Container(
//        child: Column(
//          children: <Widget>[
//            Scaffold(
//              body: this._bannerView(),
//            ),
//          ],
//        ),
//      ),
//    );
//  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      ///卡片包装
      child: new Card(
        ///增加点击效果
          child: new FlatButton(
              onPressed: (){
//                print("点击了哦");
              Navigator.push(context, Router(widget:Detail()));
              print('----jsd');
              },
              child: new Padding(
                padding: new EdgeInsets.only(left: 0.0, top: 10.0, right: 10.0, bottom: 10.0),
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ///文本描述
                    new Container(
                        child: new Text(
                          "这是一点描述",
                          style: TextStyle(
//                            color: Color(GSYColors.subTextColor),
                            fontSize: 14.0,
                          ),
                          ///最长三行，超过 ... 显示
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
                        alignment: Alignment.topLeft),
                    new Padding(padding: EdgeInsets.all(10.0)),

                    ///三个平均分配的横向图标文字
                    new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _getBottomItem(Icons.star, "1000"),
                        _getBottomItem(Icons.link, "1000"),
                        _getBottomItem(Icons.subject, "1000"),
                      ],
                    ),
                  ],
                ),
              ))),
    );
  }

  ///返回一个居中带图标和文本的Item
  _getBottomItem(IconData icon, String text) {
    ///充满 Row 横向的布局
    return new Expanded(
      flex: 1,
      ///居中显示
      child: new Center(
        ///横向布局
        child: new Row(
          ///主轴居中,即是横向居中
          mainAxisAlignment: MainAxisAlignment.center,
          ///大小按照最大充满
          mainAxisSize : MainAxisSize.max,
          ///竖向也居中
          crossAxisAlignment : CrossAxisAlignment.center,
          children: <Widget>[
            ///一个图标，大小16.0，灰色
            new Icon(
              icon,
              size: 16.0,
              color: Colors.grey,
            ),
            ///间隔
            new Padding(padding: new EdgeInsets.only(left:5.0)),
            ///显示文本
            new Text(
              text,
              //设置字体样式：颜色灰色，字体大小14.0
              style: new TextStyle(color: Colors.grey, fontSize: 14.0),
              //超过的省略为...显示
              overflow: TextOverflow.ellipsis,
              //最长一行
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  BannerView _bannerView() {
    var pre = 'https://raw.githubusercontent.com/yangxiaoweihn/Assets/master';
    List<Pair<String, Color>> param = [
      Pair.create('$pre/cars/car_0.jpg', Colors.red[100]),
      Pair.create('$pre/cartoons/ct_0.jpg', Colors.green[100]),
      Pair.create('$pre/pets/cat_1.jpg', Colors.blue[100]),
      Pair.create('$pre/scenery/s_1.jpg', Colors.yellow[100]),
      Pair.create('$pre/cartoons/ct_1.jpg', Colors.red[100]),
    ];

    return BannerView(
      BannerItemFactory.banners(param),
      cycleRolling: true,
      autoRolling: true,
      indicatorMargin: 12.0,
      indicatorNormal: this._indicatorItem(Colors.white),
      indicatorSelected: this._indicatorItem(Colors.white, selected: true),
      indicatorBuilder: (context, indicator) {
        return this._indicatorContainer(indicator);
      },
    );
  }

  Widget _indicatorContainer(Widget indicator) {

    var container = Container(
      height: 64.0,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: 0.5,
            child: Container(
              color: Colors.pink[300],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: indicator,
          ),
        ],
      ),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: container,
    );
  }

  Widget _indicatorItem(Color color, {bool selected = false}) {

    double size = selected ? 10.0 : 6.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
    );
  }
}

class _SpacePageState extends State<War> {

  List<String> addStr=["1","2","3","4","5","6","7","8","9","0"];
  List<String> str=["1","2","3","4","5","6","7","8","9","0"];
  GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Space"),
      ),
      body: Center(
          child: new EasyRefresh(
            key: _easyRefreshKey,
            refreshHeader: SpaceHeader(
              key: _headerKey,
            ),
            refreshFooter: SpaceFooter(
              key: _footerKey,
              loadHeight: 150.0,
            ),
            child:new ListView.builder(
              //ListView的Item
                itemCount: str.length,
                itemBuilder: (BuildContext context,int index){
                  return DemoItem();
                }
            ),
            onRefresh: () async{
              await new Future.delayed(const Duration(seconds: 3), () {
                if (!mounted) return;
                setState(() {
                  str.clear();
                  str.addAll(addStr);
                });
              });
            },
            loadMore: () async {
              await new Future.delayed(const Duration(seconds: 1), () {
                if (str.length < 20) {
                  if (!mounted) return;
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


class DemoItem extends StatelessWidget {

  DemoItem() : super();

  ///返回一个居中带图标和文本的Item
  _getBottomItem(IconData icon, String text) {
    ///充满 Row 横向的布局
    return new Expanded(
      flex: 1,

      ///居中显示
      child: new Center(
        ///横向布局
        child: new Row(
          ///主轴居中,即是横向居中
          mainAxisAlignment: MainAxisAlignment.center,

          ///大小按照最大充满
          mainAxisSize: MainAxisSize.max,

          ///竖向也居中
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ///一个星星图标
            new Icon(
              icon,
              size: 16.0,
              color: Colors.grey,
            ),

            ///间隔
            new Padding(padding: new EdgeInsets.all(5.0)),

            ///显示数量文本
            new Text(
              text,
              style: new TextStyle(color: Colors.grey, fontSize: 14.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      ///卡片包装
      child: new Card(
        ///增加点击效果
          child: new FlatButton(
              onPressed: (){print("点击了哦");
                Navigator.push(context, Router(widget: Detail()));
              },
              child: new Padding(
                padding: new EdgeInsets.only(left: 0.0, top: 10.0, right: 10.0, bottom: 10.0),
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ///文本描述
                    new Container(
                        child: new Text(
                          "这是一点描述",
                          style: TextStyle(
//                            color: Color(GSYColors.subTextColor),
                            fontSize: 14.0,
                          ),
                          ///最长三行，超过 ... 显示
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
                        alignment: Alignment.topLeft),
                    new Padding(padding: EdgeInsets.all(10.0)),

                    ///三个平均分配的横向图标文字
                    new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _getBottomItem(Icons.star, "1000"),
                        _getBottomItem(Icons.link, "1000"),
                        _getBottomItem(Icons.subject, "1000"),
                      ],
                    ),
                  ],
                ),
              ))),
    );
  }
}