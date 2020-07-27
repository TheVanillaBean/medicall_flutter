class TreatmentOptions {
  String dose;
  String form;
  String frequency;
  String instructions;
  String medicationName;
  String quantity;
  String refills;

  TreatmentOptions({
    this.dose,
    this.form,
    this.frequency,
    this.instructions,
    this.medicationName,
    this.quantity,
    this.refills,
  });

  factory TreatmentOptions.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    final String medicationName = data['medication_name'] as String ?? "";
    final String dose = data['dose'] as String ?? "";
    final String form = data['form'] as String ?? "";
    final String frequency = data['frequency'] as String ?? "";
    final String instructions = data['instructions'] as String ?? "";
    final String quantity = data['quantity'] as String ?? "";
    final String refills = data['refills'] as String ?? "";

    return TreatmentOptions(
      medicationName: medicationName,
      dose: dose,
      form: form,
      frequency: frequency,
      instructions: instructions,
      quantity: quantity,
      refills: refills,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'medication_name': medicationName,
      'dose': dose,
      'form': form,
      'frequency': frequency,
      'instructions': instructions,
      'quantity': quantity,
      'refills': refills,
    };
  }
}
