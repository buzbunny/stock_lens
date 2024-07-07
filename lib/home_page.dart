import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coinModel.dart';
import 'item.dart';
import 'item2.dart';
import 'navbar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isRefreshing = true;
  List? coinMarket = [];
  static const String cacheKey = 'coinMarketCache';

  @override
  void initState() {
    super.initState();
    loadCachedData();
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
    } else if (index == 2) {
      Navigator.pushNamed(context, '/settings');
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
                        colors: [Colors.black, Colors.grey[900]!]),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HeaderSection(myHeight: myHeight, myWidth: myWidth),
                      ActiveStockSection(isRefreshing: isRefreshing, coinMarket: coinMarket, myHeight: myHeight, myWidth: myWidth),
                      WatchlistSection(isRefreshing: isRefreshing, coinMarket: coinMarket, myHeight: myHeight, myWidth: myWidth),
                    ],
                  ),
                ),
              )
            : Center(
                child: Text(
                  _selectedIndex == 1 ? 'Search Screen' : 'Settings Screen',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
      ),
      bottomNavigationBar: CustomNavBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    Key? key,
    required this.myHeight,
    required this.myWidth,
  }) : super(key: key);

  final double myHeight;
  final double myWidth;

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
                      'Good Morning Julian!',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(height: myHeight * 0.01),
                    Text(
                      'IDR 12.480.000',
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '+ IDR 6.000.000 (108%)',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 30),
                    SizedBox(height: myHeight * 0.02),
                    Icon(Icons.history, color: Colors.white, size: 30),
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
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : coinMarket == null || coinMarket!.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(myHeight * 0.06),
                  child: const Center(
                    child: Text(
                      'Attention this API is free, so you cannot send multiple requests per second, please wait and try again later.',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
      height: 130, // Reduced height for the watchlist section
      child: Padding(
        padding: EdgeInsets.only(left: myWidth * 0.03),
        child: isRefreshing
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : coinMarket == null || coinMarket!.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(myHeight * 0.06),
                    child: const Center(
                      child: Text(
                        'Attention this API is free, so you cannot send multiple requests per second, please wait and try again later.',
                        style: TextStyle(fontSize: 18, color: Colors.white),
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
