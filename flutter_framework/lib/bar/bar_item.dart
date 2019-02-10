import 'dart:ui';
import 'package:flutter/material.dart';

class TabBarItem{
  final Widget icon;
  final Widget activeIcon;
  final Widget title;
  final Widget badge;
  final Color bgColor;
  final String badgeNo;

  const TabBarItem({
    @required this.icon,
    Widget activeIcon,
    this.title,
    this.badge,
    this.badgeNo,
    this.bgColor,
  }):activeIcon = activeIcon??icon,assert(icon!=null);
}
