import 'package:Medicall/common_widgets/assets_picker/widget/asset_picker.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/video_to_patient_step_state.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            if (widget.model.assetEntity != null)
              _buildVideoCardButton(
                context,
                'Recorded on:',
                'Nov 6, 2020, 2:30p',
                null,
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
                        await widget.model.visitReviewViewModel
                            .saveVideoNoteToFirestore(widget.model);
                        widget.model.visitReviewViewModel.incrementIndex();
                      }
                    : null,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVideoCardButton(
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
            child: Image.network('https://picsum.photos/250?image=9'),
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
    AssetPicker.registerObserve();

    try {
      widget.model.assetEntity =
          await ImagePicker.recordVideo(context: context);
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    if (!mounted) return;
    if (widget.model.assetEntity.id != null) {
      widget.model.updateWith(isLoading: true);
      String url = await widget.model.storageService.uploadPatientNoteVideo(
        asset: widget.model.assetEntity,
        consultId: widget.model.visitReviewViewModel.consult.uid,
      );
      widget.model.updateWith(isLoading: false);
      widget.model.updateWith(videoURL: url);
    }
    AssetPicker.unregisterObserve();
  }
}
