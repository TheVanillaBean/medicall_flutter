import 'package:Medicall/models/consult_status_modal.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';

class DetailedHistoryState with ChangeNotifier {
  User medicallUser;
  Database db;
  DetailedHistoryState({@required this.medicallUser, @required this.db});
  String documentId;
  TabController controller;
  double currentImageIndex = 0;
  int currentIndex = 0;
  Choice selectedStatus;
  List<Choice> choices = [];
  bool isDone = false;
  bool isConsultOpen = false;

  void setChoices() {
    choices = <Choice>[
      Choice(
          title: 'Done',
          icon: isDone
              ? Icon(Icons.check_box, color: Colors.green)
              : Icon(
                  Icons.check_box_outline_blank,
                  color: Colors.blue,
                )),
      Choice(
          title: 'Active',
          icon: !isDone
              ? Icon(Icons.check_box, color: Colors.green)
              : Icon(
                  Icons.check_box_outline_blank,
                  color: Colors.blue,
                )),
    ];
  }

  List<Choice> get getChoices => choices;
  Choice get getConsultStatus => selectedStatus;

  double get getDotsIndex => currentImageIndex;
  int get getCurrentIndex => currentIndex;
  bool get getIsConsultOpen => isConsultOpen;
  String get getDocumentId => documentId;
  TabController get getTabController => controller;

  _handleTabSelection() {
    updateWith(currentIndex: controller.index);
  }

  void setControllerTabs(dis) {
    if (controller == null) {
      setTabController(dis);
      controller.addListener(_handleTabSelection);
    }
  }

  void setTabController(dis) {
    controller = TabController(length: 3, vsync: dis);
  }

  void updateWith({
    double currentImageIndex,
    int currentIndex,
    Choice selectedStatus,
    bool isDone,
    bool isConsultOpen,
  }) {
    this.currentImageIndex = currentImageIndex ?? this.currentImageIndex;
    this.currentIndex = currentIndex ?? this.currentIndex;
    this.selectedStatus = selectedStatus ?? this.selectedStatus;
    this.isDone = isDone ?? this.isDone;
    this.isConsultOpen = isConsultOpen ?? this.isConsultOpen;
    notifyListeners();
  }

  setConsultStatus(consultSnapshot, val, uid, updateConsultStatus) async {
    // Causes the app to rebuild with the new _selectedChoice.
    //setChoices();
    selectedStatus = val;
    if (consultSnapshot.data['provider_id'] == uid) {
      if (val.title.toLowerCase() == 'done') {
        selectedStatus.icon = Icon(Icons.check_box, color: Colors.green);
        consultSnapshot.data['state'] = 'done';
      } else {
        selectedStatus.icon = Icon(
          Icons.check_box_outline_blank,
          color: Colors.blue,
        );
        consultSnapshot.data['state'] = 'in progress';
      }
      updateConsultStatus(selectedStatus, uid);
    }
  }
}
