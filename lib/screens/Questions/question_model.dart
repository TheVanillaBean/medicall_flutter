class Question {
  final String question;
  dynamic userData;
  final List<String> options;
  final String type;

  Question({
    this.question,
    this.userData,
    this.options,
    this.type
  });
}

class Questions {
  final List<Question> questions;

  Questions({
    this.questions,
  });
}