import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'chartModel.dart';

class SelectCoin extends StatefulWidget {
  var selectItem;

  SelectCoin({this.selectItem});

  @override
  State<SelectCoin> createState() => _SelectCoinState();
}

class _SelectCoinState extends State<SelectCoin> {
  late TrackballBehavior trackballBehavior;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs(); // Initialize shared preferences
    getChart();
    trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
    );
  }

  // Initialize shared preferences
  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  // Example method to save data to shared preferences
  Future<void> saveToPrefs(String key, dynamic value) async {
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  // Example method to retrieve data from shared preferences
  dynamic readFromPrefs(String key) {
    return prefs.get(key);
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: myHeight,
          width: myWidth,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: myWidth * 0.05, vertical: myHeight * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                                height: myHeight * 0.08,
                                child:
                                    Image.network(widget.selectItem.image)),
                            SizedBox(
                              width: myWidth * 0.03,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.selectItem.id,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                SizedBox(
                                  height: myHeight * 0.01,
                                ),
                                Text(
                                  widget.selectItem.symbol,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$' + widget.selectItem.currentPrice.toString(),
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: myHeight * 0.01,
                            ),
                            Text(
                              widget.selectItem.marketCapChangePercentage24H
                                      .toString() +
                                  '%',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: widget.selectItem
                                              .marketCapChangePercentage24H >=
                                          0
                                      ? Colors.green
                                      : Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: myWidth * 0.05,
                              vertical: myHeight * 0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Low',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: myHeight * 0.01,
                                  ),
                                  Text(
                                    '\$' + widget.selectItem.low24H.toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'High',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: myHeight * 0.01,
                                  ),
                                  Text(
                                    '\$' + widget.selectItem.high24H.toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Vol',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: myHeight * 0.01,
                                  ),
                                  Text(
                                    '\$' +
                                        widget.selectItem.totalVolume
                                            .toString() +
                                        'M',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: myHeight * 0.015,
                        ),
                        Container(
                          height: myHeight * 0.4,
                          width: myWidth,
                          child: isRefresh == true
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.grey[800],
                                  ),
                                )
                              : itemChart == null
                                  ? Padding(
                                      padding:
                                          EdgeInsets.all(myHeight * 0.06),
                                      child: Center(
                                        child: Text(
                                          'Attention this Api is free, so you cannot send multiple requests per second, please wait and try again later.',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      ),
                                    )
                                  : SfCartesianChart(
                                      trackballBehavior: trackballBehavior,
                                      zoomPanBehavior: ZoomPanBehavior(
                                          enablePinching: true,
                                          zoomMode: ZoomMode.x),
                                      series: <CandleSeries>[
                                        CandleSeries<ChartModel, int>(
                                            enableSolidCandles: true,
                                            enableTooltip: true,
                                            bullColor: Colors.green,
                                            bearColor: Colors.red,
                                            dataSource: itemChart!,
                                            xValueMapper:
                                                (ChartModel sales, _) =>
                                                    sales.time,
                                            lowValueMapper:
                                                (ChartModel sales, _) =>
                                                    sales.low,
                                            highValueMapper:
                                                (ChartModel sales, _) =>
                                                    sales.high,
                                            openValueMapper:
                                                (ChartModel sales, _) =>
                                                    sales.open,
                                            closeValueMapper:
                                                (ChartModel sales, _) =>
                                                    sales.close,
                                            animationDuration: 55)
                                      ],
                                    ),
                        ),
                        SizedBox(
                          height: myHeight * 0.01,
                        ),
                        Center(
                          child: Container(
                            height: myHeight * 0.03,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: text.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: myWidth * 0.02),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        textBool = [
                                          false,
                                          false,
                                          false,
                                          false,
                                          false,
                                          false
                                        ];
                                        textBool[index] = true;
                                      });
                                      setDays(text[index]);
                                      getChart();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: myWidth * 0.03,
                                          vertical: myHeight * 0.005),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: textBool[index] == true
                                            ? Color(0xffFBC700).withOpacity(0.7)
                                            : Colors.transparent,
                                      ),
                                      child: Text(
                                        text[index],
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: myHeight * 0.1,
                    width: myWidth,
                    child: Column(
                      children: [
                        const Divider(),
                        SizedBox(
                          height: myHeight * 0.01,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: myWidth * 0.05,
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: myHeight * 0.012),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.grey.withOpacity(0.2)),
                                child: Image.asset(
                                  'assets/logo-no-background.png',
                                  height: 10,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.1,
                maxChildSize: 0.8,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: myWidth * 0.06,
                              vertical: myHeight * 0.02),
                          child: Text(
                            'News',
                            style:
                                TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: myWidth * 0.06,
                              vertical: myHeight * 0.01),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ),
                              Container(
                                width: myWidth * 0.25,
                                child: CircleAvatar(
                                  radius: myHeight * 0.04,
                                  backgroundImage:
                                      AssetImage('assets/image/11.PNG'),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> text = ['D', 'W', 'M', '3M', '6M', 'Y'];
  List<bool> textBool = [false, false, true, false, false, false];

  int days = 30;

  setDays(String txt) {
    if (txt == 'D') {
      setState(() {
        days = 1;
      });
      saveToPrefs('selectedDays', days); // Save selected days to shared preferences
    } else if (txt == 'W') {
      setState(() {
        days = 7;
      });
      saveToPrefs('selectedDays', days); // Save selected days to shared preferences
    } else if (txt == 'M') {
      setState(() {
        days = 30;
      });
      saveToPrefs('selectedDays', days); // Save selected days to shared preferences
    } else if (txt == '3M') {
      setState(() {
        days = 90;
      });
      saveToPrefs('selectedDays', days); // Save selected days to shared preferences
    } else if (txt == '6M') {
      setState(() {
        days = 180;
      });
      saveToPrefs('selectedDays', days); // Save selected days to shared preferences
    } else if (txt == 'Y') {
      setState(() {
        days = 365;
      });
      saveToPrefs('selectedDays', days); // Save selected days to shared preferences
    }
  }

  List<ChartModel>? itemChart;

  bool isRefresh = true;

  Future<void> getChart() async {
    String url = 'https://api.coingecko.com/api/v3/coins/' +
        widget.selectItem.id +
        '/ohlc?vs_currency=usd&days=' +
        days.toString();

    setState(() {
      isRefresh = true;
    });

    var response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });

    setState(() {
      isRefresh = false;
    });

    if (response.statusCode == 200) {
      Iterable x = json.decode(response.body);
      List<ChartModel> modelList =
          x.map((e) => ChartModel.fromJson(e)).toList();
      setState(() {
        itemChart = modelList;
      });
    } else {
      print(response.statusCode);
    }
  }
}
