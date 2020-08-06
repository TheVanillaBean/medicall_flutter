import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/consult_photos_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

class ConsultPhotos extends StatelessWidget {
  final ConsultPhotosViewModel model;

  const ConsultPhotos({@required this.model});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitConsultPhotos,
      arguments: {
        'consult': consult,
      },
    );
  }

  static Widget create(
    BuildContext context,
    Consult consult,
  ) {
    return PropertyChangeProvider(
      value: ConsultPhotosViewModel(consult: consult),
      child: PropertyChangeConsumer<ConsultPhotosViewModel>(
        properties: [ConsultPhotosProperties.photoRoot],
        builder: (context, model, properties) {
          return ConsultPhotos(
            model: model,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        centerTitle: true,
        title: Text("Visit Photos"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: _buildPhotoGallery(db),
        ),
      ),
    );
  }

  Widget _buildPhotoGallery(FirestoreDatabase db) {
    return FutureBuilder<ScreeningQuestions>(
      future: db.consultQuestionnaire(consultId: model.consult.uid),
      builder:
          (BuildContext context, AsyncSnapshot<ScreeningQuestions> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData) {
            List<Question> photoQuestions = snapshot.data.screeningQuestions
                .where((element) => element.type == Q_TYPE.PHOTO)
                .toList();
            List<String> photoURLS = [];
            photoQuestions.forEach((question) {
              question.answer.answer.forEach((url) {
                photoURLS.add(url);
              });
            });
            if (photoQuestions.length == 0) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "There are no photos for this visit.",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }
            this.model.imagesCount = photoURLS.length.toDouble();
            return Column(
              children: <Widget>[
                Expanded(
                  child: PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: CachedNetworkImageProvider(
                          photoURLS[index],
                        ),
                        initialScale: PhotoViewComputedScale.contained,
                        tightMode: true,
                        minScale: PhotoViewComputedScale.contained,
                      );
                    },
                    gaplessPlayback: true,
                    itemCount: photoURLS.length,
                    loadingBuilder: (context, event) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    backgroundDecoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                    ),
                    onPageChanged: (page) => model.updateDotsIndicator(
                      index: page.toDouble(),
                    ),
                  ),
                ),
                if (photoURLS.length > 1)
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: DotsReviewWidget(),
                    ),
                  ),
              ],
            );
          } else {
            return Center(
              child: Text("Photos could not be retrieved..."),
            );
          }
        }
      },
    );
  }
}

class DotsReviewWidget extends StatelessWidget {
  const DotsReviewWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConsultPhotosViewModel model =
        PropertyChangeProvider.of<ConsultPhotosViewModel>(
      context,
      properties: [ConsultPhotosProperties.photoDots],
    ).value;
    return DotsIndicator(
      dotsCount: model.imagesCount.toInt(),
      position: model.imageIndex,
      decorator: DotsDecorator(
        activeColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
