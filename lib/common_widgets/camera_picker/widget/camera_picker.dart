import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/constants.dart';
import '../delegates/camera_picker_text_delegate.dart';
import '../widget/circular_progress_bar.dart';
import 'builder/slide_page_transition_builder.dart';
import 'camera_picker_viewer.dart';

/// Create a camera picker integrate with [CameraDescription].
///
/// The picker provides create an [AssetEntity] through the camera.
/// However, this might failed (high probability) if there're any steps
/// went wrong during the process.
class CameraPicker extends StatefulWidget {
  CameraPicker({
    Key key,
    this.isAllowRecording = false,
    this.isOnlyAllowRecording = false,
    this.maximumRecordingDuration = const Duration(seconds: 15),
    this.theme,
    this.resolutionPreset = ResolutionPreset.max,
    this.cameraQuarterTurns = 0,
    CameraPickerTextDelegate textDelegate,
  })  : assert(
          isAllowRecording == true || isOnlyAllowRecording != true,
          'Recording mode error.',
        ),
        assert(
          resolutionPreset != null,
          'Resolution preset must not be null.',
        ),
        super(key: key) {
    Constants.textDelegate = textDelegate ??
        (isAllowRecording
            ? DefaultCameraPickerTextDelegateWithRecording()
            : DefaultCameraPickerTextDelegate());
  }

  /// The number of clockwise quarter turns the camera view should be rotated.
  final int cameraQuarterTurns;

  /// Whether the picker can record video.
  final bool isAllowRecording;

  /// Whether the picker can record video.
  final bool isOnlyAllowRecording;

  /// The maximum duration of the video recording process.
  /// This is 15 seconds by default.
  /// Also allow `null` for unrestricted video recording.
  final Duration maximumRecordingDuration;

  /// Theme data for the picker.
  final ThemeData theme;

  /// Present resolution for the camera.
  final ResolutionPreset resolutionPreset;

  /// Static method to create [AssetEntity] through camera.
  static Future<AssetEntity> pickFromCamera(
    BuildContext context, {
    bool isAllowRecording = false,
    bool isOnlyAllowRecording = false,
    Duration maximumRecordingDuration = const Duration(seconds: 15),
    ThemeData theme,
    int cameraQuarterTurns = 0,
    CameraPickerTextDelegate textDelegate,
    ResolutionPreset resolutionPreset = ResolutionPreset.max,
  }) async {
    if (isAllowRecording != true && isOnlyAllowRecording == true) {
      throw ArgumentError('Recording mode error.');
    }
    if (resolutionPreset == null) {
      throw ArgumentError('Resolution preset must not be null.');
    }
    final AssetEntity result = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<AssetEntity>(
      SlidePageTransitionBuilder<AssetEntity>(
        builder: CameraPicker(
          isAllowRecording: isAllowRecording,
          isOnlyAllowRecording: isOnlyAllowRecording,
          maximumRecordingDuration: maximumRecordingDuration,
          theme: theme,
          cameraQuarterTurns: cameraQuarterTurns,
          textDelegate: textDelegate,
          resolutionPreset: resolutionPreset,
        ),
        transitionCurve: Curves.easeIn,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    return result;
  }

  /// Build a dark theme according to the theme color.
  static ThemeData themeData(Color themeColor) => ThemeData.dark().copyWith(
        buttonColor: themeColor,
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        primaryColorBrightness: Brightness.dark,
        primaryColorLight: Colors.grey[900],
        primaryColorDark: Colors.grey[900],
        accentColor: themeColor,
        accentColorBrightness: Brightness.dark,
        canvasColor: Colors.grey[850],
        scaffoldBackgroundColor: Colors.grey[900],
        bottomAppBarColor: Colors.grey[900],
        cardColor: Colors.grey[900],
        highlightColor: Colors.transparent,
        toggleableActiveColor: themeColor,
        cursorColor: themeColor,
        textSelectionColor: themeColor.withAlpha(100),
        textSelectionHandleColor: themeColor,
        indicatorColor: themeColor,
        appBarTheme: const AppBarTheme(
          brightness: Brightness.dark,
          elevation: 0,
        ),
        colorScheme: ColorScheme(
          primary: Colors.grey[900],
          primaryVariant: Colors.grey[900],
          secondary: themeColor,
          secondaryVariant: themeColor,
          background: Colors.grey[900],
          surface: Colors.grey[900],
          brightness: Brightness.dark,
          error: const Color(0xffcf6679),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.black,
        ),
      );

  @override
  CameraPickerState createState() => CameraPickerState();
}

class CameraPickerState extends State<CameraPicker> {
  /// The [Duration] for record detection. (200ms)
  final Duration recordDetectDuration = const Duration(milliseconds: 200);

  /// Available cameras.
  List<CameraDescription> cameras;

  /// The controller for the current camera.
  CameraController cameraController;

  /// The index of the current cameras. Defaults to `0`.
  int currentCameraIndex = 0;

  /// The path which the temporary file will be stored.
  String cacheFilePath;

  /// Whether the [shootingButton] should animate according to the gesture.
  ///
  /// This happens when the [shootingButton] is being long pressed. It will animate
  /// for video recording state.
  bool isShootingButtonAnimate = false;

  /// Whether the recording progress started.
  ///
  /// After [shootingButton] animated, the [CircleProgressBar] will become visible.
  bool get isRecording => cameraController?.value?.isRecordingVideo ?? false;

  /// The [Timer] for record start detection.
  ///
  /// When the [shootingButton] started animate, this [Timer] will start at the same
  /// time. When the time is more than [recordDetectDuration], which means we should
  /// start recoding, the timer finished.
  Timer recordDetectTimer;

  /// The [Timer] for record countdown.
  ///
  /// When the record time reached the [maximumRecordingDuration], stop the recording.
  /// However, if there's no limitation on record time, this will be useless.
  Timer recordCountdownTimer;

  /// Whether the current [CameraDescription] initialized.
  bool get isInitialized => cameraController?.value?.isInitialized ?? false;

  /// Whether the picker can record video. (A non-null wrapper)
  bool get isAllowRecording => widget.isAllowRecording ?? false;

  /// Whether the picker can only record video. (A non-null wrapper)
  bool get isOnlyAllowRecording => widget.isOnlyAllowRecording ?? false;

  /// Getter for `widget.maximumRecordingDuration` .
  Duration get maximumRecordingDuration => widget.maximumRecordingDuration;

  /// Whether the recording restricted to a specific duration.
  ///
  /// It's **NON-GUARANTEE** for stability if there's no limitation on the record duration.
  /// This is still an experimental control.
  bool get isRecordingRestricted => maximumRecordingDuration != null;

  /// The path of the taken picture file.
  String takenPictureFilePath;

  /// The path of the taken video file.
  String takenVideoFilePath;

  /// The [File] instance of the taken picture.
  File get takenPictureFile => File(takenPictureFilePath);

  /// The [File] instance of the taken video.
  File get takenVideoFile => File(takenVideoFilePath);

  /// A getter to the current [CameraDescription].
  CameraDescription get currentCamera => cameras?.elementAt(currentCameraIndex);

  /// If there's no theme provided from the user, use [CameraPicker.themeData] .
  ThemeData _theme;

  /// Get [ThemeData] of the [AssetPicker] through [Constants.pickerKey].
  ThemeData get theme => _theme;

  @override
  void initState() {
    super.initState();
    _theme = widget.theme ?? CameraPicker.themeData(C.themeColor);

    /// TODO: Currently hide status bar will cause the viewport shaking on Android.
    /// Hide system status bar automatically on iOS.
    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
    }

    try {
      initStorePath();
      initCameras();
    } catch (e) {
      realDebugPrint('Error when initializing: $e');
      if (context == null) {
        SchedulerBinding.instance.addPostFrameCallback((Duration _) {
          Navigator.of(context).pop();
        });
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    cameraController?.dispose();
    recordDetectTimer?.cancel();
    recordCountdownTimer?.cancel();
    super.dispose();
  }

  /// Defined the path with platforms specification.
  ///
  /// * When the platform is not Android, use [getApplicationDocumentsDirectory] .
  /// * When [Platform.isAndroid] :
  ///   * SDK < 29: /sdcard/DCIM/camera .
  ///   * SDK >= 29: ${cacheDir}/ .
  Future<void> initStorePath() async {
    try {
      /// Get device info before the path initialized.
      await DeviceUtils.getDeviceInfo();

      if (Platform.isAndroid) {
        if (DeviceUtils.isLowerThanAndroidQ) {
          cacheFilePath =
              '${(await getExternalStorageDirectory()).path}/DCIM/Camera/';
        } else {
          cacheFilePath = (await getTemporaryDirectory()).path;
        }
      } else {
        cacheFilePath = (await getApplicationDocumentsDirectory()).path;
      }
      if (cacheFilePath != null) {
        cacheFilePath += '/cameraPicker';

        /// Check if the directory exists.
        final Directory directory = Directory(cacheFilePath);
        if (!directory.existsSync()) {
          /// Create the directory recursively.
          await directory.create(recursive: true);
        }
      } else {
        realDebugPrint('Failed to initialize path: Still null.');
      }
    } catch (e) {
      realDebugPrint('Error when initializing store path: $e');
    }
  }

  /// Initialize cameras instances.
  Future<void> initCameras({CameraDescription cameraDescription}) async {
    await cameraController?.dispose();

    /// When it's null, which means this is the first time initializing the cameras.
    /// So cameras should fetch.
    if (cameraDescription == null) {
      cameras = await availableCameras();
    }

    /// After cameras fetched, judge again with the list is empty or not to ensure
    /// there is at least an available camera for use.
    if (cameraDescription == null && (cameras?.isEmpty ?? true)) {
      realDebugPrint('No cameras found.');
      return;
    }

    /// Initialize the controller with the max resolution preset.
    /// - No one want the lower resolutions. :)
    cameraController = CameraController(
      cameraDescription ?? cameras[0],
      widget.resolutionPreset,
    );
    cameraController.initialize().then((dynamic _) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  /// The method to switch cameras.
  ///
  /// Switch cameras in order. When the [currentCameraIndex] reached the length
  /// of cameras, start from the beginning.
  void switchCameras() {
    ++currentCameraIndex;
    if (currentCameraIndex == cameras.length) {
      currentCameraIndex = 0;
    }
    initCameras(cameraDescription: currentCamera);
  }

  /// The method to take a picture.
  ///
  /// The picture will only taken when [isInitialized], and the camera is not
  /// taking pictures.
  Future<void> takePicture() async {
    if (isInitialized && !cameraController.value.isTakingPicture) {
      try {
        final String path = '${cacheFilePath}_$currentTimeStamp.jpg';
        await cameraController.takePicture(path);
        takenPictureFilePath = path;

        final AssetEntity entity = await CameraPickerViewer.pushToViewer(
          context,
          pickerState: this,
          pickerType: CameraPickerViewType.image,
          previewFile: takenPictureFile,
          previewFilePath: takenPictureFilePath,
          theme: theme,
        );
        if (entity != null) {
          Navigator.of(context).pop(entity);
        } else {
          takenPictureFilePath = null;
          if (mounted) {
            setState(() {});
          }
        }
      } catch (e) {
        realDebugPrint('Error when taking pictures: $e');
        takenPictureFilePath = null;
      }
    }
  }

  /// When the [shootingButton]'s `onLongPress` called, the timer [recordDetectTimer]
  /// will be initialized to achieve press time detection. If the duration
  /// reached to same as [recordDetectDuration], and the timer still active,
  /// start recording video.
  void recordDetection() {
    recordDetectTimer = Timer(recordDetectDuration, () {
      startRecordingVideo();
      if (mounted) {
        setState(() {});
      }
    });
    setState(() {
      isShootingButtonAnimate = true;
    });
  }

  /// This will be given to the [Listener] in the [shootingButton]. When it's
  /// called, which means no more pressing on the button, cancel the timer and
  /// reset the status.
  void recordDetectionCancel(PointerUpEvent event) {
    recordDetectTimer?.cancel();
    if (isRecording) {
      stopRecordingVideo();
      if (mounted) {
        setState(() {});
      }
    }
    if (isShootingButtonAnimate) {
      isShootingButtonAnimate = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Set record file path and start recording.
  void startRecordingVideo() {
    final String filePath = '${cacheFilePath}_$currentTimeStamp.mp4';
    takenVideoFilePath = filePath;
    if (!cameraController.value.isRecordingVideo) {
      cameraController.startVideoRecording(filePath).then((dynamic _) {
        if (mounted) {
          setState(() {});
        }
        if (isRecordingRestricted) {
          recordCountdownTimer = Timer(maximumRecordingDuration, () {
            stopRecordingVideo();
          });
        }
      }).catchError((dynamic e) {
        takenVideoFilePath = null;
        realDebugPrint('Error when recording video: $e');
        if (cameraController.value.isRecordingVideo) {
          cameraController.stopVideoRecording().catchError((dynamic e) {
            realDebugPrint('Error when stop recording video: $e');
          });
        }
      });
    }
  }

  /// Stop the recording process.
  Future<void> stopRecordingVideo() async {
    if (cameraController.value.isRecordingVideo) {
      cameraController.stopVideoRecording().then((dynamic result) async {
        final AssetEntity entity = await CameraPickerViewer.pushToViewer(
          context,
          pickerState: this,
          pickerType: CameraPickerViewType.video,
          previewFile: takenVideoFile,
          previewFilePath: takenVideoFilePath,
          theme: theme,
        );
        if (entity != null) {
          Navigator.of(context).pop(entity);
        } else {
          takenVideoFilePath = null;
          if (mounted) {
            setState(() {});
          }
        }
      }).catchError((dynamic e) {
        realDebugPrint('Error when stop recording video: $e');
      }).whenComplete(() {
        isShootingButtonAnimate = false;
        takenVideoFilePath = null;
      });
    }
  }

  /// Settings action section widget.
  ///
  /// This displayed at the top of the screen.
  Widget get settingsAction {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: <Widget>[
          const Spacer(),
          // TODO(Alex): There's an issue tracking NPE of the camera plugin, so switching is temporary disabled .
          if ((cameras?.length ?? 0) > 1) switchCamerasButton,
        ],
      ),
    );
  }

  /// The button to switch between cameras.
  Widget get switchCamerasButton {
    return InkWell(
      onTap: switchCameras,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(
          Icons.switch_camera,
          color: Colors.white,
          size: 30.0,
        ),
      ),
    );
  }

  /// Text widget for shooting tips.
  Widget get tipsTextWidget {
    return AnimatedOpacity(
      duration: recordDetectDuration,
      opacity: isRecording ? 0.0 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
        ),
        child: Text(
          Constants.textDelegate.shootingTips,
          style: const TextStyle(fontSize: 15.0),
        ),
      ),
    );
  }

  /// Shooting action section widget.
  ///
  /// This displayed at the top of the screen.
  Widget get shootingActions {
    return SizedBox(
      height: Screens.width / 3.5,
      child: Row(
        children: <Widget>[
          Expanded(
            child: !isRecording
                ? Center(child: backButton)
                : const SizedBox.shrink(),
          ),
          Expanded(child: Center(child: shootingButton)),
          const Spacer(),
        ],
      ),
    );
  }

  /// The back button near to the [shootingButton].
  Widget get backButton {
    return InkWell(
      borderRadius: maxBorderRadius,
      onTap: Navigator.of(context).pop,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        width: Screens.width / 15,
        height: Screens.width / 15,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// The shooting button.
  Widget get shootingButton {
    final Size outerSize = Size.square(Screens.width / 3.5);
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerUp: isAllowRecording ? recordDetectionCancel : null,
      child: InkWell(
        borderRadius: maxBorderRadius,
        onTap: !isOnlyAllowRecording ? takePicture : null,
        onLongPress: isAllowRecording ? recordDetection : null,
        child: SizedBox.fromSize(
          size: outerSize,
          child: Stack(
            children: <Widget>[
              Center(
                child: AnimatedContainer(
                  duration: kThemeChangeDuration,
                  width: isShootingButtonAnimate
                      ? outerSize.width
                      : (Screens.width / 5),
                  height: isShootingButtonAnimate
                      ? outerSize.height
                      : (Screens.width / 5),
                  padding: EdgeInsets.all(
                    Screens.width / (isShootingButtonAnimate ? 10 : 35),
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white30,
                    shape: BoxShape.circle,
                  ),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (isRecording && isRecordingRestricted)
                CircleProgressBar(
                  duration: maximumRecordingDuration,
                  outerRadius: outerSize.width,
                  ringsWidth: 2.0,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Material(
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            if (isInitialized)
              Center(
                child: RotatedBox(
                  quarterTurns: widget.cameraQuarterTurns ?? 0,
                  child: AspectRatio(
                    aspectRatio: cameraController.value.aspectRatio,
                    child: CameraPreview(cameraController),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: <Widget>[
                    settingsAction,
                    const Spacer(),
                    tipsTextWidget,
                    shootingActions,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
