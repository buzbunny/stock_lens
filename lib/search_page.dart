import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_call_manager.dart';
import 'coinModel.dart';
import 'navbar.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'item2.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isSearching = false;
  List<CoinModel>? searchResults;
  final TextEditingController _searchController = TextEditingController();
  bool _shouldRefresh = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    _shouldRefresh = true;
    _onSearch(_searchController.text);
  }

  Future<List<CoinModel>?> searchCoins(String query) async {
    final apiCallManager = Provider.of<ApiCallManager>(context, listen: false);
    if (!apiCallManager.canMakeApiCall) return null;

    apiCallManager.setCanMakeApiCall(false);

    List<CoinModel>? cachedResults = await _getFromCache(query);
    if (cachedResults != null && !_shouldRefresh) {
      return cachedResults;
    }

    const url = 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&sparkline=true';
    try {
      setState(() {
        isSearching = true;
      });

      var response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      });

      setState(() {
        isSearching = false;
      });

      if (response.statusCode == 200) {
        var coinList = coinModelFromJson(response.body);

        await _saveToCache(query, coinList);

        _shouldRefresh = false;

        return coinList.where((coin) => coin.name.toLowerCase().contains(query.toLowerCase())).toList();
      } else {
        print('API request failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isSearching = false;
      });
      return null;
    } finally {
      apiCallManager.setCanMakeApiCall(true);
      await _updateSearchFrequency(query);
    }
  }

  Future<void> _onSearch(String query) async {
    if (query.isNotEmpty) {
      var results = await searchCoins(query);
      setState(() {
        searchResults = results;
      });
    } else {
      setState(() {
        searchResults = null;
      });
    }
  }

  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;

    // Accessing color scheme
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LiquidPullToRefresh(
          onRefresh: () => _onSearch(_searchController.text),
          showChildOpacityTransition: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: myWidth * 0.05, vertical: myHeight * 0.02),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a coin...',
                    hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.primary,
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              isSearching
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                  : searchResults == null
                      ? Center(
                          child: Text(
                            'Search for a coin to see results',
                            style: TextStyle(fontSize: 18, color: colorScheme.onSurface),
                          ),
                        )
                      : searchResults!.isEmpty
                          ? Center(
                              child: Text(
                                'Coin doesn\'t exist.',
                                style: TextStyle(fontSize: 18, color: colorScheme.error),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: searchResults!.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Item2(item: searchResults![index])),
                                      );
                                    },
                                    child: Item2(
                                      item: searchResults![index],
                                    ),
                                  );
                                },
                              ),
                            ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    final apiCallManager = Provider.of<ApiCallManager>(context, listen: false);
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/');
      apiCallManager.setCanMakeApiCall(true);
    } else if (index == 4) {
      Navigator.pushNamed(context, '/settings');
      apiCallManager.setCanMakeApiCall(false);
    }
  }

  // Helper methods for caching

  static const String _cacheKeyPrefix = 'coin_search_cache_';
  static const String _frequencyKeyPrefix = 'coin_search_frequency_';

  Future<void> _saveToCache(String query, List<CoinModel> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonStringList = data.map((coin) => json.encode(coin.toJson())).toList();
    await prefs.setStringList(_cacheKeyPrefix + query.toLowerCase(), jsonStringList);
  }

  Future<List<CoinModel>?> _getFromCache(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList(_cacheKeyPrefix + query.toLowerCase());
    if (jsonStringList != null) {
      return jsonStringList.map((jsonString) => CoinModel.fromJson(json.decode(jsonString))).toList();
    }
    return null;
  }

  Future<void> _updateSearchFrequency(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = _frequencyKeyPrefix + query.toLowerCase();
    int frequency = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, frequency + 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (ModalRoute.of(context)?.isCurrent == true && _shouldRefresh) {
      _onSearch(_searchController.text);
    }
  }
}
