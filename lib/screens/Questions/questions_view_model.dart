import 'package:Medicall/models/option_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class QuestionsViewModel with ChangeNotifier {
  final AuthBase auth;

  double _progress = 0;
  Option _selected;

  final PageController controller = PageController();

  QuestionsViewModel({
    @required this.auth,
  });

  get progress => _progress;
  get selected => _selected;

  set progress(double newValue) {
    _progress = newValue;
    notifyListeners();
  }

  set selected(Option newValue) {
    _selected = newValue;
    notifyListeners();
  }

  void nextPage() async {
    await controller.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }
}
