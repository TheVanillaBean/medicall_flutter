import 'dart:io';

import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CameraState with ChangeNotifier {
  CameraState({this.options, @required this.extImageProvider, this.imageData});
  Map options;
  CameraController controller;
  String imagePath;
  List<String> imagePathList = [];
  String videoPath;
  dynamic imageData;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  ExtImageProvider extImageProvider;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void updateWith({
    CameraController controller,
    String imagePath,
    List<String> imagePathList,
    String videoPath,
    VideoPlayerController videoController,
  }) {
    this.controller = controller ?? this.controller;
    this.imagePath = imagePath ?? this.imagePath;
    this.imagePathList = imagePathList ?? this.imagePathList;
    this.videoPath = videoPath ?? this.videoPath;
    this.videoController = videoController ?? this.videoController;
    notifyListeners();
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

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message, context) {
    AppUtil().showFlushBar(message, context);
  }

  void onNewCameraSelected(CameraDescription cameraDescription, context) async {
    if (controller != null) {
      await controller.dispose();
    }
    updateWith(
        controller: CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: true,
    ));

    // If the controller is updated then update the UI.
    // controller.addListener(() {
    //   if (controller.value.hasError) {
    //     showInSnackBar('Camera error ${controller.value.errorDescription}');
    //   }
    // });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e, context);
    }
  }

  void onTakePictureButtonPressed(context) {
    takePicture(context).then((String filePath) {
      videoController?.dispose();
      updateWith(imagePath: filePath, videoController: null);
      // if (filePath != null)
      //   showInSnackBar('Picture saved to $filePath', context);
    });
  }

  void onVideoRecordButtonPressed(context) {
    startVideoRecording(context).then((String filePath) {
      // if (filePath != null)
      //   showInSnackBar('Saving video to $filePath', context);
    });
  }

  void onStopButtonPressed(context) {
    stopVideoRecording(context).then((_) {
      showInSnackBar('Video recorded to: $videoPath', context);
    });
  }

  void onPauseButtonPressed(context) {
    pauseVideoRecording(context).then((_) {
      showInSnackBar('Video recording paused', context);
    });
  }

  void onResumeButtonPressed(context) {
    resumeVideoRecording(context).then((_) {
      showInSnackBar('Video recording resumed', context);
    });
  }

  Future<String> startVideoRecording(context) async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.', context);
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      updateWith(videoPath: filePath);
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e, context);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording(context) async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e, context);
      return null;
    }

    await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording(context) async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e, context);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording(context) async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e, context);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
        VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    updateWith(imagePath: null, videoController: vcontroller);
    await vcontroller.play();
  }

  Future<String> takePicture(context) async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.', context);
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e, context);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e, context) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}', context);
  }
}
