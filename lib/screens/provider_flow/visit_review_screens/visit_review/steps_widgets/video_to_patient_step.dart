import 'dart:io';

import 'package:Medicall/common_widgets/assets_picker/widget/asset_picker.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/video_to_patient_step_state.dart';
import 'package:Medicall/screens/shared/video_player/video_player.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail_generator/video_thumbnail_generator.dart';

import '../visit_review_view_model.dart';

class VideoToPatientStep extends StatefulWidget {
  final VideoToPatientStepState model;

  const VideoToPatientStep({@required this.model});

  static Widget create(BuildContext context) {
    final VisitReviewViewModel visitReviewViewModel =
        Provider.of<VisitReviewViewModel>(context);
    ExtImageProvider _extImageProvider = Provider.of<ExtImageProvider>(context);
    FirebaseStorageService _storageService =
        Provider.of<FirebaseStorageService>(context);
    return ChangeNotifierProvider<VideoToPatientStepState>(
      create: (context) => VideoToPatientStepState(
        visitReviewViewModel: visitReviewViewModel,
        extImageProvider: _extImageProvider,
        storageService: _storageService,
      ),
      child: Consumer<VideoToPatientStepState>(
        builder: (_, model, __) => VideoToPatientStep(model: model),
      ),
    );
  }

  @override
  _VideoToPatientStepState createState() => _VideoToPatientStepState();
}

class _VideoToPatientStepState extends State<VideoToPatientStep> {
  Future<void> _submit() async {
    widget.model.updateWith(isLoading: true, isSubmitted: true);
    String url = await widget.model.storageService.uploadPatientNoteVideo(
      mediaInfo: widget.model.mediaInfo,
      consultId: widget.model.visitReviewViewModel.consult.uid,
    );
    widget.model.updateWith(videoURL: url);
    await widget.model.visitReviewViewModel
        .saveVideoNoteToFirestore(widget.model);

    widget.model.updateWith(isLoading: false);
    AppUtil().showFlushBar("Successfully saved video note!", context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return LayoutBuilder(builder: (context, constraint) {
      return SwipeGestureRecognizer(
        onSwipeLeft: () {
          if (widget.model.minimumRequiredFieldsFilledOut &&
              widget.model.editedStep) {
            widget.model.editedStep = false;
            AppUtil().showFlushBar("Press save to save your changes", context);
          }
          widget.model.visitReviewViewModel.incrementIndex();
        },
        onSwipeRight: () {
          if (widget.model.minimumRequiredFieldsFilledOut &&
              widget.model.editedStep) {
            widget.model.editedStep = false;
            AppUtil().showFlushBar("Press save to save your changes", context);
          }
          widget.model.visitReviewViewModel.decrementIndex();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
              child: Text(
                "Record a Video Note (Optional)",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.model.mediaInfo == null &&
                widget.model.videoURL.length > 0)
              _buildVideoCardNetworkButton(
                context,
                'Visit Date: ',
                widget.model.formattedRecordedDate,
                () async {
                  widget.model.updateWith(isLoading: true);
                  await VideoPlayer.show(
                    context: context,
                    url: widget.model.videoURL,
                    title: "Video Note",
                    fromNetwork: true,
                  );
                  widget.model.updateWith(isLoading: false);
                },
              ),
            if (widget.model.mediaInfo != null)
              _buildVideoCardMemoryButton(
                context,
                'Visit Date: ',
                widget.model.formattedRecordedDate,
                () async {
                  widget.model.updateWith(isLoading: true);
                  File file = widget.model.mediaInfo.file;
                  await VideoPlayer.show(
                    context: context,
                    file: file,
                    title: "Video Note",
                    fromNetwork: false,
                  );
                  widget.model.updateWith(isLoading: false);
                },
              ),
            SizedBox(height: 50),
            Center(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => _recordVideo(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 5.0, color: Colors.black12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      child: Container(
                        decoration: new BoxDecoration(
                          color: Colors.red,
                          shape: widget.model.isLoading
                              ? BoxShape.rectangle
                              : BoxShape.circle,
                          borderRadius: widget.model.isLoading
                              ? BorderRadius.all(Radius.circular(8.0))
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.model.isLoading) ...[
              SizedBox(height: 12),
              Center(
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 12),
            ],
            Expanded(
              child: ContinueButton(
                title: "Save and Continue",
                width: width,
                onTap: this.widget.model.minimumRequiredFieldsFilledOut
                    ? () async {
                        await _submit();
                      }
                    : null,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVideoCardNetworkButton(
      BuildContext context, String title, String subtitle, Function onTap) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Card(
        elevation: 2,
        borderOnForeground: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(15, 5, 5, 5),
          dense: true,
          leading: SizedBox(
            height: 50,
            width: 50,
            child: ThumbnailImage(
              videoUrl: widget.model.videoURL,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.caption,
          ),
          trailing: Icon(
            Icons.play_arrow_rounded,
            size: 50,
            color: Colors.teal,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildVideoCardMemoryButton(
      BuildContext context, String title, String subtitle, Function onTap) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Card(
        elevation: 2,
        borderOnForeground: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(15, 5, 5, 5),
          dense: true,
          leading: SizedBox(
            height: 50,
            width: 50,
            child: Icon(Icons.video_collection_rounded),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.caption,
          ),
          trailing: Icon(
            Icons.play_arrow_rounded,
            size: 50,
            color: Colors.teal,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Future<void> _recordVideo() async {
    PickedFile pickedFile;
    try {
      pickedFile = await widget.model.imagePicker.getVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxDuration: Duration(minutes: 3),
      );
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    if (!mounted) return;
    if (pickedFile != null && pickedFile.path != null) {
      widget.model.updateWith(isLoading: true);
      final MediaInfo info = await VideoCompress.compressVideo(
        pickedFile.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: true,
      );
      widget.model.updateWith(
        mediaInfo: info,
        isSubmitted: false,
        isLoading: false,
      );
    }
    AssetPicker.unregisterObserve();
  }
}
