import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

import 'grouped_checkbox.dart';

class QuestionForm extends StatefulWidget {
  final Question question;
  final QuestionsViewModel questionsViewModel;
  final ExtendedImageProvider extendedImageProvider;

  QuestionForm({
    @required this.question,
    @required this.questionsViewModel,
    @required this.extendedImageProvider,
  });

  static Widget create(BuildContext context, Question question,
      QuestionsViewModel questionsViewModel) {
    final ExtendedImageProvider extendedImageProvider =
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
  ExtendedImageProvider get extendedImageProvider =>
      widget.extendedImageProvider;

  Future<void> _loadProfileImage() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await this.extendedImageProvider.pickImages(
            model.questionPhotos,
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
    model.updateQuestionPageWith(questionPhotos: resultList);
  }

  @override
  Widget build(BuildContext context) {
    if (this.question.type == "FR") {
      return _buildFreeResponseOption(context);
    } else if (this.question.type == "MC") {
      return _buildMultipleChoiceOption(context);
    } else {
      double height = MediaQuery.of(context).size.height;
      if (model.questionPhotos.length == 0)
        return _buildPhotoOption(height: height);
      if (model.questionPhotos.length > 0)
        return _buildPhotoOptionWithExistingImage(
            asset: model.questionPhotos.first, height: height);
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
            activeColor: Colors.blueAccent,
            onChanged: model.checkedItemsChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFreeResponseOption(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildFRTextField(model),
      ],
    );
  }

  Widget _buildPhotoOption({double height}) {
    return Container(
      height: height * 0.5,
      width: MediaQuery.of(context).size.width,
      child: IconButton(
        onPressed: _loadProfileImage,
        icon: Icon(
          Icons.image,
          color: Colors.blue.withAlpha(140),
          size: height * 0.5,
        ),
      ),
    );
  }

  Widget _buildFRTextField(QuestionsViewModel model) {
    return TextField(
      controller: model.inputController,
      focusNode: model.inputFocusNode,
      autocorrect: false,
      keyboardType: TextInputType.multiline,
      maxLines: 8,
      onChanged: model.updateInput,
      style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        hintStyle: TextStyle(
          color: Color.fromRGBO(100, 100, 100, 1),
        ),
        filled: true,
        fillColor: Colors.grey.withAlpha(50),
        labelText: "Enter response",
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildPhotoOptionWithExistingImage({Asset asset, double height}) {
    return GestureDetector(
      onTap: _loadProfileImage,
      child: ClipRRect(
        child: this.extendedImageProvider.returnAssetThumb(
              asset: asset,
              quality: 25,
              height: (height * 0.5).toInt(),
              width: (height * 0.5).toInt(),
            ),
      ),
    );
  }
}
