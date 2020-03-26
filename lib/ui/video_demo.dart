import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoComponet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _VideoComponet();
  }
}

class _VideoComponet extends State<VideoComponet> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://img.askcnd.com/v/4962460.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    ///SingleChildScrollView 防止键盘输入报错，自动弹到键盘以上
    return new SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: new Container(
        child: new Center(
          child: new Column(
            children: <Widget>[
              new Container(
                child:  new GestureDetector(
                  onTap: _onTap,
                  child:  new Container(
                    height: 300,
                    child: VideoPlayer(_controller),
                  ),
                ),),
              //显示进度条，内部Widget,支持进度条
              new VideoProgressIndicator(_controller,allowScrubbing:true),
              new TextField(
                onSubmitted:_onSubmitted ,
              ),
              new FlatButton(onPressed: _seekTo, child: new Text("快进")),
              new FlatButton(onPressed: _play, child: new Text("播放")),
              new FlatButton(onPressed: _pause, child: new Text("暂停")),
              new FlatButton(onPressed: _initSource, child: new Text("初始化"))
            ],
          ),
        ),
      ),
    );
  }

  void _play() {
    setState(() {
      _controller.play();
    });
  }

  void _pause() {
    setState(() {
      _controller.pause();
    });
  }

  void _initSource() {
    setState(() {
      _controller = VideoPlayerController.network(
          "https://img.askcnd.com/v/4962460.mp4")
        ..initialize().then((_) {
          setState(() {});
        });
    });
  }
  void _onSubmitted(String url){
    _controller.dispose();
    if(url.isEmpty){
      url="https://img.askcnd.com/v/4962460.mp4";
    }
    setState(() {
      _controller = VideoPlayerController.network(
          url)
        ..initialize().then((_) {
          setState(() {});
        });
    });
  }

  void _onTap(){
    if(_controller.value.isPlaying){
      setState(() {
        _controller.pause();
      });
    }else{
      setState(() {
        _controller.play();
      });
    }
  }
  void _seekTo(){
    _controller.position;
    print("asassa");
  }
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}