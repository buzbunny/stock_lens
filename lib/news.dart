import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'navbar.dart'; // Import CustomNavBar from navbar.dart

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCachedNews();
  }

  Future<void> loadCachedNews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedNews = prefs.getString('cachedNews');
    if (cachedNews != null) {
      setState(() {
        articles = json.decode(cachedNews);
        isLoading = false;
      });
    }
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
    });

    const apiKey = 'RiOtnEWCIHeHafp0mENfX4gqJzLzVaraU8RYJjvP';
    var headers = {
      'apikey': apiKey,
    };

    var request = http.Request(
      'GET',
      Uri.parse(
        'https://api.marketaux.com/v1/news/all?countries=us&filter_entities=true&limit=10&published_after=2024-07-12T21:20&api_token=RiOtnEWCIHeHafp0mENfX4gqJzLzVaraU8RYJjvP'
      )
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> data = json.decode(responseBody);
      setState(() {
        articles = data['data'] ?? [];
        isLoading = false;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('cachedNews', json.encode(articles));
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load news');
    }
  }

  Future<void> handleRefresh() async {
    await fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'News',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search action
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) => LiquidPullToRefresh(
          onRefresh: handleRefresh,
          showChildOpacityTransition: false,
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      UserHeader(),
                      Tabs(),
                      ...articles.map((article) => NewsCard(
                            title: article['title'],
                            author: article['source'],
                            date: article['published_at'],
                            views: '',
                            comments: '',
                            likes: '',
                          )),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: CustomNavBar( // Adding CustomNavBar at the bottom
        currentIndex: 0, // Set the current index accordingly
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}

class UserHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.rss_feed,
              size: 40, // Adjust size as needed
              color: Colors.white, // Customize color to match your design
            ),
          ),
          SizedBox(width: 10),
          Text(
            'My Feed',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class Tabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }
}

class TabButton extends StatelessWidget {
  final String text;
  final bool selected;

  const TabButton({required this.text, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Tab action
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: selected ? Colors.white : Colors.grey,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final String views;
  final String comments;
  final String likes;

  NewsCard({
    required this.title,
    required this.author,
    required this.date,
    required this.views,
    required this.comments,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'by $author, $date',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (views.isNotEmpty) const Icon(Icons.remove_red_eye, size: 16, color: Colors.white),
                if (views.isNotEmpty) Text(views, style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 10),
                if (comments.isNotEmpty) const Icon(Icons.comment, size: 16, color: Colors.white),
                if (comments.isNotEmpty) Text(comments, style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 10),
                if (likes.isNotEmpty) const Icon(Icons.thumb_up, size: 16, color: Colors.white),
                if (likes.isNotEmpty) Text(likes, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
