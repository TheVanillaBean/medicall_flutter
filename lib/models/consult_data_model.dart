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

  ConsultData.fromJson(Map<List, dynamic> json)
      : consultType = json['consultType'],
        provider = json['provider'],
        providerId = json['providerId'],
        patientDevTokens = json['patientDevTokens'],
        providerDevTokens = json['providerDevTokens'],
        stringListQuestions = json['stringListQuestions'],
        screeningQuestions = json['screeningQuestions'],
        historyQuestions = json['historyQuestions'],
        media = json['media'];

  Map<String, dynamic> toJson() => {
        'consultType': consultType,
        'provider': provider,
        'providerId': providerId,
        'patientDevTokens': patientDevTokens,
        'providerDevTokens': providerDevTokens,
        'stringListQuestions': stringListQuestions,
        'screeningQuestions': screeningQuestions,
        'historyQuestions': historyQuestions,
        'media': media,
      };
}
