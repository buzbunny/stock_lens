import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coinModel.dart';
import '../sub_pages/item.dart';
import '../sub_pages/item2.dart';
import '../widgets/navbar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isRefreshing = true;
  List? coinMarket = [];
  static const String cacheKey = 'coinMarketCache';
  String? _username;

  @override
  void initState() {
    super.initState();
    loadCachedData();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(cacheKey);

    if (cachedData != null) {
      setState(() {
        coinMarket = coinModelFromJson(cachedData);
        isRefreshing = false;
      });
    } else {
      await getCoinMarket();
    }
  }

  Future<void> getCoinMarket() async {
    const url = 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&sparkline=true';
    setState(() {
      isRefreshing = true;
    });
    try {
      var response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        var responseBody = response.body;
        var coinMarketList = coinModelFromJson(responseBody);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, responseBody);

        setState(() {
          coinMarket = coinMarketList;
          isRefreshing = false;
        });
      } else {
        print(response.statusCode);
        setState(() {
          isRefreshing = false;
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isRefreshing = false;
      });
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, '/search');
    }
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: _selectedIndex == 0
            ? LiquidPullToRefresh(
                onRefresh: getCoinMarket,
                showChildOpacityTransition: false,
                child: Container(
                  height: myHeight,
                  width: myWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.background,
                          Theme.of(context).colorScheme.surface,
                        ]),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HeaderSection(myHeight: myHeight, myWidth: myWidth, username: _username),
                      ActiveStockSection(isRefreshing: isRefreshing, coinMarket: coinMarket, myHeight: myHeight, myWidth: myWidth),
                      WatchlistSection(isRefreshing: isRefreshing, coinMarket: coinMarket, myHeight: myHeight, myWidth: myWidth),
                    ],
                  ),
                ),
              )
            : Center(
                child: Text(
                  _selectedIndex == 1 ? 'Search Screen' : '',
                  style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.onBackground),
                ),
              ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    Key? key,
    required this.myHeight,
    required this.myWidth,
    required this.username,
  }) : super(key: key);

  final double myHeight;
  final double myWidth;
  final String? username;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: myHeight * 0.03),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: myWidth * 0.07),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome ${username ?? 'User'}!',
                      style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onBackground),
                    ),
                    SizedBox(height: myHeight * 0.01),
                    Text(
                      'STOCKLENS',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      'Active markets',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveStockSection extends StatelessWidget {
  const ActiveStockSection({
    Key? key,
    required this.isRefreshing,
    required this.coinMarket,
    required this.myHeight,
    required this.myWidth,
  }) : super(key: key);

  final bool isRefreshing;
  final List? coinMarket;
  final double myHeight;
  final double myWidth;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: isRefreshing
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : coinMarket == null || coinMarket!.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(myHeight * 0.06),
                  child: Center(
                    child: Text(
                      'Attention: This API is free, so you cannot send multiple requests per second. Please wait and try again later.',
                      style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: coinMarket!.length,
                  itemBuilder: (context, index) {
                    return Item(
                      item: coinMarket![index],
                    );
                  },
                ),
    );
  }
}

class WatchlistSection extends StatelessWidget {
  const WatchlistSection({
    Key? key,
    required this.isRefreshing,
    required this.coinMarket,
    required this.myHeight,
    required this.myWidth,
  }) : super(key: key);

  final bool isRefreshing;
  final List? coinMarket;
  final double myHeight;
  final double myWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Reduced height for the watchlist section
      child: Padding(
        padding: EdgeInsets.only(left: myWidth * 0.03),
        child: isRefreshing
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : coinMarket == null || coinMarket!.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(myHeight * 0.06),
                    child: Center(
                      child: Text(
                        'Attention: This API is free, so you cannot send multiple requests per second. Please wait and try again later.',
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: coinMarket!.length,
                    itemBuilder: (context, index) {
                      return Item2(
                        item: coinMarket![index],
                      );
                    },
                  ),
      ),
    );
  }
}
