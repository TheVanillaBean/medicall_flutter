class ConsultData {
  String consultType;
  List<dynamic> screeningQuestions;
  List<dynamic> uploadQuestions;
  List<dynamic> stringListQuestions;
  String provider;
  String providerTitles;
  String providerId;
  String providerProfilePic;
  String providerAddress;
  String price;
  List<dynamic> patientDevTokens;
  List<dynamic> providerDevTokens;
  List<dynamic> historyQuestions;
  List media;
  String desc;

  ConsultData(
      {this.consultType,
      this.screeningQuestions,
      this.uploadQuestions,
      this.stringListQuestions,
      this.provider,
      this.providerTitles,
      this.providerId,
      this.price,
      this.patientDevTokens,
      this.providerDevTokens,
      this.providerProfilePic,
      this.providerAddress,
      this.historyQuestions,
      this.media,
      this.desc});

  ConsultData.fromJson(Map<List, dynamic> json)
      : consultType = json['consultType'],
        provider = json['provider'],
        providerTitles = json['providerTitles'],
        providerId = json['providerId'],
        providerProfilePic = json['providerProfilePic'],
        providerAddress = json['providerAddress'],
        price = json['price'],
        patientDevTokens = json['patientDevTokens'],
        providerDevTokens = json['providerDevTokens'],
        stringListQuestions = json['stringListQuestions'],
        screeningQuestions = json['screeningQuestions'],
        uploadQuestions = json['uploadQuestions'],
        historyQuestions = json['historyQuestions'],
        media = json['media'],
        desc = json['desc'];

  Map<String, dynamic> toJson() => {
        'consultType': consultType,
        'provider': provider,
        'providerTitles': providerTitles,
        'providerId': providerId,
        'providerProfilePic': providerProfilePic,
        'providerAddress': providerAddress,
        'price': price,
        'patientDevTokens': patientDevTokens,
        'providerDevTokens': providerDevTokens,
        'stringListQuestions': stringListQuestions,
        'screeningQuestions': screeningQuestions,
        'uploadQuestions': uploadQuestions,
        'historyQuestions': historyQuestions,
        'media': media,
        'desc': desc,
      };
}
