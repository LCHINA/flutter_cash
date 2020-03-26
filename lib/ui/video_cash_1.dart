import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

typedef CrashPlayerCallback = void Function(int duration, int position);

class CrashViewPlayerDelegate {
  CrashViewPlayerDelegate({this.callback});

  CrashPlayerCallback callback;
  String _source;
  bool _isPlaying = true;

  set isPlaying(bool isPlaying) {
    print('old$_isPlaying new$isPlaying');
    this._isPlaying = isPlaying;
  }

  get isPlaying => this._isPlaying;

  set source(String source) {
    this._source = source;
  }

  get source => this._source;

  bool _isPlayOneTime = false;

  get isFinish => _isPlayOneTime;

  void play() {
    print('play$_isPlaying');
    this._isPlaying = true;
  }

  void pause() {
    print('old$_isPlaying');
    this._isPlaying = false;
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
      print(controller.value);
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
        widget.delegate.callback(duration, position);
        if (position == duration) {
          setState(() {
            widget.delegate.isPlaying = true;
          });
        }
        if (_isPlaying != widget.delegate.isPlaying) {
          setState(() {});
        }
      }
    };
  }

  bool _isPlaying;

  VideoPlayerController controller;
  Future<void> _initializeVideoPlayerFuture;
  VoidCallback listener;

  @override
  void initState() {
    _isPlaying = widget.delegate.isPlaying;
    controller = VideoPlayerController.network(widget.delegate.source);
    _initializeVideoPlayerFuture = controller.initialize();
    controller.setLooping(true);
    controller.play();
    super.initState();
  }

  @override
  void deactivate() {
    print('deactivate');
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    print('_CrashViewPlayerScreenState build');

    if (controller.dataSource == widget.delegate.source) {
    } else {
      controller.pause();
      controller.dispose();
      controller = VideoPlayerController.network(widget.delegate.source);
      _initializeVideoPlayerFuture = controller.initialize();
      _initializeVideoPlayerFuture.then((_) {
        print('_initializeVideoPlayerFuture');
        controller.addListener(listener);
      });
      controller.setLooping(true);
      controller.play();
    }
    if (widget.delegate.isPlaying) {
      controller.play();
    } else {
      controller.pause();
    }
    _isPlaying = widget.delegate.isPlaying;

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
    ;
  }

  @override
  void dispose() {
//    widget.delegate.controller.removeListener(listener);
    controller.dispose();
    super.dispose();
  }
}
