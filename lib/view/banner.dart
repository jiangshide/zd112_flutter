import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'dart:async';

typedef void OnBannerClickListener<D>(int index,D itemData);
typedef Widget BuildShow<D>(int index,D itemData);

const IntegerMax = 0x7fffffff;

class Banner<T> extends StatefulWidget{
  final OnBannerClickListener<T> onBannerClickListener;

  final int delayTime;
  final int scrollTime;
  final double height;
  final List<T> data;
  final BuildShow<T> buildShow;

  Banner({Key key,
    @required this.data,
    @required this.buildShow,
    this.onBannerClickListener,
    this.delayTime = 3,
    this.scrollTime = 200,
    this.height = 200.0
  }):super(key:key);

  @override
  State<StatefulWidget> createState() => BannerState();
}

class BannerState extends State<Banner>{
  final pageController = PageController(initialPage: IntegerMax ~/ 2);
  Timer timer;

  @override
  void initState() {
    super.initState();
    resetTimer();
  }

  resetTimer(){
    clearTimer();
    timer = Timer.periodic(Duration(seconds: widget.delayTime),(timer){
      if(pageController.positions.isNotEmpty){
        var i = pageController.page.toInt()+1;
        pageController.animateToPage(i==3?0:i, duration: Duration(milliseconds: widget.scrollTime), curve: Curves.linear);
      }
    });
  }

  clearTimer(){
    if(null != timer){
      timer.cancel();
      timer = null;
    }
  }

  @override
  void dispose() {
    clearTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQueryData.fromWindow(window).size.width;
    return SizedBox(
      height: widget.height,
      child: widget.data.length == 0?null:GestureDetector(
        onTap: (){
          widget.onBannerClickListener(pageController.page.round()%widget.data.length,widget.data[pageController.page.round()%widget.data.length]);
        },
        onTapDown: (details){
          clearTimer();
        },
        onTapUp: (details){
          resetTimer();
        },
        onTapCancel: (){
          resetTimer();
        },
        child: PageView.builder(
          controller: pageController,
          physics: const PageScrollPhysics(parent: const ClampingScrollPhysics()),
          itemBuilder: (context,index){
            return widget.buildShow(index,widget.data[index%widget.data.length]);
          },
          itemCount: IntegerMax,
        ),
      ),
    );
  }
}