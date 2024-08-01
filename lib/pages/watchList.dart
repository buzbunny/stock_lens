// watch_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navbar.dart';
import '../managers/watchlist_manager.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.background,
        title: Text(
          'My Watchlist',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: colorScheme.onBackground,
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _loadWatchlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading watchlist', style: TextStyle(color: colorScheme.error)));
          } else {
            return LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              showChildOpacityTransition: false,
              color: colorScheme.primary,
              backgroundColor: colorScheme.background,
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
                            color: colorScheme.onBackground,
                          ),
                        ),
                        subtitle: Text(
                          'Price: \$${coin.currentPrice}',
                          style: TextStyle(
                            color: colorScheme.onBackground.withOpacity(0.7),
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
                          icon: Icon(Icons.remove_circle, color: colorScheme.error),
                          onPressed: () {
                            setState(() {
                              WatchlistManager().removeCoin(coin);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${coin.name} has been removed from the watchlist.',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),

                                backgroundColor: colorScheme.primary,
                                action: SnackBarAction(
                                  label: 'Undo',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    // Code to undo the change
                                  },
                                ),
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
