import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class ConsultPhotos extends StatelessWidget {
  final Consult consult;

  const ConsultPhotos({@required this.consult});

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
      future: db.consultQuestionnaire(consultId: consult.uid),
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
            return PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(photoURLS[index]),
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
