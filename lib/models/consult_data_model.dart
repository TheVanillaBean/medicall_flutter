import 'package:multi_image_picker/multi_image_picker.dart';

class ConsultData {
  String consultType;
  List<dynamic> screeningQuestions;
  List<dynamic> stringListQuestions;
  String provider;
  String providerId;
  List<dynamic> patientDevTokens;
  List<dynamic> providerDevTokens;
  List<dynamic> historyQuestions;
  List<Asset> media;

  ConsultData({
    this.consultType,
    this.screeningQuestions,
    this.stringListQuestions,
    this.provider,
    this.providerId,
    this.patientDevTokens,
    this.providerDevTokens,
    this.historyQuestions,
    this.media,
  });
}
