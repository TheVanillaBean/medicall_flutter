buildMedicalNote(snapshot, patientDetail, medicalHistory) {
  medicalHistory = medicalHistory['medical_history_questions'];
  String fullStr = '';
  if (snapshot['type'] == 'Hairloss') {
    fullStr += '\nCC: ' +
        snapshot['type'] +
        '\n\n' +
        'HPI: ' +
        (DateTime.now().year - int.parse(patientDetail.dob.split('-')[2]))
            .toString() +
        ' year old ' +
        patientDetail.gender +
        ' complains of ' +
        snapshot['type'] +
        '.  This has been present for ' +
        snapshot['screening_questions'][0]['answer'].toString();
    if (patientDetail != null &&
        snapshot['screening_questions'][1]['answer'] != null) {
      fullStr += '.\n\nThe patient complains of ' +
          snapshot['screening_questions'][1]['answer'].toString() +
          '.\nThe patient has tried ' +
          snapshot['screening_questions'][2]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][3]['answer'] != null) {
      fullStr += '.  Minoxidil or Rogaine used for: ' +
          snapshot['screening_questions'][3]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][4]['answer'] != null) {
      fullStr += snapshot['screening_questions'][4]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][5]['answer'] != null) {
      fullStr += snapshot['screening_questions'][5]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][6]['answer'] != null) {
      fullStr += '\n\nPatient has history of family hairloss on: ' +
          snapshot['screening_questions'][7]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][8]['answer'] != null) {
      fullStr += '  Patient has sexual dysfunction and notes: [' +
          snapshot['screening_questions'][9]['answer'].toString() +
          ']';
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][10]['answer'] != null) {
      fullStr += '  Associated symptoms: ' +
          snapshot['screening_questions'][10]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][11]['answer'] != null) {
      fullStr += '\n\nPatient has seen doctor for psoriasis ' +
          snapshot['screening_questions'][11]['answer'].toString() +
          ', treatments include ' +
          snapshot['screening_questions'][12]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][13]['answer'] != null) {
      fullStr += '  Patient has seen doctor for eczema ' +
          snapshot['screening_questions'][13]['answer'].toString() +
          ', treatments include ' +
          snapshot['screening_questions'][14]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][15]['answer'] != null) {
      fullStr += '  Other treatments ' +
          snapshot['screening_questions'][15]['answer'].toString();
    }
  }
  if (snapshot['type'] == 'Lesion') {
    fullStr += '\nCC: Spot' +
        '\n\n' +
        'HPI: ' +
        (DateTime.now().year - int.parse(patientDetail.dob.split('-')[2]))
            .toString() +
        ' year old ' +
        patientDetail.gender +
        ' complains of Spot' +
        '.  This has been present for ' +
        snapshot['screening_questions'][0]['answer'].toString();
    if (patientDetail != null &&
        snapshot['screening_questions'][1]['answer'] != null) {
      fullStr += '.\n\nThe patient complains of ' +
          snapshot['screening_questions'][1]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][2]['answer'][0] != null) {
      fullStr += '.\n\nDiagnoised with skin cancer ' +
          snapshot['screening_questions'][2]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][3]['answer'][0] != null) {
      fullStr += '.\n\nPatient has melanoma in family history ' +
          snapshot['screening_questions'][3]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][4]['answer'][0] != null) {
      fullStr += '.\n\nOn medication that decreases immune system ' +
          snapshot['screening_questions'][4]['answer'].toString();
    }
    if (patientDetail != null &&
        snapshot['screening_questions'][5]['answer'] != null) {
      fullStr += '.\n\nPatient notes: ' +
          snapshot['screening_questions'][5]['answer'].toString();
    }
  }
  if (medicalHistory != null) {
    fullStr += '\n\nMedications: \n' +
        medicalHistory[4]['answer'].toString() +
        ' ' +
        medicalHistory[5]['answer'].toString();
    fullStr += '\n\nAllergies: \n' +
        medicalHistory[6]['answer'].toString() +
        ' ' +
        medicalHistory[7]['answer'].toString();
    fullStr += '\n\nPast medical history: \n';
    // medicalHistory[2]['answer'].toString() +
    // ' ' +
    // medicalHistory[3]['answer'].toString() +
    // ' ' +
    // medicalHistory[13]['answer'].toString();
    if (medicalHistory[0]['answer'][0].toString() == 'Yes') {
      fullStr += medicalHistory[1]['answer'].toString();
    }
    fullStr += medicalHistory[2]['answer'].toString() +
        ' ' +
        medicalHistory[3]['answer'].toString() +
        ' ' +
        medicalHistory[13]['answer'].toString();
    return fullStr;
  }
}
