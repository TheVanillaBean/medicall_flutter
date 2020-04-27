import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/introduction_screen/model/page_view_model.dart';
import 'package:Medicall/util/introduction_screen/ui/intro_content.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  final PageViewModel page;

  const IntroPage({Key key, @required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: page.decoration.pageColor,
      decoration: page.decoration.boxDecoration,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (page.image != null)
              Expanded(
                flex: page.decoration.imageFlex,
                child: Padding(
                  padding: page.decoration.imagePadding,
                  child: page.image,
                ),
              ),
            Expanded(
              flex: page.decoration.bodyFlex,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 70.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: FadeInPlace(
                    2.0,
                    IntroContent(page: page),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
