import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';

class AcceptedInsurancesViewModel with ChangeNotifier {
  final FirestoreDatabase firestoreDatabase;
  final UserProvider userProvider;

  bool isLoading;
  bool submitted;

  List<String> selectInsurances = [
    'UnitedHealthcare',
    'BlueCrossBlueShield',
    'Aetna',
    'Anthem',
    'Humana',
    'Cigna',
  ];

  List<String> acceptedInsurances = [];

  AcceptedInsurancesViewModel({
    @required this.firestoreDatabase,
    @required this.userProvider,
    this.isLoading = false,
    this.submitted = false,
  }) {
    this.initFromFirestore();
  }

  void initFromFirestore() {
    this.acceptedInsurances =
        (this.userProvider.user as ProviderUser).acceptedInsurances;
  }

  bool get canSubmit {
    return acceptedInsurances.length > 0 && !isLoading;
  }

  Future<void> saveInsurances() async {
    updateWith(submitted: true, isLoading: true);
    ProviderUser user = userProvider.user;

    await updateUser(user);

    updateWith(submitted: false, isLoading: false);
  }

  void updateWith({
    List<String> acceptedInsurances,
    bool submitted,
    bool isLoading,
  }) {
    this.acceptedInsurances = acceptedInsurances ?? this.acceptedInsurances;
    this.submitted = submitted ?? this.submitted;
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }

  Future<void> updateUser(ProviderUser user) async {
    user.acceptedInsurances = this.acceptedInsurances;
    await firestoreDatabase.setUser(user);
    userProvider.user = user;
  }
}
