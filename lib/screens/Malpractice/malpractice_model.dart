import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/temp_user_provider.dart';

class MalpracticeScreenModel {
  TempUserProvider tempUserProvider;
  MedicallUser medicallUser;

  void setTempUserProvider(TempUserProvider tempUserProvider) {
    this.tempUserProvider = tempUserProvider;
    this.medicallUser = this.tempUserProvider.medicallUser;
  }

  MalpracticeScreenModel();
}
