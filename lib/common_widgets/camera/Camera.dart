import 'dart:async';
import 'dart:io';

import 'package:Medicall/common_widgets/camera/camera_state.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  final CameraState model;

  static Widget create(BuildContext context, data, Map options) {
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);

    return ChangeNotifierProvider<CameraState>(
      create: (context) => CameraState(
          options: options,
          extImageProvider: extImageProvider,
          imageData: data),
      child: Consumer<CameraState>(
        builder: (_, model, __) => CameraScreen(
          model: model,
        ),
      ),
    );
  }

  CameraScreen({@required this.model});
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraState model;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    model.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    model = widget.model;
    ScreenUtil.init(context);
    if (model.controller == null && model.cameras == null) {
      return FutureBuilder(
          future: availableCameras(), // a Future<String> or null
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              model.cameras = snapshot.data;
              model.controller = CameraController(
                  model.cameras[0], ResolutionPreset.medium,
                  enableAudio: true);
              return FutureBuilder(
                  future: model.controller.initialize(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (model.options['fullscreen']) {
                        return Scaffold(
                          backgroundColor: Colors.black,
                          key: model.scaffoldKey,
                          body: _cameraPreviewWidget(),
                        );
                      } else {
                        return _cameraPreviewWidget();
                      }
                    } else {
                      return Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator()),
                          )
                        ],
                      );
                    }
                  });
            }
            return Container();
          });
    } else {
      if (model.cameras != null && model.controller == null) {
        model.controller = CameraController(
            model.cameras[0], ResolutionPreset.medium,
            enableAudio: true);
      }
      if (model.controller.value.isInitialized) {
        return Scaffold(
          backgroundColor: Colors.black,
          key: model.scaffoldKey,
          body: _cameraPreviewWidget(),
        );
      } else {
        return FutureBuilder(
            future: model.controller.initialize(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Scaffold(
                  backgroundColor: Colors.black,
                  key: model.scaffoldKey,
                  body: _cameraPreviewWidget(),
                );
              } else {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator()),
                    )
                  ],
                );
              }
            });
      }
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (model.controller == null || !model.controller.value.isInitialized) {
      return Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      if (model.options['fullscreen']) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 20 * ScreenUtil.pixelRatio,
              right: 20,
              child: Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.videocam),
                  color: Colors.white,
                  onPressed: model.controller != null &&
                          model.controller.value.isInitialized &&
                          !model.controller.value.isRecordingVideo
                      ? model.onVideoRecordButtonPressed
                      : null,
                ),
              ),
            ),
            Visibility(
                visible: model.controller.value.isRecordingVideo,
                child: Positioned(
                  top: 20 * ScreenUtil.pixelRatio,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: model.controller != null &&
                                model.controller.value.isRecordingPaused
                            ? Icon(Icons.play_arrow)
                            : Icon(Icons.pause),
                        color: Colors.white,
                        onPressed: () {
                          if (model.controller != null &&
                              model.controller.value.isInitialized &&
                              model.controller.value.isRecordingVideo) {
                            if (model.controller != null &&
                                model.controller.value.isRecordingPaused) {
                              model.onResumeButtonPressed();
                            } else {
                              model.onPauseButtonPressed();
                            }
                          } else {
                            return null;
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.stop),
                        color: Colors.red,
                        onPressed: model.controller != null &&
                                model.controller.value.isInitialized &&
                                model.controller.value.isRecordingVideo
                            ? model.onStopButtonPressed
                            : null,
                      )
                    ],
                  ),
                )),
            Visibility(
                visible: model.imagePath != null ||
                    model.videoPath != null &&
                        !model.controller.value.isRecordingVideo,
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
                            model.imagePath = null;
                            model.videoPath = null;
                            if (model.controller.value.isRecordingVideo) {
                              model.controller.stopVideoRecording();
                            }
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
            Visibility(
                visible: model.imagePath == null && model.videoPath == null,
                child: Positioned(
                  right: 20,
                  bottom: 20,
                  child: SizedBox(
                      width: 40.0,
                      child: IconButton(
                        icon: Icon(
                          Icons.photo_size_select_actual,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          //controller.dispose();
                          loadAssets();
                        },
                      )),
                )),
            Visibility(
                visible: model.imagePath == null && model.videoPath == null,
                child:
                    Positioned(bottom: 20, child: _captureControlRowWidget())),
            // Positioned(bottom: 0, right: 0, child: _toggleAudioWidget()),
            Center(
              child: AspectRatio(
                aspectRatio: model.controller.value.aspectRatio,
                child: CameraPreview(model.controller),
              ),
            ),
            Visibility(
                visible: model.imagePath == null && model.videoPath == null,
                child: Positioned(
                    bottom: 20, left: 0, child: _cameraTogglesRowWidget())),
            Visibility(
                visible: model.imagePath != null ||
                    model.videoPath != null &&
                        !model.controller.value.isRecordingVideo,
                child: _thumbnailWidget()),
          ],
        );
      } else {
        return Container(
          child: Center(
            child: AspectRatio(
              aspectRatio: model.controller.value.aspectRatio,
              child: CameraPreview(model.controller),
            ),
          ),
        );
      }
    }
  }

  Future<void> loadAssets() async {
    String error = '';
    try {
      await model.extImageProvider
          .pickImages(
              model.extImageProvider.currentAssetList,
              model.imageData['max_images'],
              false,
              model.extImageProvider
                  .pickImagesCupertinoOptions(takePhotoIcon: 'chat'),
              model.extImageProvider.pickImagesMaterialOptions(
                  lightStatusBar: false,
                  autoCloseOnSelectionLimit: true,
                  startInAllView: false,
                  actionBarTitle: 'Select Images',
                  allViewTitle: 'All Photos'),
              context)
          .then((onValue) {
        model.extImageProvider.currentAssetList = onValue;
        for (var i = 0; i < onValue.length; i++) {
          model.extImageProvider.assetList.add(onValue[i]);
        }
        model.imageData['image'] = onValue;
        Navigator.pop(context);
        //setState(() {});
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
            model.videoController == null && model.imagePath == null
                ? Container()
                : (model.videoController == null)
                    ? Image.file(
                        File(model.imagePath),
                        fit: BoxFit.fitWidth,
                        width: ScreenUtil.screenWidthDp,
                        filterQuality: FilterQuality.high,
                        alignment: Alignment.topCenter,
                      )
                    : Container(
                        child: Center(
                          child: AspectRatio(
                              aspectRatio:
                                  model.videoController.value.size != null
                                      ? model.videoController.value.aspectRatio
                                      : 1.0,
                              child: VideoPlayer(model.videoController)),
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
            onPressed: model.controller != null &&
                    model.controller.value.isInitialized &&
                    !model.controller.value.isRecordingVideo
                ? model.onTakePictureButtonPressed
                : null,
          ),
        ),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (model.cameras.isEmpty) {
      return Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in model.cameras) {
        toggles.add(
          Visibility(
            visible: model.controller.description != cameraDescription,
            child: SizedBox(
              width: 90.0,
              child: IconButton(
                  icon: Icon(
                    model.getCameraLensIcon(cameraDescription.lensDirection),
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (model.controller != null &&
                        model.controller.value.isRecordingVideo) {
                      return null;
                    } else {
                      model.onNewCameraSelected(cameraDescription);
                    }
                  }),
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }
}
