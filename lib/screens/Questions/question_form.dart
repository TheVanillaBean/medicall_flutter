import 'dart:typed_data';

import 'package:Medicall/common_widgets/camera/Camera.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

import 'grouped_checkbox.dart';

class QuestionForm extends StatefulWidget {
  final Question question;
  final QuestionsViewModel questionsViewModel;
  final ExtImageProvider extendedImageProvider;

  QuestionForm({
    @required this.question,
    @required this.questionsViewModel,
    @required this.extendedImageProvider,
  });

  static Widget create(BuildContext context, Question question,
      QuestionsViewModel questionsViewModel) {
    final ExtImageProvider extendedImageProvider =
        Provider.of<ExtImageProvider>(context);
    return PropertyChangeConsumer<QuestionsViewModel>(
      properties: [QuestionVMProperties.questionFormWidget],
      builder: (context, model, properties) {
        return QuestionForm(
          question: question,
          questionsViewModel: questionsViewModel,
          extendedImageProvider: extendedImageProvider,
        );
      },
    );
  }

  @override
  _QuestionFormState createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  Question get question => widget.question;
  QuestionsViewModel get model => widget.questionsViewModel;
  ExtImageProvider get extendedImageProvider => widget.extendedImageProvider;

  bool isLoading = false;

  Future<void> _loadProfileImage() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await this.extendedImageProvider.pickImages(
        [],
        question.maxImages,
        true,
        this
            .extendedImageProvider
            .pickImagesCupertinoOptions(takePhotoIcon: 'camera'),
        this.extendedImageProvider.pickImagesMaterialOptions(
            useDetailsView: true,
            actionBarColor:
                '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
            statusBarColor:
                '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
            lightStatusBar: false,
            autoCloseOnSelectionLimit: true,
            startInAllView: true,
            actionBarTitle: 'Select photo(s) for consult',
            allViewTitle: 'All Photos'),
        context,
      );
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    List<Map<String, ByteData>> resultMap = [];
    for (Asset asset in resultList) {
      ByteData byteData =
          await FirebaseStorageService.getAccurateByteData(asset);
      String assetPath =
          await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
      resultMap.add({assetPath: byteData});
    }
    setState(() {
      isLoading = false;
    });
    model.updateQuestionPageWith(questionPhotos: resultMap);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (this.question.type == Q_TYPE.FR) {
      return _buildFreeResponseOption(context);
    } else if (this.question.type == Q_TYPE.MC) {
      return _buildMultipleChoiceOption(context);
    } else if (this.question.type == Q_TYPE.SC) {
      return _buildSingleChoiceOption(context);
    } else {
      double height = MediaQuery.of(context).size.height;
      if (model.questionPhotos.length == 0)
        return _buildPhotoOption(height: height);
      if (model.questionPhotos.length > 0)
        return _buildPhotoOptionWithExistingImage(height: height);
      return Container();
    }
  }

  Widget _buildMultipleChoiceOption(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 9,
          child: GroupedCheckbox(
            itemList: model.optionsList,
            checkedItemList: model.selectedOptionsList,
            orientation: CheckboxOrientation.VERTICAL,
            checkColor: Colors.white,
            textStyle: Theme.of(context).textTheme.bodyText1,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: model.checkedItemsChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleChoiceOption(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 9,
          child: RadioButtonGroup(
            labelStyle: Theme.of(context).textTheme.bodyText1,
            activeColor: Theme.of(context).colorScheme.primary,
            labels: model.optionsList,
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            picked: model.selectedOptionsList.length > 0
                ? model.selectedOptionsList.first
                : null,
            onSelected: (String selected) {
              model.checkedItemsChanged([selected]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFreeResponseOption(BuildContext context) {
    return _buildFRTextField(model);
  }

  Widget _buildFRTextField(QuestionsViewModel model) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Scrollbar(
        child: TextField(
          textCapitalization: TextCapitalization.sentences,
          controller: model.inputController,
          focusNode: model.inputFocusNode,
          autocorrect: true,
          keyboardType: TextInputType.multiline,
          maxLines: 30,
          onChanged: model.updateInput,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            hintStyle: TextStyle(
              color: Color.fromRGBO(100, 100, 100, 1),
            ),
            filled: false,
            fillColor: Colors.grey.withAlpha(50),
            labelText: "Enter response",
            alignLabelWithHint: true,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOption({double height}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 9,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen.create(context, model, {
                      'fullscreen': true,
                      'video': false,
                      'max_images': question.maxImages
                    }),
                  ));
            },
            child: ClipRRect(
              child: model.questionPlaceholderURL.length > 0
                  ? this.extendedImageProvider.returnNetworkImage(
                        model.questionPlaceholderURL,
                        mode: ExtendedImageMode.none,
                        fit: BoxFit.fitWidth,
                        height: (height * 0.5),
                        width: (height * 0.5),
                      )
                  : Icon(
                      Icons.add_a_photo,
                      color: Theme.of(context).colorScheme.primary,
                      size: height * 0.25,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoOptionWithExistingImage({double height}) {
    return Column(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen.create(context, model, {
                      'fullscreen': true,
                      'video': false,
                      'max_images': question.maxImages
                    }),
                  ));
            },
            child: ClipRRect(
              child: Container(
                child: PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: MemoryImage(model
                          .questionPhotos[index].values.first.buffer
                          .asUint8List()),
                      initialScale: PhotoViewComputedScale.contained,
                      tightMode: true,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 4,
                    );
                  },
                  gaplessPlayback: true,
                  itemCount: model.questionPhotos.length,
                  loadingBuilder: (context, event) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  backgroundDecoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                  ),
                  onPageChanged: (page) {
                    model.updateDotsIndicator(page.toDouble());
                  },
                ),
              ),
            ),
          ),
        ),
        if (model.questionPhotos.length > 1)
          Container(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DotsQuestionnaireWidget(),
            ),
          ),
      ],
    );
  }
}

class DotsQuestionnaireWidget extends StatelessWidget {
  const DotsQuestionnaireWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final QuestionsViewModel model =
        PropertyChangeProvider.of<QuestionsViewModel>(
      context,
      properties: [QuestionVMProperties.questionDots],
    ).value;
    return DotsIndicator(
      dotsCount: model.questionPhotos.length,
      position: model.imageIndex,
      decorator:
          DotsDecorator(activeColor: Theme.of(context).colorScheme.secondary),
    );
  }
}
