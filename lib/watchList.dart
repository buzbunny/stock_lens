import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navbar.dart';
import 'watchlist_manager.dart';
import 'selectCoin.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'dart:async'; // Import for Timer

class WatchListPage extends StatefulWidget {
  @override
  _WatchListPageState createState() => _WatchListPageState();
}

class _WatchListPageState extends State<WatchListPage> {
  late Timer _timer;
  late Future<void> _loadWatchlistFuture;

  @override
  void initState() {
    super.initState();
    _loadWatchlistFuture = Provider.of<WatchlistManager>(context, listen: false).loadFromPreferences();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        // This will refresh the UI every minute
      });
    });
  }

  Future<void> _handleRefresh() async {
    // Simulate a network call or any data fetch operation
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Update your state here if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Watchlist',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _loadWatchlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading watchlist'));
          } else {
            return LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              showChildOpacityTransition: false,
              child: Consumer<WatchlistManager>(
                builder: (context, manager, child) {
                  return ListView.builder(
                    itemCount: manager.watchedCoins.length,
                    itemBuilder: (context, index) {
                      final coin = manager.watchedCoins[index];
                      return ListTile(
                        leading: Image.network(coin.image),
                        title: Text(
                          coin.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'Price: \$${coin.currentPrice}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectCoin(selectItem: coin),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              WatchlistManager().removeCoin(coin);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${coin.name} has been removed from the watchlist.'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
        },
      ),
      bottomNavigationBar: CustomNavBar(
        onTap: (index) {
          // Handle tap logic if needed
        },
        currentIndex: 3,
      ),
    );
  }
}
