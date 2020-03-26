import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cash/ui/ask_button.dart';
import 'package:flutter_cash/ui/heart_widget.dart';

class BarWidget extends StatelessWidget {
  const BarWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var devicesWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: devicesWidth,
      height: 70,
      child: Row(
        children: <Widget>[
          buildBarItem(devicesWidth, '更多', Icons.more_vert, () {
            _openIndex0(context);
          }),
          _HeartBtn(
            width: devicesWidth / 6,
            height: 70,
            function: () {
              print('index 1');
            },
          ),
          SizedBox(
            height: 70,
            width: devicesWidth / 3,
            child: Center(
              child: AskButton(
                width: 120.0,
                height: 40.0,
              ),
            ),
          ),
          buildBarItem(devicesWidth, '分享', Icons.share, () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    width: devicesWidth,
                    height: 150,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                          child: Text('分享到'),
                        ),
                        SizedBox(
                          height: 80,
                          width: devicesWidth,
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.transparent,
                                child: IconButton(
                                  icon: Icon(Icons.favorite),
                                  tooltip: '分享到微信',
                                  iconSize: 80,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.favorite),
                                tooltip: '分享到微信',
                                iconSize: 80,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: devicesWidth,
                          height: 50,
                          child: RaisedButton(
                            color: Colors.blue,
                            child: Text('取消'),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          }),
          buildBarItem(devicesWidth, '我的', Icons.person, () {
            print('index 4');
          }),
        ],
      ),
    );
  }

  Future<int> _openIndex0(BuildContext context) {
    return showCupertinoModalPopup(
        context: context,
        builder: (context) {
          var dialog = CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Text('举报该视频'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context, 0);
              },
              child: Text('取消'),
            ),
          );
          return dialog;
        });
  }

  SizedBox buildBarItem(
      double devicesWidth, String text, IconData iconData, Function function,
      {Color color = Colors.white70}) {
    return SizedBox(
      height: 70,
      width: devicesWidth / 6,
      child: GestureDetector(
        onTap: function,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 12.0),
          child: Column(
            children: <Widget>[
              Icon(
                iconData,
                color: color,
              ),
              Text(
                text,
                style: TextStyle(color: Colors.white70),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _HeartBtn extends StatefulWidget {
  final double width;
  final double height;
  final Function function;
  final String dislikeStr;
  final String likeStr;

  const _HeartBtn(
      {Key key,
      this.width,
      this.height,
      this.function,
      this.dislikeStr = '不喜欢',
      this.likeStr = '喜欢'})
      : super(key: key);

  @override
  __HeartBtnState createState() => __HeartBtnState();
}

class __HeartBtnState extends State<_HeartBtn>
    with SingleTickerProviderStateMixin {
  bool isLike = false;

  AnimationController _controller;

  ColorTween tween;
  Color heartColor = Colors.white70;

  @override
  void initState() {
    _controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    final Animation curve = new CurvedAnimation(
        parent: _controller, curve: Curves.fastLinearToSlowEaseIn);

    Animation<Color> colorAni =
        ColorTween(begin: Colors.white70, end: Colors.redAccent).animate(curve);

    colorAni.addListener(() {
      setState(() {
        heartColor = colorAni.value;
      });
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        setState(() {
          isLike = !isLike;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 12.0),
        child: GestureDetector(
          onTap: () {
            if (isLike) {
              _controller.reverse();
            } else {
              _controller.forward();
            }
            widget.function();
          },
          child: Column(
            children: <Widget>[
              HeartWidget(
                width: 26,
                height: 26,
                color: heartColor,
              ),
              Text(
                isLike ? widget.dislikeStr : widget.likeStr,
                style: TextStyle(color: Colors.white70),
              )
            ],
          ),
        ),
      ),
    );
  }
}
