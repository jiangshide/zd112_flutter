import 'dart:collection' show Queue;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'bar_item.dart';

const double activeFontSize = 14.0;
const double inActiveFontSize = 12.0;
const double topMargin = 6.0;
const double bottomMargin = 8.0;

enum TabBarType{
  fixed,shifting,
}

class TabBar extends StatefulWidget{
  final bool isAnimation;
  final Color badgeColor;
  final bool isInkResponse;
  final List<TabBarItem> items;
  final ValueChanged<int> onTap;
  final int currentIndex;
  final TabBarType type;
  final Color fixedColor;
  final double iconSize;

  TabBar({Key key,
    @required this.items,
    this.onTap,
    this.currentIndex = 0,
    TabBarType type,
    this.fixedColor,
    this.iconSize = 24.0,
    this.isAnimation = true,
    this.badgeColor,
    this.isInkResponse = true,
  }):assert(null != items),assert(items.length >= 2),assert(
    items.every((item)=>item.title!=null)==true,'Every item must have a non-null title',
  ),assert(0<=currentIndex && currentIndex<items.length),assert(null != iconSize),
        type=type??(items.length <= 3 ?TabBarType.fixed:TabBarType.shifting),super(key:key);

   @override
  State<StatefulWidget> createState() => TabBarState();
}

class TabBarState extends State<TabBar> with TickerProviderStateMixin{
  List<AnimationController> _controllers = <AnimationController>[];
  List<CurvedAnimation> _animations;

  final Queue<Circle> _circles = Queue<Circle>();
  Color _bgColor;
  static final Animatable<double> _flexTween = Tween<double>(begin: 1.0,end:1.5);

  void _resetState(){
    for(AnimationController controller in _controllers) controller.dispose();
    for(Circle circle in _circles) circle.dispose();
    _circles.clear();
    
    _controllers = List<AnimationController>.generate(widget.items.length,(index){
      return AnimationController(duration: kThemeAnimationDuration,vsync: this)..addListener(_rebuild);
    });
    _animations = List<CurvedAnimation>.generate(widget.items.length,(index){
      return CurvedAnimation(parent: _controllers[index],curve: Curves.fastOutSlowIn,reverseCurve: Curves.fastOutSlowIn.flipped);
    });
    _controllers[widget.currentIndex].value = 1.0;
    _bgColor = widget.items[widget.currentIndex].bgColor;
  }

  @override
  void initState() {
    super.initState();
    _resetState();
  }

  void _rebuild(){
    setState(() {

    });
  }

  @override
  void dispose() {
    for(AnimationController controller in _controllers) controller.dispose();
    for(Circle circle in _circles) circle.dispose();
    super.dispose();
  }

  double _evaluateFlex(Animation<double> animation)=>_flexTween.evaluate(animation);

  void _pushCircle(index){
    if(null != widget.items[index].bgColor){
      _circles.add(
        Circle(state: this,index: index,color: widget.items[index].bgColor,vsync: this)..controller.addStatusListener(
            (status){
              switch(status){
                case AnimationStatus.completed:
                  setState(() {
                    final Circle circle = _circles.removeFirst();
                    _bgColor = circle.color;
                    circle.dispose();
                  });
                  break;
                case AnimationStatus.dismissed:
                case AnimationStatus.forward:
                case AnimationStatus.reverse:
                  break;
              }
            }
        ),
      );
    }
  }

  @override
  void didUpdateWidget(TabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.items.length != oldWidget.items.length){
      _resetState();return;
    }

    if(widget.currentIndex != oldWidget.currentIndex){
      switch(widget.type){
        case TabBarType.fixed:break;
        case TabBarType.shifting:
          _pushCircle(widget.currentIndex);
          break;
      }
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }else{
      if(_bgColor != widget.items[widget.currentIndex].bgColor)
        _bgColor = widget.items[widget.currentIndex].bgColor;
    }
  }

  List<Widget> _createTitles(){
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    assert(null != localizations);
    final List<Widget> children = <Widget>[];
    switch(widget.type){
      case TabBarType.fixed:
        final ThemeData themeData = Theme.of(context);
        final TextTheme textTheme = themeData.textTheme;
        Color themeColor;
        switch(themeData.brightness){
          case Brightness.light:
            themeColor = themeData.primaryColor;
            break;
          case Brightness.dark:
            themeColor = themeData.accentColor;
            break;
        }
        final ColorTween colorTween = ColorTween(begin: textTheme.caption.color,end: widget.fixedColor ?? themeColor);
        for(int i=0;i<widget.items.length;i+=1){
          children.add(
            NavigationTile(
              widget.type,
              widget.items[i],
              _animations[i],
              widget.iconSize,
              onTap: (){if(null != widget.onTap)widget.onTap(i);},
              colorTween: colorTween,
              selected: i == widget.currentIndex,
              indexLabel: localizations.tabLabel(tabIndex: i+1,tabCount: widget.items.length),
              isAnimation: widget.isAnimation,
              isInkResponse: widget.isInkResponse,
              badgeColor: widget.badgeColor == null?widget.fixedColor:widget.badgeColor,
            ),
          );
        }
        break;
      case TabBarType.shifting:
        for(int i=0;i<widget.items.length;i+=1){
          children.add(NavigationTile(widget.type,widget.items[i],_animations[i],widget.iconSize,onTap: (){
            if(widget.onTap != null)widget.onTap(i);
          },
          flex: _evaluateFlex(_animations[i]),
            selected: i == widget.currentIndex,
            indexLabel: localizations.tabLabel(tabIndex: i+1,tabCount: widget.items.length),
            isAnimation: widget.isAnimation,
            isInkResponse: widget.isInkResponse,
            badgeColor: widget.badgeColor == null?widget.fixedColor:widget.badgeColor,
          ));
        }
        break;
    }
    return children;
  }

  Widget _createContainer(List<Widget> titles){
    return DefaultTextStyle.merge(child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,children: titles,
    ),overflow: TextOverflow.ellipsis);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasMaterialLocalizations(context));

    final double additionalBottomPadding=math.max(MediaQuery.of(context).padding.bottom-bottomMargin, 0.0);
    Color backgroundColor;
    switch(widget.type){
      case TabBarType.fixed:break;
      case TabBarType.shifting:
        backgroundColor = _bgColor;
        break;
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: Material(elevation: 8.0,color: backgroundColor,)),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: kBottomNavigationBarHeight+additionalBottomPadding),
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: CustomPaint(painter: RadialPainter(circles: _circles.toList(), textDirection: Directionality.of(context)),)),
                Material(
                  type: MaterialType.transparency,
                  child: Padding(padding: EdgeInsets.only(bottom: additionalBottomPadding),
                    child: MediaQuery.removePadding(context: context,removeBottom: true, child:_createContainer(_createTitles()) ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RadialPainter extends CustomPainter{
  final List<Circle> circles;
  final TextDirection textDirection;

  RadialPainter({
    @required this.circles,
    @required this.textDirection,
  }):assert(null != circles),assert(null != textDirection);

  static double _maxRadius(Offset center,Size size){
    final double maxX = math.max(center.dx, size.width-center.dx);
    final double maxY = math.max(center.dx, size.height-center.dy);
    return math.sqrt(maxX*maxX+maxY+maxY);
  }

  @override
  bool shouldRepaint(RadialPainter oldPainter) {
    if(textDirection != oldPainter.textDirection)return true;
    if(circles == oldPainter.circles)return false;
    if(circles.length != oldPainter.circles.length)return true;
    for(int i=0;i<circles.length;i+=1)
      if(circles[i] != oldPainter.circles[i])return true;
    return false;
  }

  @override
  void paint(Canvas canvas,Size size){
    for(Circle circle in circles){
      final Paint paint = Paint()..color = circle.color;
      final Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
      canvas.clipRect(rect);
      double leftFraction;
      switch(textDirection){
        case TextDirection.rtl:
          leftFraction = 1.0-circle.horizontalLeadingOffset;
          break;
        case TextDirection.ltr:
          leftFraction = circle.horizontalLeadingOffset;
          break;
      }
      final Offset center = Offset(leftFraction*size.width, size.height/2.0);
      final Tween<double> radiusTween = Tween<double>(begin: 0.0,end: _maxRadius(center, size));
      canvas.drawCircle(center, radiusTween.transform(circle.animation.value), paint);
    }
  }
}

class NavigationTile extends StatelessWidget{
  final TabBarType type;
  final TabBarItem item;
  final Animation<double> animation;
  final double iconSize;
  final VoidCallback onTap;
  final ColorTween colorTween;
  final double flex;
  final bool selected;
  final String indexLabel;
  final bool isAnimation;
  final bool isInkResponse;
  final Color badgeColor;

  const NavigationTile(
    this.type,
    this.item,
    this.animation,
    this.iconSize,{
    this.onTap,
    this.colorTween,
    this.flex,
    this.selected = false,
    this.indexLabel,
    this.isAnimation = true,
    this.isInkResponse = true,
    this.badgeColor,
  }) : assert(null != selected);

  Widget _buildIcon(){
    double tweenStart;
    Color iconColor;
    switch(type){
      case TabBarType.fixed:
        tweenStart = 8.0;
        iconColor = colorTween.evaluate(animation);
        break;
      case TabBarType.shifting:
        tweenStart = 16.0;
        iconColor = Colors.white;
        break;
    }
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1.0,
      child: Container(
        margin: EdgeInsets.only(
          top: isAnimation?Tween<double>(begin: tweenStart,end: topMargin).evaluate(animation):topMargin,
        ),
        child: IconTheme(data: IconThemeData(color: iconColor,size: iconSize), child: selected?item.activeIcon:item.icon),
      ),
    );
  }

  Widget _buildFixedLabel(){
    double scale = isAnimation?Tween<double>(begin: inActiveFontSize/activeFontSize,end: 1.0).evaluate(animation):1.0;
    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: bottomMargin),
        child: DefaultTextStyle.merge(
          style: TextStyle(fontSize: activeFontSize,color: colorTween.evaluate(animation)),
          child: Transform(
            transform: Matrix4.diagonal3Values(scale,scale,scale),
            alignment: Alignment.bottomCenter,
            child: item.title,
          )
        ),
      ),
    );
  }
  
  Widget _buildShiftingLabel(){
    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1.0,
      child: Container(
        margin: EdgeInsets.only(bottom: Tween<double>(begin: 2.0,end: bottomMargin).evaluate(animation),),
        child: FadeTransition(opacity: animation,alwaysIncludeSemantics: true,child: DefaultTextStyle(style: const TextStyle(
          fontSize: activeFontSize,color: Colors.white,
        ), child: item.title),),
      ),
    );
  }

  Widget _buildBadge(){
    if(null == item.badge && (null == item.badgeNo || item.badgeNo.isEmpty))return Container();
    if(null != item.badge)return item.badge;
    return Container(
      width: 24,padding: EdgeInsets.fromLTRB(0, 2, 0, 2),alignment: Alignment.center,decoration: BoxDecoration(
      color: badgeColor,shape: BoxShape.rectangle,borderRadius: BorderRadius.all(Radius.circular(10))
    ),
      child: Text(item.badgeNo,style: TextStyle(fontSize: 10,color: Colors.white),),
    );
  }

  Widget _buildInkWidget(Widget label){
    if(isInkResponse){
      return InkResponse(
        onTap: onTap,child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[_buildIcon(),label],
      ),
      );
    }
    return GestureDetector(
      onTap: onTap,child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[_buildIcon(),label],
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int size;
    Widget label;
    switch(type){
      case TabBarType.fixed:
        size = 1;
        label = _buildFixedLabel();
        break;
      case TabBarType.shifting:
        size = (flex * 1000.0).round();
        label = _buildShiftingLabel();
        break;
    }
    return Expanded(
      flex: size,child: Semantics(
      container: true,header: true,selected: selected,child: Stack(
      children: <Widget>[Positioned(right: 4,top: 4,child: _buildBadge()),_buildInkWidget(label),Semantics(label: indexLabel,)],
    ),
    ),
    );
  }
}

class Circle{

  final TabBarState state;
  final int index;
  final Color color;
  AnimationController controller;
  CurvedAnimation animation;

  Circle({@required this.state,@required this.index,@required this.color,@required TickerProvider vsync,}):assert(null != state),
  assert(null != index),assert(null != color){
    controller = AnimationController(vsync: vsync,duration: kThemeAnimationDuration,);
    animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.forward();
  }

  double get horizontalLeadingOffset{
    double weightSum(Iterable<Animation<double>> animations){
      return animations.map<double>(state._evaluateFlex).fold<double>(0.0,(double sum,double value) => sum+value);
    }
    final double allWeights = weightSum(state._animations);
    final double leadingWeights = weightSum(state._animations.sublist(0,index));
    return (leadingWeights+state._evaluateFlex(state._animations[index])/2.0)/allWeights;
  }

  void dispose(){
    controller.dispose();
  }
}