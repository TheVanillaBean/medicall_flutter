import 'package:Medicall/models/consult_status_modal.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';

class DetailedHistoryState with ChangeNotifier {
  DetailedHistoryState();

  double _currentImageIndex = 0;
  Choice _selectedStatus;
  Database _db;
  TabController _controller;
  int _currentIndex = 0;

  bool _isConsultOpen = false;

  String _documentId;
  bool _isDone = false;

  List<Choice> _choices = [];

  void setChoices() {
    _choices = <Choice>[
      Choice(
          title: 'Done',
          icon: _isDone
              ? Icon(Icons.check_box, color: Colors.green)
              : Icon(
                  Icons.check_box_outline_blank,
                  color: Colors.blue,
                )),
      Choice(
          title: 'Active',
          icon: !_isDone
              ? Icon(Icons.check_box, color: Colors.green)
              : Icon(
                  Icons.check_box_outline_blank,
                  color: Colors.blue,
                )),
    ];
  }

  List<Choice> get getChoices => _choices;
  Choice get getConsultStatus => _selectedStatus;
  double get getDotsIndex => _currentImageIndex;
  int get getCurrentIndex => _currentIndex;
  bool get getIsConsultOpen => _isConsultOpen;
  String get getDocumentId => _documentId;
  TabController get getTabController => _controller;

  _handleTabSelection() {
    _currentIndex = _controller.index;
  }

  void setControllerTabs(dis) {
    if (_controller == null) {
      setTabController(dis);
      _controller.addListener(_handleTabSelection);
    }
  }

  void setTabController(dis) {
    _controller = TabController(length: 3, vsync: dis);
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
  }

  void setIsConsultOpen(bool isOpen) {
    _isConsultOpen = isOpen;
  }

  void setDocumentId(String id) {
    _documentId = id;
  }

  void setDotsIndex(double index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  void setIsDone(bool isDone) {
    _isDone = isDone;
  }

  setConsultStatus(MedicallUser user) async {
    // Causes the app to rebuild with the new _selectedChoice.
    _db.updateConsultStatus(_selectedStatus, user);
    if (_db.consultSnapshot.data['provider_id'] == medicallUser.uid) {
      if (_selectedStatus.title == 'Done') {
        _selectedStatus.icon = Icon(Icons.check_box, color: Colors.green);
        _db.consultSnapshot.data['state'] = 'done';
      } else {
        _selectedStatus.icon = Icon(
          Icons.check_box_outline_blank,
          color: Colors.blue,
        );
        _db.consultSnapshot.data['state'] = 'in progress';
      }
    }
  }
}
