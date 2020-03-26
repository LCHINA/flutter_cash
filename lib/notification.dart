import 'package:flutter/cupertino.dart';

class MyNotification extends Notification {
  MyNotification(this.duration, this.position, this.source, this.isFinish);

  final int duration;
  final int position;
  final String source;
  final bool isFinish;
}
