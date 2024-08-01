import 'package:flutter/material.dart';

class ApiCallManager with ChangeNotifier {
  bool _canMakeApiCall = true;

  bool get canMakeApiCall => _canMakeApiCall;

  void setCanMakeApiCall(bool value) {
    _canMakeApiCall = value;
    notifyListeners();
  }
}
