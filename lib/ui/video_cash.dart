import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

typedef CrashPlayerCallback = void Function(int duration, int position);

class CrashViewPlayerDelegate {
  VideoPlayerController controller;
String _source;
  set source(String source) {
    this._source = source;
  }
  get source =>this._source;
  Future<void> _initializeVideoPlayerFuture;
  bool _isPlayOneTime = false;

  get isFinish => _isPlayOneTime;
  CrashPlayerCallback callback;

  CrashViewPlayerDelegate({this.callback});

  void play() {
    if (!controller.value.isPlaying) {
      controller.play();
    }
  }

  void pause() {
    if (controller.value.isPlaying) {
      controller.pause();
    }
  }

  get isPlaying => controller.value.isPlaying;

  // ignore: missing_return
  Widget build(BuildContext context) {
    print(source);
    controller = VideoPlayerController.network(source);
    _initializeVideoPlayerFuture = controller.initialize();
    _initializeVideoPlayerFuture.then((_) {
      print('_initializeVideoPlayerFuture');
      _isPlayOneTime = false;
//      controller.dispose();
      controller.setLooping(false);
      controller.play();
    });

    return FutureBuilder(
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
        });
  }
}

class CrashViewPlayerScreen extends StatefulWidget {
  final CrashViewPlayerDelegate delegate;

  CrashViewPlayerScreen({Key key, this.delegate}) : super(key: key);

  @override
  _CrashViewPlayerScreenState createState() => _CrashViewPlayerScreenState();
}

class _CrashViewPlayerScreenState extends State<CrashViewPlayerScreen> {
  _CrashViewPlayerScreenState() {
    listener = () {
      print(widget.delegate.controller.value);
      final int duration =
          widget.delegate.controller.value.duration.inMilliseconds;
      final int position =
          widget.delegate.controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in widget.delegate.controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }
      widget.delegate.callback(duration, position);
//      print('duration:$duration position:$position max:$maxBuffering');
      if (position == duration) {
        setState(() {
          widget.delegate.controller.setLooping(true);
          widget.delegate.controller.play();
          widget.delegate._isPlayOneTime = true;
        });
      }
    };
  }

  VoidCallback listener;

  @override
  void initState() {
    super.initState();
//    widget.delegate.controller.addListener(listener);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    print('_CrashViewPlayerScreenState build');
//    widget.delegate.controller.addListener(listener);
    return widget.delegate.build(context);
  }

  @override
  void dispose() {
//    widget.delegate.controller.removeListener(listener);
    widget.delegate.controller.dispose();
    super.dispose();
  }
}
