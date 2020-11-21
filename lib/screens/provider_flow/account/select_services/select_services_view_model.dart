import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';

class SelectServicesViewModel with ChangeNotifier {
  final FirestoreDatabase firestoreDatabase;
  final UserProvider userProvider;

  bool isLoading;
  bool submitted;

  List<String> selectServices = [
    'Acne',
    'Hairloss',
    'Rash',
    'Rosacea',
    'Skin spots',
    'Cosmetic skin issues',
  ];
  List<String> selectedServices = [];

  SelectServicesViewModel({
    @required this.firestoreDatabase,
    @required this.userProvider,
    this.isLoading = false,
    this.submitted = false,
  }) {
    this.initFromFirestore();
  }

  void initFromFirestore() {
    this.selectedServices =
        (this.userProvider.user as ProviderUser).selectedServices;
  }

  bool get canSubmit {
    return selectedServices.length > 0 && !isLoading;
  }

  Future<void> saveServices() async {
    updateWith(submitted: true, isLoading: true);
    ProviderUser user = userProvider.user;

    await updateUser(user);

    updateWith(submitted: false, isLoading: false);
  }

  void updateWith({
    List<String> selectedServices,
    bool submitted,
    bool isLoading,
  }) {
    this.selectedServices = selectedServices ?? this.selectedServices;
    this.submitted = submitted ?? this.submitted;
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }

  Future<void> updateUser(ProviderUser user) async {
    user.selectedServices = this.selectedServices;
    await firestoreDatabase.setUser(user);
    userProvider.user = user;
  }
}
