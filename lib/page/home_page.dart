import 'package:flutter/material.dart';
import 'package:flutter_cash/notification.dart';
import 'package:flutter_cash/ui/bar_widget.dart';
import 'package:flutter_cash/ui/video_cash.dart';

class PlayData {
  PlayData(this.dataSource, this.position, this.duration,
      {this.isFinish = false});

  String dataSource;
  int position = 0;
  int duration = 0;
  bool isFinish;

  @override
  String toString() {
    return "dataSource:$dataSource position:$position duration:$duration isFinish:$isFinish";
  }
}

//数据共享组件
class ShareDataWidget extends InheritedWidget {
  ShareDataWidget({@required this.data, Widget child}) : super(child: child);

  final PlayData data; //需要在子树中共享的数据，保存点击次数

  //定义一个便捷方法，方便子树中的widget获取共享数据
  static ShareDataWidget of(BuildContext context, {bool listen = true}) {
    return listen
        ? context.inheritFromWidgetOfExactType(ShareDataWidget)
        : context
            .ancestorInheritedElementForWidgetOfExactType(ShareDataWidget)
            .widget;
  }

  //该回调决定当data发生变化时，是否通知子树中依赖data的Widget
  @override
  bool updateShouldNotify(ShareDataWidget old) {
    print(
        "updateShouldNotify position:${old.data.position} new:${data.position}");
    //如果返回true，则子树中依赖(build函数中有调用)本widget
    //的子widget的`state.didChangeDependencies`会被调用
    return old.data.position != data.position;
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> _offsetAnimation;
  bool hide = false;
  int index = 0;
  List<String> videos = [
    'https://img.askcnd.com/v/4962460.mp4',
    'https://img.askcnd.com/v/4859008.mp4'
  ];

  String _source = '';

  int _position = 0;

  int _duration = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _offsetAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.0)).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.elasticIn));
  }

  bool _notifi(n) {
    _source = n.source;
    _position = n.position;
    _duration = n.duration;
//    setState(() {
////      _source = n.source;
////      _position = n.position;
////      _duration = n.duration;
//    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ShareDataWidget(
      data: PlayData(
          _source == '' ? videos[index] : _source, _position, _duration),
      child: Scaffold(
        body: Center(
          child: GestureDetector(
            onTap: _onTap,
            onDoubleTap: _onDoubleTap,
            onVerticalDragStart: _onVerticalDragStart,
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            child: NotificationListener<MyNotification>(
                onNotification: _notifi,
                child: CrashViewPlayerScreen(videos[index])),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
        bottomNavigationBar: SlideTransition(
          position: _offsetAnimation,
          child: const Material(
            child: BarWidget(),
            color: Colors.blueAccent,
          ),
        ),
        drawer: Drawer(
          child: Text('test'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    print('_onTap');
    if (hide) {
      _animationController.animateTo(0);
      hide = false;
    } else {
      _animationController.animateTo(1);
      hide = true;
    }
  }

  void _onDoubleTap() {
    print('home _onDoubleTap');
  }

  Offset slideOffset;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    print('_onVerticalDragUpdate');
    slideOffset = slideOffset + details.delta;
  }

  void _onVerticalDragStart(DragStartDetails details) {
    print('_onVerticalDragStart');
    slideOffset = Offset.zero;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    print('_onVerticalDragEnd');
    if (slideOffset.dy > 100 || slideOffset.dy < -100) {
      _neverSatisfied();
    }
  }

  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: <Widget>[
              Icon(
                Icons.assignment_late,
                color: Colors.yellow,
                size: 80,
              ),
              Text(
                '你确定要跳过吗？',
                style: TextStyle(fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '放弃此题您将失去这笔奖励金',
                  style: TextStyle(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '今天不在推送此题，每日答题次数有限，请慎重操作哦',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  setState(() {
                    if (index + 1 >= videos.length) {
                      index = 0;
                    } else {
                      index++;
                    }
                  });
                });
              },
            ),
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
