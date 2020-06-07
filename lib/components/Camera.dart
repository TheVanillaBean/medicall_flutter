import 'dart:async';
import 'dart:io';

import 'package:Medicall/services/extimage_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  final data;
  CameraScreen({Key key, this.data}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

List<CameraDescription> cameras;

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  ExtImageProvider _extImageProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    _extImageProvider = Provider.of<ExtImageProvider>(context);
    return FutureBuilder(
        future: availableCameras(), // a Future<String> or null
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (controller == null) {
              cameras = snapshot.data;
              controller =
                  CameraController(cameras[0], ResolutionPreset.medium);
              return FutureBuilder(
                  future: controller.initialize(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Scaffold(
                        backgroundColor: Colors.black,
                        key: _scaffoldKey,
                        body: _cameraPreviewWidget(),
                      );
                    } else {
                      return Container(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator());
                    }
                  });
            }
            return Scaffold(
              backgroundColor: Colors.black,
              key: _scaffoldKey,
              body: _cameraPreviewWidget(),
            );
          }
          return Container(
              width: 50, height: 50, child: CircularProgressIndicator());
        });
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Visibility(
              visible: imagePath != null,
              child: Positioned(
                bottom: 20,
                child: Row(
                  children: <Widget>[
                    MaterialButton(
                        shape: CircleBorder(
                            side: BorderSide(
                                width: 2,
                                color: Colors.red,
                                style: BorderStyle.solid)),
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 40,
                        ),
                        onPressed: () {
                          imagePath = null;
                          setState(() {});
                        }),
                    SizedBox(width: 40),
                    MaterialButton(
                        shape: CircleBorder(
                            side: BorderSide(
                                width: 2,
                                color: Colors.green,
                                style: BorderStyle.solid)),
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 40,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        })
                  ],
                ),
              )),
          Positioned(
            right: 20,
            bottom: 20,
            child: SizedBox(
                width: 40.0,
                child: IconButton(
                  icon: Icon(
                    Icons.photo_size_select_actual,
                    color: Colors.white,
                  ),
                  onPressed: loadAssets,
                )),
          ),
          Visibility(
              visible: imagePath == null,
              child: Positioned(bottom: 20, child: _captureControlRowWidget())),
          // Positioned(bottom: 0, right: 0, child: _toggleAudioWidget()),
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
          Visibility(
              visible: imagePath == null,
              child: Positioned(
                  bottom: 20, left: 0, child: _cameraTogglesRowWidget())),
          _thumbnailWidget(),
        ],
      );
    }
  }

  Future<void> loadAssets() async {
    String error = '';
    try {
      await _extImageProvider
          .pickImages(
              _extImageProvider.currentAssetList,
              widget.data['data']['max_images'],
              false,
              _extImageProvider.pickImagesCupertinoOptions(
                  takePhotoIcon: 'chat'),
              _extImageProvider.pickImagesMaterialOptions(
                  lightStatusBar: false,
                  autoCloseOnSelectionLimit: true,
                  startInAllView: false,
                  actionBarTitle: 'Select Images',
                  allViewTitle: 'All Photos'),
              context)
          .then((onValue) {
        _extImageProvider.currentAssetList = onValue;
        for (var i = 0; i < onValue.length; i++) {
          _extImageProvider.assetList.add(onValue[i]);
        }
        widget.data['data']['image'] = onValue;
        setState(() {});
      });
    } on Exception catch (e) {
      if (e.toString() != 'The user has cancelled the selection') {
        error = e.toString();
      }
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    print(error);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Stack(
          children: <Widget>[
            videoController == null && imagePath == null
                ? Container()
                : (videoController == null)
                    ? Image.file(
                        File(imagePath),
                        fit: BoxFit.fitWidth,
                        width: ScreenUtil.screenWidthDp,
                        filterQuality: FilterQuality.high,
                        alignment: Alignment.topCenter,
                      )
                    : Container(
                        child: Center(
                          child: AspectRatio(
                              aspectRatio: videoController.value.size != null
                                  ? videoController.value.aspectRatio
                                  : 1.0,
                              child: VideoPlayer(videoController)),
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.pink)),
                      ),
          ],
        ),
      ],
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Row(
      children: <Widget>[
        Container(
          width: 60,
          height: 60,
          child: IconButton(
            icon: Icon(
              Icons.camera_alt,
              size: 50,
            ),
            color: Colors.white,
            onPressed: controller != null &&
                    controller.value.isInitialized &&
                    !controller.value.isRecordingVideo
                ? onTakePictureButtonPressed
                : null,
          ),
        ),
        // Container(
        //   width: 100,
        //   alignment: Alignment.centerRight,
        //   child: IconButton(
        //     icon: Icon(Icons.videocam),
        //     color: Colors.white,
        //     onPressed: controller != null &&
        //             controller.value.isInitialized &&
        //             !controller.value.isRecordingVideo
        //         ? onVideoRecordButtonPressed
        //         : null,
        //   ),
        // ),
        // Visibility(
        //     visible: controller.value.isRecordingVideo,
        //     child: Row(
        //       children: <Widget>[
        //         IconButton(
        //           icon: controller != null && controller.value.isRecordingPaused
        //               ? Icon(Icons.play_arrow)
        //               : Icon(Icons.pause),
        //           color: Colors.white,
        //           onPressed: controller != null &&
        //                   controller.value.isInitialized &&
        //                   controller.value.isRecordingVideo
        //               ? (controller != null &&
        //                       controller.value.isRecordingPaused
        //                   ? onResumeButtonPressed
        //                   : onPauseButtonPressed)
        //               : null,
        //         ),
        //         IconButton(
        //           icon: Icon(Icons.stop),
        //           color: Colors.red,
        //           onPressed: controller != null &&
        //                   controller.value.isInitialized &&
        //                   controller.value.isRecordingVideo
        //               ? onStopButtonPressed
        //               : null,
        //         )
        //       ],
        //     )),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          Visibility(
            visible: controller.description != cameraDescription,
            child: SizedBox(
              width: 90.0,
              child: IconButton(
                  icon: Icon(
                    getCameraLensIcon(cameraDescription.lensDirection),
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (controller != null &&
                        controller.value.isRecordingVideo) {
                      return null;
                    } else {
                      onNewCameraSelected(cameraDescription);
                    }
                  }),
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null) showInSnackBar('Saving video to $filePath');
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recorded to: $videoPath');
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
        VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
