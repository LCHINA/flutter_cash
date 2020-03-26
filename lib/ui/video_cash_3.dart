import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cash/page/home_page.dart';
import 'package:video_player/video_player.dart';

class CrashViewPlayerScreen extends StatefulWidget {
  CrashViewPlayerScreen(this.source, {Key key}) : super(key: key);

  final String source;

  @override
  _CrashViewPlayerScreenState createState() => _CrashViewPlayerScreenState();
}

class _CrashViewPlayerScreenState extends State<CrashViewPlayerScreen> {
  _CrashViewPlayerScreenState() {
    listener = () {
//      print(controller.value);
      if (controller.value.initialized && controller.value.duration != null) {
        final int duration = controller.value.duration.inMilliseconds;
        final int position = controller.value.position.inMilliseconds;
        int maxBuffering = 0;
        for (DurationRange range in controller.value.buffered) {
          final int end = range.end.inMilliseconds;
          if (end > maxBuffering) {
            maxBuffering = end;
          }
        }
        if (position / duration > 0.9) {
          isFinish = true;
        }
//        new MyNotification(duration, position, widget.source, isFinish)
//            .dispatch(context);
        if (ShareDataWidget.of(context, listen: false).data != null) {
          ShareDataWidget.of(context, listen: false).data.position = position;
          ShareDataWidget.of(context, listen: false).data.duration = duration;
          ShareDataWidget.of(context, listen: false).data.dataSource =
              widget.source;
          ShareDataWidget.of(context, listen: false).data.isFinish = isFinish;
        }
      }
    };
  }

  VideoPlayerController controller;
  Future<void> _initializeVideoPlayerFuture;
  VoidCallback listener;
  bool isFinish = false;

  @override
  void initState() {
    print('initState');
    controller = VideoPlayerController.network(widget.source);
    _initializeVideoPlayerFuture = controller.initialize().then((_) {
      print('----');
      controller.addListener(listener);
      controller.setLooping(true);
      controller.play();
    });

    super.initState();
  }

  @override
  void deactivate() {
    print('deactivate');
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  void didUpdateWidget(CrashViewPlayerScreen oldWidget) {
    print('old:${oldWidget.source} new:${widget.source} is:$isFinish');
    if (oldWidget.source != widget.source) {
      isFinish = false;
      controller.pause();
      controller = VideoPlayerController.network(widget.source);
      _initializeVideoPlayerFuture = controller.initialize().then((_) {
        controller.addListener(listener);
        controller.setLooping(true);
        controller.play();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: _onDoubleTap,
      child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }
}
