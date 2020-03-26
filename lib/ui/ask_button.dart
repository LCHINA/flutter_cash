import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cash/page/home_page.dart';

class AskButton extends StatefulWidget {
  final Color boderColor;
  final Color activeColor;
  final Color disableColor;
  final double width;
  final double height;

  const AskButton(
      {Key key,
      @required this.width,
      @required this.height,
      this.boderColor,
      this.activeColor,
      this.disableColor})
      : super(key: key);

  @override
  _AskButtonState createState() => _AskButtonState();
}

class _AskButtonState extends State<AskButton>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  double percent = 0;

  @override
  void initState() {
    controller = new AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    final Animation curve =
        new CurvedAnimation(parent: controller, curve: Curves.linear);
    //60帧
    Animation<int> alpha = new IntTween(begin: 0, end: 4).animate(curve);
    alpha.addListener(() {
//      setState(() {});
      if (context != null) {
        var data = ShareDataWidget.of(context).data;
//        print(data);
        if (data != null) {
          int position = data.position;
          int duration = data.duration;
          var p = position / duration;
          if (duration == 0) {
            p = 0.1;
          }
          if (data.isFinish) {
            p = 1;
          }
          if (p != percent) {
            setState(() {
              percent = p;
            });
          }
        }
      }
    });
    super.initState();
    controller.repeat();
//    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('CustomPaint ontab');
      },
      child: CustomPaint(
        painter: _BtnPainter(2, percent: percent),
        size: Size(widget.width, widget.height),
      ),
    );
  }
}

class _BtnPainter extends CustomPainter {
  final Color borderColor;
  final Color activeColor;
  final Color disableColor;
  double radius;
  final double borderWidth;
  TextPainter textPainter;
  double percent;

  _BtnPainter(this.borderWidth,
      {this.percent = 0.5,
      this.borderColor = Colors.black26,
      this.activeColor = Colors.redAccent,
      this.disableColor = Colors.blueGrey}) {
    textPainter = new TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.rtl);
  }

  @override
  void paint(Canvas canvas, Size size) {
    radius = size.height / 2;
    //draw border
    final mPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final borderPath = Path()
      ..moveTo(radius, size.height)
      ..arcTo(Rect.fromCircle(center: Offset(radius, radius), radius: radius),
          0.5 * pi, 1 * pi, false)
      ..lineTo(size.width - radius, 0)
      ..arcTo(
          Rect.fromCircle(
              center: Offset(size.width - radius, radius), radius: radius),
          1.5 * pi,
          1 * pi,
          false)
      ..lineTo(radius, size.height)
      ..close();
    canvas.drawPath(borderPath, mPaint);
    //内圆
    var inPath = Path()
      ..moveTo(radius + 6, size.height - 6)
      ..arcTo(
          Rect.fromCircle(center: Offset(radius, radius), radius: radius - 6),
          0.5 * pi,
          1 * pi,
          false)
      ..lineTo(size.width - radius, 6)
      ..arcTo(
          Rect.fromCircle(
              center: Offset(size.width - radius, radius), radius: radius - 6),
          1.5 * pi,
          1 * pi,
          false)
      ..lineTo(radius, size.height - 6)
      ..close();
    mPaint.color = Colors.grey;
    if (percent >= 1) {
      mPaint.color = Colors.red;
    }
    mPaint.strokeWidth = 1;
    canvas.drawPath(inPath, mPaint);
    mPaint.style = PaintingStyle.fill;
    var xPath = Path()
      ..addRect(
          Rect.fromLTRB(6, 0, (size.width - 12) * percent + 6, size.height));
    final path = Path.combine(PathOperation.intersect, xPath, inPath);
    canvas.drawPath(path, mPaint);
    textPainter.text = TextSpan(
        text: percent >= 1 ? '请答题' : '请听题',
        style: TextStyle(
            textBaseline: TextBaseline.alphabetic,
            color: percent == 1 ? Colors.white : Colors.white70));
    textPainter.layout();
    textPainter.paint(
        canvas,
        new Offset(size.width / 2 - (textPainter.width / 2),
            size.height / 2 - (textPainter.height / 2)));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
