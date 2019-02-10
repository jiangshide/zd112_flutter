import 'package:flutter/material.dart';

class Router extends PageRouteBuilder{
  final Widget widget;
  final int anim;
  Router({this.widget,this.anim}):super(
    transitionDuration:const Duration(milliseconds: 100),
    pageBuilder:(BuildContext context,Animation<double> animation,Animation<double> secondaryAnimation){
      return widget;
    },
    transitionsBuilder:(BuildContext context,Animation<double> animation,Animation<double> secondaryAnimation,Widget child){
      return FadeTransition(
        opacity: Tween(begin: 0.0,end: 1.0).animate(CurvedAnimation(parent: animation, curve:Curves.fastOutSlowIn)),
        child: child,
      );

      return ScaleTransition(
        scale: Tween(begin: 0.0,end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
        child: child,
      );

      return RotationTransition(
        turns: Tween(begin: -1.0,end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
        child: ScaleTransition(scale: Tween(begin: 0.0,end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
          child: child,
        ),
      );

      return SlideTransition(
        position: Tween<Offset>(begin: Offset(0.0, -1.0),end: Offset(0.0, 0.0)).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
        child: child,
      );
    }
  );
}