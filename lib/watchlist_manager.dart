import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coinModel.dart'; // Adjust the import path as necessary

class WatchlistManager with ChangeNotifier {
  static final WatchlistManager _instance = WatchlistManager._internal();

  factory WatchlistManager() {
    return _instance;
  }

  WatchlistManager._internal() {
    loadFromPreferences();
  }

  final List<CoinModel> _watchedCoins = [];

  List<CoinModel> get watchedCoins => _watchedCoins;

  Future<void> addCoin(CoinModel coin) async {
    if (!_watchedCoins.contains(coin)) {
      _watchedCoins.add(coin);
      await _saveToPreferences();
      notifyListeners();
    }
  }

  Future<void> removeCoin(CoinModel coin) async {
    _watchedCoins.remove(coin);
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonData = _watchedCoins.map((coin) => coin.toJson()).toList();
    final String encodedData = jsonEncode(jsonData);
    await prefs.setString('watchedCoins', encodedData);
  }

  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('watchedCoins');
    if (encodedData != null) {
      final List<dynamic> jsonData = jsonDecode(encodedData);
      _watchedCoins.clear();
      _watchedCoins.addAll(jsonData.map((data) => CoinModel.fromJson(data)).toList());
    }
    notifyListeners();
  }
}
