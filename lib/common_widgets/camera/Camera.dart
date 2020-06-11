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

  static Widget create(BuildContext context, data) {
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);

    return ChangeNotifierProvider<CameraState>(
      create: (context) =>
          CameraState(extImageProvider: extImageProvider, imageData: data),
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
  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    if (widget.model.controller == null && widget.model.cameras == null) {
      return FutureBuilder(
          future: availableCameras(), // a Future<String> or null
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              widget.model.cameras = snapshot.data;
              widget.model.controller = CameraController(
                  widget.model.cameras[0], ResolutionPreset.medium,
                  enableAudio: true);
              return FutureBuilder(
                  future: widget.model.controller.initialize(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Scaffold(
                        backgroundColor: Colors.black,
                        key: widget.model.scaffoldKey,
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
            return Container();
          });
    } else {
      if (widget.model.cameras != null && widget.model.controller == null) {
        widget.model.controller = CameraController(
            widget.model.cameras[0], ResolutionPreset.medium,
            enableAudio: true);
      }
      if (widget.model.controller.value.isInitialized) {
        return Scaffold(
          backgroundColor: Colors.black,
          key: widget.model.scaffoldKey,
          body: _cameraPreviewWidget(),
        );
      } else {
        return FutureBuilder(
            future: widget.model.controller.initialize(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Scaffold(
                  backgroundColor: Colors.black,
                  key: widget.model.scaffoldKey,
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
    if (widget.model.controller == null ||
        !widget.model.controller.value.isInitialized) {
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
          Positioned(
            top: 20 * ScreenUtil.pixelRatio,
            right: 20,
            child: Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.videocam),
                color: Colors.white,
                onPressed: widget.model.controller != null &&
                        widget.model.controller.value.isInitialized &&
                        !widget.model.controller.value.isRecordingVideo
                    ? widget.model.onVideoRecordButtonPressed
                    : null,
              ),
            ),
          ),
          Visibility(
              visible: widget.model.controller.value.isRecordingVideo,
              child: Positioned(
                top: 20 * ScreenUtil.pixelRatio,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: widget.model.controller != null &&
                              widget.model.controller.value.isRecordingPaused
                          ? Icon(Icons.play_arrow)
                          : Icon(Icons.pause),
                      color: Colors.white,
                      onPressed: () {
                        if (widget.model.controller != null &&
                            widget.model.controller.value.isInitialized &&
                            widget.model.controller.value.isRecordingVideo) {
                          if (widget.model.controller != null &&
                              widget.model.controller.value.isRecordingPaused) {
                            widget.model.onResumeButtonPressed();
                          } else {
                            widget.model.onPauseButtonPressed();
                          }
                        } else {
                          return null;
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      color: Colors.red,
                      onPressed: widget.model.controller != null &&
                              widget.model.controller.value.isInitialized &&
                              widget.model.controller.value.isRecordingVideo
                          ? widget.model.onStopButtonPressed
                          : null,
                    )
                  ],
                ),
              )),
          Visibility(
              visible: widget.model.imagePath != null ||
                  widget.model.videoPath != null &&
                      !widget.model.controller.value.isRecordingVideo,
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
                          widget.model.imagePath = null;
                          widget.model.videoPath = null;
                          if (widget.model.controller.value.isRecordingVideo) {
                            widget.model.controller.stopVideoRecording();
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
              visible: widget.model.imagePath == null &&
                  widget.model.videoPath == null,
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
              visible: widget.model.imagePath == null &&
                  widget.model.videoPath == null,
              child: Positioned(bottom: 20, child: _captureControlRowWidget())),
          // Positioned(bottom: 0, right: 0, child: _toggleAudioWidget()),
          Center(
            child: AspectRatio(
              aspectRatio: widget.model.controller.value.aspectRatio,
              child: CameraPreview(widget.model.controller),
            ),
          ),
          Visibility(
              visible: widget.model.imagePath == null &&
                  widget.model.videoPath == null,
              child: Positioned(
                  bottom: 20, left: 0, child: _cameraTogglesRowWidget())),
          Visibility(
              visible: widget.model.imagePath != null ||
                  widget.model.videoPath != null &&
                      !widget.model.controller.value.isRecordingVideo,
              child: _thumbnailWidget()),
        ],
      );
    }
  }

  Future<void> loadAssets() async {
    String error = '';
    try {
      await widget.model.extImageProvider
          .pickImages(
              widget.model.extImageProvider.currentAssetList,
              widget.model.imageData['max_images'],
              false,
              widget.model.extImageProvider
                  .pickImagesCupertinoOptions(takePhotoIcon: 'chat'),
              widget.model.extImageProvider.pickImagesMaterialOptions(
                  lightStatusBar: false,
                  autoCloseOnSelectionLimit: true,
                  startInAllView: false,
                  actionBarTitle: 'Select Images',
                  allViewTitle: 'All Photos'),
              context)
          .then((onValue) {
        widget.model.extImageProvider.currentAssetList = onValue;
        for (var i = 0; i < onValue.length; i++) {
          widget.model.extImageProvider.assetList.add(onValue[i]);
        }
        widget.model.imageData['image'] = onValue;
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
            widget.model.videoController == null &&
                    widget.model.imagePath == null
                ? Container()
                : (widget.model.videoController == null)
                    ? Image.file(
                        File(widget.model.imagePath),
                        fit: BoxFit.fitWidth,
                        width: ScreenUtil.screenWidthDp,
                        filterQuality: FilterQuality.high,
                        alignment: Alignment.topCenter,
                      )
                    : Container(
                        child: Center(
                          child: AspectRatio(
                              aspectRatio:
                                  widget.model.videoController.value.size !=
                                          null
                                      ? widget.model.videoController.value
                                          .aspectRatio
                                      : 1.0,
                              child: VideoPlayer(widget.model.videoController)),
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
            onPressed: widget.model.controller != null &&
                    widget.model.controller.value.isInitialized &&
                    !widget.model.controller.value.isRecordingVideo
                ? widget.model.onTakePictureButtonPressed
                : null,
          ),
        ),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (widget.model.cameras.isEmpty) {
      return Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in widget.model.cameras) {
        toggles.add(
          Visibility(
            visible: widget.model.controller.description != cameraDescription,
            child: SizedBox(
              width: 90.0,
              child: IconButton(
                  icon: Icon(
                    widget.model
                        .getCameraLensIcon(cameraDescription.lensDirection),
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (widget.model.controller != null &&
                        widget.model.controller.value.isRecordingVideo) {
                      return null;
                    } else {
                      widget.model.onNewCameraSelected(cameraDescription);
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
