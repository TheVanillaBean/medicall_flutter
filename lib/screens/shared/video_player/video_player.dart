import 'dart:io';

import 'package:Medicall/routing/router.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer extends StatefulWidget {
  final String title;
  final String url;
  final File file;
  final bool fromNetwork;

  const VideoPlayer(
      {@required this.title, @required this.fromNetwork, this.url, this.file})
      : assert((fromNetwork && url != null) || (!fromNetwork && file != null));

  static Future<void> show({
    BuildContext context,
    String url,
    String title,
    bool fromNetwork,
    File file,
  }) async {
    if (fromNetwork) {
      await Navigator.of(context).pushNamed(
        Routes.videoPlayer,
        arguments: {
          'url': url,
          'title': title,
          'fromNetwork': fromNetwork,
        },
      );
    } else {
      await Navigator.of(context).pushNamed(
        Routes.videoPlayer,
        arguments: {
          'title': title,
          'file': file,
          'fromNetwork': fromNetwork,
        },
      );
    }
  }

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    this.initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    if (widget.fromNetwork) {
      _videoPlayerController = VideoPlayerController.network(
        widget.url,
      );
    } else {
      _videoPlayerController = VideoPlayerController.file(
        widget.file,
      );
    }
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.blue,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.lightGreen,
      ),
      placeholder: Container(
        color: Colors.grey,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: _chewieController != null &&
                      _chewieController.videoPlayerController.value.initialized
                  ? Chewie(
                      controller: _chewieController,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
