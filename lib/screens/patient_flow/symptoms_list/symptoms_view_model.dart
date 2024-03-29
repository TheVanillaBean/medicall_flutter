import 'dart:async';

import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:flutter/cupertino.dart';

class SymptomsViewModel with ChangeNotifier {
  final NonAuthDatabase database;

  // ignore: close_sinks
  StreamController<List<Symptom>> symptomsStream = StreamController();

  List<Symptom> cosmeticSymptoms;

  SymptomsViewModel({
    @required this.database,
  }) {
    symptomsStream.add([]);
    database.symptomsStream().listen((symptomsSnapshot) {
      List<Symptom> symptoms = symptomsSnapshot
          .where(
            (element) =>
                element.category == "hairloss" ||
                element.category == "spots" ||
                element.category == "rosacea" ||
                element.category == "rash" ||
                element.category == "acne",
          )
          .toList();
      this.cosmeticSymptoms = symptomsSnapshot
          .where((element) => element.category == "cosmetic")
          .toList();
      Symptom cosmeticSymptom = Symptom(
        name: "Cosmetic Skin Issues",
        commonMedications: "",
        description: "Various symptoms related to cosmetic skin issues",
        duration: "Depends on the issue",
        price: 0,
        category: "cosmetic",
      );
      symptoms.add(cosmeticSymptom);
      symptomsStream.add(symptoms);
    });
  }
}
