import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'selectCoin.dart';
import 'watchlist_manager.dart'; // Import the WatchlistManager

class Item2 extends StatelessWidget {
  final dynamic item;

  Item2({this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: myWidth * 0.02, vertical: myHeight * 0.005), // Reduced padding
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SelectCoin(selectItem: item)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20, // Reduced horizontal padding
            vertical: 10, // Reduced vertical padding
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface, // Use surface color for background
            borderRadius: BorderRadius.circular(10), // Reduced border radius
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withOpacity(0.8), // Use onSurface color for shadow
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      height: myHeight * 0.025, // Reduced height of the image container
                      child: Image.network(item.image)),
                  IconButton(
                    icon: Icon(Icons.add, color: colorScheme.onSurface),
                    onPressed: () {
                      // Add the item to the watchlist and show a Snackbar
                      Provider.of<WatchlistManager>(context, listen: false).addCoin(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.id} has been added to your watchlist'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 5, // Reduced vertical spacing
              ),
              Text(
                item.id,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(
                height: 5, // Reduced vertical spacing
              ),
              Row(
                children: [
                  Text(
                    item.priceChange24H.toString().contains('-')
                        ? "-\$" +
                            item.priceChange24H
                                .toStringAsFixed(2)
                                .replaceAll('-', '')
                        : "\$" + item.priceChange24H.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: colorScheme.onBackground.withOpacity(0.7), // Use onBackground color for price change
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    item.marketCapChangePercentage24H.toStringAsFixed(2) + '%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: item.marketCapChangePercentage24H >= 0
                          ? colorScheme.secondary
                          : colorScheme.error,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
