import 'package:flutter/material.dart';

class Detail extends StatefulWidget {
  Detail({Key key}) : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<Detail> {
  int _currentPageIndex = 0;
  var _pageController = new PageController(initialPage: 0);

  void _pageChange(int index) {
    setState(() {
      if (_currentPageIndex != index) {
        _currentPageIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("书籍管理"),
        centerTitle: true,
      ),
      body: new PageView.builder(
        onPageChanged:_pageChange,
        controller: _pageController,
        itemBuilder: (BuildContext context,int index){
          return index==1?new Text("我是第一页"):new Text("我是其他页面");
        },
        itemCount: 2,

      ),
      bottomNavigationBar: new BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: new Icon(Icons.category), title: new Text("功能")),
          BottomNavigationBarItem(
              icon: new Icon(Icons.message), title: new Text("待办")),
        ],
        currentIndex: _currentPageIndex,
        onTap: (int index){
          //_pageController.jumpToPage(index); 没有动画的页面切换
          _pageController.animateToPage(index, duration: new Duration(seconds: 2),curve:new ElasticOutCurve(0.8));
          _pageChange(index);
        },
      ),
    );
  }
}