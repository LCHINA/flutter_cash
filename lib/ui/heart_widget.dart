import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeartWidget extends StatefulWidget {
  final double width;
  final double height;
  final Color color;

  const HeartWidget({
    Key key,
    this.width,
    this.height,
    this.color = Colors.white70,
  }) : super(key: key);

  @override
  _HeartWidgetState createState() => _HeartWidgetState();
}

class _HeartWidgetState extends State<HeartWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HeartBtn(widget.color),
      size: Size(widget.width, widget.height),
    );
  }
}

class _HeartBtn extends CustomPainter {
  var mPaint = Paint();

  final Color paintColor;

  _HeartBtn(this.paintColor);

  @override
  void paint(Canvas canvas, Size size) {
    mPaint.color = paintColor;
    mPaint.style = PaintingStyle.fill;

    final heartPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.17)
      ..cubicTo(
          size.width * (1 - 0.15),
          -size.height * 0.1,
          size.width * (1 + 0.4),
          size.height * 0.45,
          size.width * 0.5,
          size.height)
      ..moveTo(size.width * 0.5, size.height)
      ..close();
    final nPath = heartPath.transform(Matrix4.rotationY(pi).storage);
    heartPath.addPath(nPath, Offset(size.width, 0));
    canvas.drawPath(heartPath, mPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
