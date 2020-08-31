import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:Medicall/common_widgets/camera/camera_state.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
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
                          backgroundColor: Theme.of(context).canvasColor,
                          key: model.scaffoldKey,
                          body: _cameraPreviewWidget(context),
                        );
                      } else {
                        return _cameraPreviewWidget(context);
                      }
                    } else {
                      return Container(
                        color: Theme.of(context).canvasColor,
                        alignment: Alignment.center,
                        width: ScreenUtil.screenWidthDp,
                        height: ScreenUtil.screenHeightDp,
                        child: Container(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator()),
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
          body: _cameraPreviewWidget(context),
        );
      } else {
        return FutureBuilder(
            future: model.controller.initialize(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Scaffold(
                  backgroundColor: Colors.black,
                  key: model.scaffoldKey,
                  body: _cameraPreviewWidget(context),
                );
              } else {
                return Container(
                  color: Theme.of(context).canvasColor,
                  alignment: Alignment.center,
                  width: ScreenUtil.screenWidthDp,
                  height: ScreenUtil.screenHeightDp,
                  child: Container(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator()),
                );
              }
            });
      }
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  _cameraPreviewWidget(context) {
    final deviceRatio = ScreenUtil.screenWidthDp / ScreenUtil.screenHeightDp;
    final xScale = model.controller.value.aspectRatio / deviceRatio;

// Modify the yScale if you are in Landscape
    if (model.controller == null || !model.controller.value.isInitialized) {
      return Text(
        'Tap a camera',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      if (model.options['fullscreen']) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              child: AspectRatio(
                aspectRatio: deviceRatio,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(xScale, 1, 1),
                  child: CameraPreview(model.controller),
                ),
              ),
            ),
            Visibility(
              visible: model.options['video'],
              child: Positioned(
                top: 20,
                right: 10,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.videocam),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      if (model.controller != null &&
                          model.controller.value.isInitialized &&
                          !model.controller.value.isRecordingVideo) {
                        model.onVideoRecordButtonPressed(context);
                      }
                    },
                  ),
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
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          if (model.controller != null &&
                              model.controller.value.isInitialized &&
                              model.controller.value.isRecordingVideo) {
                            if (model.controller != null &&
                                model.controller.value.isRecordingPaused) {
                              model.onResumeButtonPressed(context);
                            } else {
                              model.onPauseButtonPressed(context);
                            }
                          } else {
                            return null;
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.stop),
                        color: Colors.red,
                        onPressed: () {
                          if (model.controller != null &&
                              model.controller.value.isInitialized &&
                              model.controller.value.isRecordingVideo) {
                            model.onStopButtonPressed(context);
                          }
                        },
                      )
                    ],
                  ),
                )),
            Positioned(
                top: ScreenUtil.statusBarHeight + 10,
                left: 0,
                child: Container(
                  width: ScreenUtil.screenWidthDp,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: returnThumbnailImages(context),
                  ),
                )),
            Positioned(
              bottom: 0,
              child: Row(
                children: [
                  // Positioned(bottom: 0, right: 0, child: _toggleAudioWidget()),
                  Visibility(
                      visible:
                          model.imagePath == null && model.videoPath == null,
                      child: Container(
                          padding: EdgeInsets.all(5),
                          color: Theme.of(context).canvasColor.withAlpha(120),
                          width: ScreenUtil.screenWidthDp / 3,
                          child: _cameraTogglesRowWidget(context))),
                  Visibility(
                      visible:
                          model.imagePath == null && model.videoPath == null,
                      child: Container(
                          padding: EdgeInsets.all(5),
                          color: Theme.of(context).canvasColor.withAlpha(120),
                          width: ScreenUtil.screenWidthDp / 3,
                          child: _captureControlRowWidget(context))),
                  Visibility(
                      visible:
                          model.imagePath == null && model.videoPath == null,
                      child: Container(
                          padding: EdgeInsets.all(5),
                          color: Theme.of(context).canvasColor.withAlpha(120),
                          width: ScreenUtil.screenWidthDp / 3,
                          child: IconButton(
                            icon: Icon(
                              Icons.photo_size_select_actual,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              //controller.dispose();
                              loadAssets(context);
                            },
                          ))),
                ],
              ),
            ),
            Visibility(
                visible: model.imagePath != null ||
                    model.videoPath != null &&
                        !model.controller.value.isRecordingVideo,
                child: _thumbnailWidget()),
            Visibility(
                visible: model.imagePath != null ||
                    model.videoPath != null &&
                        !model.controller.value.isRecordingVideo,
                child: Positioned(
                  bottom: 10,
                  child: Column(
                    children: <Widget>[
                      ReusableRaisedButton(
                          title: "Delete",
                          onPressed: () async {
                            await File(model.imagePath).delete();
                            int removeIndex =
                                model.imagePathList.indexOf(model.imagePath);
                            model.imagePathList.removeAt(removeIndex);
                            model.imageData.questionPhotos
                                .removeAt(removeIndex);
                            model.imagePath = null;
                            model.videoPath = null;
                            if (model.controller.value.isRecordingVideo) {
                              model.controller.stopVideoRecording();
                            }
                            setState(() {});
                          }),
                      SizedBox(
                        height: 10,
                      ),
                      ReusableRaisedButton(
                          title: "Accept",
                          outlined: true,
                          onPressed: () {
                            if (!model.imagePathList
                                .contains(model.imagePath)) {
                              model.imagePathList.add(model.imagePath);
                            }
                            List<Map<String, ByteData>> resultMap = [];
                            for (var i = 0;
                                i < model.imagePathList.length;
                                i++) {
                              File file = File(model.imagePathList[i]);
                              Uint8List bytes = file.readAsBytesSync();
                              ByteData byteData = ByteData.view(bytes.buffer);
                              if (!resultMap.contains(
                                  {model.imagePathList[i]: byteData})) {
                                resultMap
                                    .add({model.imagePathList[i]: byteData});
                              }
                            }
                            model.imageData.updateQuestionPageWith(
                                questionPhotos: resultMap);
                            model.imagePath = null;
                            setState(() {});
                          }),
                    ],
                  ),
                )),
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

  returnThumbnailImages(context) {
    if (model.imageData.questionPhotos.length > 0) {
      model.imagePathList = [];
      for (var i = 0; i < model.imageData.questionPhotos.length; i++) {
        final String filePath = model.imageData.questionPhotos[i].keys.first;
        if (!model.imagePathList.contains(filePath) &&
            model.imagePathList.length < model.options['max_images']) {
          model.imagePathList.add(filePath);
        }
      }
    }
    List<GestureDetector> widgetList = [];
    for (var i = 0; i < model.imagePathList.length; i++) {
      widgetList.add(GestureDetector(
        onTap: () {
          model.imagePath = model.imagePathList[i];
          _thumbnailWidget();
          // await File(model.imagePathList[i]).delete();
          // model.imagePathList.removeAt(i);
          setState(() {});
        },
        child: Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(
                        12) //                 <--- border radius here
                    ),
                color: Theme.of(context).canvasColor.withAlpha(80),
                border: Border.all(
                    color: Theme.of(context).colorScheme.primary, width: 2)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.file(
                File(model.imagePathList[i]),
                fit: BoxFit.fill,
                height: 80,
                width: 80,
              ),
            )),
      ));
    }
    for (var i = 0;
        i < model.options['max_images'] - model.imagePathList.length;
        i++) {
      widgetList.add(GestureDetector(
        onTap: () async {},
        child: Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(
                        12) //                 <--- border radius here
                    ),
                color: Theme.of(context).canvasColor.withAlpha(80),
                border: Border.all(
                    color: Theme.of(context).colorScheme.primary, width: 2)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Text((i + 1 + model.imagePathList.length).toString()),
            )),
      ));
    }
    return widgetList;
  }

  Future<void> loadAssets(context) async {
    String error = '';
    String color = '#' +
        Theme.of(context)
            .colorScheme
            .primary
            .value
            .toRadixString(16)
            .toUpperCase()
            .substring(2);
    try {
      await model.extImageProvider
          .pickImages(
              model.extImageProvider.currentAssetList,
              model.options['max_images'] - model.imagePathList.length,
              false,
              model.extImageProvider
                  .pickImagesCupertinoOptions(takePhotoIcon: 'chat'),
              model.extImageProvider.pickImagesMaterialOptions(
                  lightStatusBar: false,
                  actionBarColor: color,
                  statusBarColor: color,
                  autoCloseOnSelectionLimit: true,
                  startInAllView: false,
                  actionBarTitle: 'Select Images',
                  allViewTitle: 'All Photos'),
              context)
          .then((onValue) async {
        model.extImageProvider.currentAssetList = onValue;
        for (var i = 0; i < onValue.length; i++) {
          if (!model.extImageProvider.assetList.contains(onValue[i])) {
            model.extImageProvider.assetList.add(onValue[i]);
          }
        }
        List<Map<String, ByteData>> resultMap = [];
        for (Asset asset in model.extImageProvider.assetList) {
          ByteData byteData =
              await FirebaseStorageService.getAccurateByteData(asset);
          String assetPath =
              await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
          if (!model.extImageProvider.assetList
                  .contains({asset.name: byteData}) &&
              model.options['max_images'] > resultMap.length) {
            resultMap.add({assetPath: byteData});
          } else {
            resultMap.remove({assetPath: byteData});
          }
        }

        for (var i = 0; i < model.imagePathList.length; i++) {
          File file = File(model.imagePathList[i]);
          Uint8List bytes = file.readAsBytesSync();
          ByteData byteData = ByteData.view(bytes.buffer);
          if (!resultMap.contains({model.imagePathList[i]: byteData})) {
            resultMap.add({model.imagePathList[i]: byteData});
          }
        }

        for (var i = 0;
            i < model.extImageProvider.currentAssetList.length;
            i++) {
          String assetPath = await FlutterAbsolutePath.getAbsolutePath(
              model.extImageProvider.currentAssetList[i].identifier);
          if (model.imagePathList.contains(assetPath)) {
            model.imagePathList.remove(assetPath);
          } else {
            model.imagePathList.add(assetPath);
          }
        }
        model.imageData.updateQuestionPageWith(questionPhotos: resultMap);
        //Navigator.pop(context);
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
    final deviceRatio = ScreenUtil.screenWidthDp / ScreenUtil.screenHeightDp;
    final xScale = model.controller.value.aspectRatio / deviceRatio;
    return model.videoController == null && model.imagePath == null
        ? Container()
        : (model.videoController == null)
            ? Container(
                child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(xScale, 1, 1),
                child: Image.file(
                  File(model.imagePath),
                  fit: BoxFit.fill,
                  height: ScreenUtil.screenHeightDp,
                  width: ScreenUtil.screenWidthDp,
                  filterQuality: FilterQuality.high,
                ),
              ))
            : Container(
                child: Center(
                  child: AspectRatio(
                      aspectRatio: model.videoController.value.size != null
                          ? model.videoController.value.aspectRatio
                          : 1.0,
                      child: VideoPlayer(model.videoController)),
                ),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.pink)),
              );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(
            Icons.camera_alt,
            size: 50,
          ),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            if (model.controller != null &&
                model.controller.value.isInitialized &&
                !model.controller.value.isRecordingVideo) {
              if (model.imagePathList.length < model.options['max_images']) {
                model.onTakePictureButtonPressed(context);
              } else {
                AppUtil().showFlushBar(
                    "Max images reached, please delete some to make space.",
                    context);
              }
            }
          },
        ),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget(context) {
    final List<Widget> toggles = <Widget>[];

    if (model.cameras.isEmpty) {
      return Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in model.cameras) {
        toggles.add(
          Visibility(
            visible: model.controller.description != cameraDescription,
            child: IconButton(
                alignment: Alignment.center,
                padding: EdgeInsets.all(0),
                icon: Icon(
                  model.getCameraLensIcon(cameraDescription.lensDirection),
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if (model.controller != null &&
                      model.controller.value.isRecordingVideo) {
                    return null;
                  } else {
                    model.onNewCameraSelected(cameraDescription, context);
                  }
                }),
          ),
        );
      }
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: toggles);
  }
}
