import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'navbar.dart'; // Import CustomNavBar from navbar.dart
import 'package:awesome_notifications/awesome_notifications.dart';


class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List articles = [];
  List filteredArticles = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await loadCachedNews();
    await fetchNews();
  }

  Future<void> loadCachedNews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedNews = prefs.getString('cachedNews');
    if (cachedNews != null) {
      setState(() {
        articles = json.decode(cachedNews);
        filteredArticles = articles;
        isLoading = false;
      });
    }
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
    });

    try {
      const apiKey = 'cq9f34pr01qlu7f2mbh0cq9f34pr01qlu7f2mbhg';
      final response = await http.get(
        Uri.parse('https://finnhub.io/api/v1/news?category=general'),
        headers: {'X-Finnhub-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty && articles.isNotEmpty && data[0]['id'] != articles.first['id']) {
          notifyNewArticle(data[0]['headline'], data[0]['summary']);
        }

        setState(() {
          articles = data;
          filteredArticles = articles;
          isLoading = false;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('cachedNews', json.encode(articles));
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleRefresh() async {
    await fetchNews();
  }

  void notifyNewArticle(String title, String summary) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'news_channel',
        title: title,
        body: summary,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  void filterArticles(String query) {
    List filteredList = articles.where((article) {
      return article['headline'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredArticles = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Type your keywords here',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (query) {
                  filterArticles(query);
                },
              )
            : const Text(
                'News',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  filterArticles('');
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      body: LiquidPullToRefresh(
        onRefresh: handleRefresh,
        showChildOpacityTransition: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserHeader(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TabButton(text: 'Today'),
                    // Add more TabButtons as needed
                  ],
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: filteredArticles.map((article) => NewsCard(
                  title: article['headline'],
                  author: article['source'],
                  date: DateTime.fromMillisecondsSinceEpoch(article['datetime'] * 1000).toString(),
                  views: '',
                  comments: '',
                  likes: '',
                  url: article['url'],
                )).toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 2,
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
              size: 40,
              color: Colors.white,
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

class TabButton extends StatelessWidget {
  final String text;
  final bool selected;

  const TabButton({required this.text, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () {
          // Tab action
        },
        style: ButtonStyle(
          backgroundColor: selected ? MaterialStateProperty.all(Colors.blue) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: selected ? Colors.white : Colors.grey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
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
  final String url;

  NewsCard({
    required this.title,
    required this.author,
    required this.date,
    required this.views,
    required this.comments,
    required this.likes,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          print('Could not launch $url');
          throw 'Could not launch $url';
        }
      },
      child: Card(
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
      ),
    );
  }
}
