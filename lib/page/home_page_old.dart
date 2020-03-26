import 'package:flutter/material.dart';
import 'package:flutter_cash/ui/bar_widget.dart';
import 'package:flutter_cash/ui/video_cash_1.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('initState');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _offsetAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.0)).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.elasticIn));
    _delegate = new CrashViewPlayerDelegate(callback: (duration, position) {
//      print('duration:$duration position:$position');
    });
    _delegate.source = videos[index];
  }

  CrashViewPlayerDelegate _delegate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: _onTap,
          onDoubleTap: _onDoubleTap,
          onVerticalDragStart: _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: CrashViewPlayerScreen(
            delegate: _delegate,
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      bottomNavigationBar: SlideTransition(
        position: _offsetAnimation,
        child: const Material(
          child: BarWidget(),
          color: Colors.blueAccent,
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
    print('_onDoubleTap');
    if (_delegate.isPlaying) {
      _delegate.pause();
    } else {
      _delegate.play();
    }
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
                  if (index + 1 >= videos.length) {
                    index = 0;
                  } else {
                    index++;
                  }
                  print(index);
                  _delegate.source = videos[index];
                  print(_delegate.source);
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
