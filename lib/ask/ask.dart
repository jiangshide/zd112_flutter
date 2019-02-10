import 'package:flutter/material.dart';
import 'package:flutter_framework/flutter_framework.dart';
import 'package:flutter_framework/view/refresh/space_header.dart';
import 'package:flutter_framework/view/refresh/space_footer.dart';
import 'detail.dart';

class Ask extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _AskState();
}

class _AskState extends State<Ask>{
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
        child: EasyRefresh(
          key: _easyRefreshKey,
          refreshHeader: SpaceHeader(key: _headerKey),
          refreshFooter: SpaceFooter(key: _footerKey),
          child: ListView.builder(
            itemCount: str.length,
            itemBuilder: (context,index){
              return Container(
                height: 70.0,
                child: FlatButton(
                  onPressed: (){
                    Navigator.push(context, Router(widget:Detail()));
                  },
                  child: Text(str[index],style: TextStyle(fontSize: 18.0),),
                ),
              );
            },
          ),
          onRefresh: () async{
            await Future.delayed(const Duration(seconds: 3),(){
              if(!mounted) return;
              setState(() {
                str.clear();
                str.addAll(addStr);
              });
            });
          },
          loadMore: () async{
            await Future.delayed(const Duration(seconds: 1),(){
              if(str.length < 20){
                if(!mounted)return;
                setState(() {
                  str.addAll(addStr);
                });
              }
            });
          },
        ),
      ),
    );
  }
}