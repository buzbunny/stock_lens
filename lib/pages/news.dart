// news.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/navbar.dart';
import '../services/noti.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math' as math;
import '../services/back_service.dart';
import 'dart:async';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class _NewsPageState extends State<NewsPage> {
  List articles = [];
  List filteredArticles = [];
  List archivedArticles = [];
  bool isLoading = true;
  bool isSearching = false;
  bool isSelecting = false;
  bool showingArchived = false;
  TextEditingController searchController = TextEditingController();
  Set<int> selectedIndices = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initializeData();
    Noti.initialize(flutterLocalNotificationsPlugin);
    initializeBackgroundService();

    _timer = Timer.periodic(const Duration(seconds: 360), (Timer t) => fetchNews());
  }

  @override
  void dispose() {
    _timer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> initializeData() async {
    await loadCachedNews();
    await loadArchivedNews();
    await fetchNews();
  }

  Future<void> initializeBackgroundService() async {
    await initializeService(
      notificationTitle: 'Fetching News',
      notificationContent: 'The app is fetching the latest news in the background.',
      intervalSeconds: 3600,
    );
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

  Future<void> loadArchivedNews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? archivedNews = prefs.getString('archivedNews');
    if (archivedNews != null) {
      setState(() {
        archivedArticles = json.decode(archivedNews);
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

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? cachedNews = prefs.getString('cachedNews');
        List cachedArticles = cachedNews != null ? json.decode(cachedNews) : [];

        List newArticles = [];
        List oldArticles = [];

        for (var article in data) {
          if (cachedArticles.any((cachedArticle) => cachedArticle['id'] == article['id'])) {
            oldArticles.add(article);
          } else {
            newArticles.add(article);
          }
        }

        setState(() {
          articles = newArticles + oldArticles;
          filteredArticles = articles;
          isLoading = false;
        });

        prefs.setString('cachedNews', json.encode(articles));

        for (var i = 0; i < math.min(5, newArticles.length); i++) {
          var article = newArticles[i];
          Noti.showBigTextNotification(
            id: i,
            title: article['headline'],
            body: article['summary'] ?? 'No summary available',
            fln: flutterLocalNotificationsPlugin,
          );
        }
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

  void filterArticles(String query) {
    List filteredList = showingArchived ? archivedArticles : articles;
    filteredList = filteredList.where((article) {
      return article['headline'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredArticles = filteredList;
    });
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
      isSelecting = selectedIndices.isNotEmpty;
    });
  }

  void archiveSelectedArticles() async {
    List<dynamic> toArchive = [];
    List<dynamic> remaining = [];

    for (int i = 0; i < filteredArticles.length; i++) {
      if (selectedIndices.contains(i)) {
        toArchive.add(filteredArticles[i]);
      } else {
        remaining.add(filteredArticles[i]);
      }
    }

    setState(() {
      if (showingArchived) {
        articles.addAll(toArchive);
        archivedArticles.removeWhere((article) => toArchive.contains(article));
      } else {
        archivedArticles.addAll(toArchive);
        articles = remaining;
      }

      filteredArticles = showingArchived ? archivedArticles : articles;
      selectedIndices.clear();
      isSelecting = false;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedNews', json.encode(articles));
    await prefs.setString('archivedNews', json.encode(archivedArticles));
  }

  void deleteSelectedArticles() async {
    List<dynamic> remaining = [];

    for (int i = 0; i < filteredArticles.length; i++) {
      if (!selectedIndices.contains(i)) {
        remaining.add(filteredArticles[i]);
      }
    }

    setState(() {
      if (showingArchived) {
        archivedArticles = remaining;
      } else {
        articles = remaining;
      }
      filteredArticles = remaining;
      selectedIndices.clear();
      isSelecting = false;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedNews', json.encode(articles));
    await prefs.setString('archivedNews', json.encode(archivedArticles));
  }

  void toggleArchiveView() {
    setState(() {
      showingArchived = !showingArchived;
      filteredArticles = showingArchived ? archivedArticles : articles;
      selectedIndices.clear();
      isSelecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.background,
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Type your keywords here',
                  hintStyle: TextStyle(color: colorScheme.onBackground),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: colorScheme.onBackground),
                onChanged: (query) {
                  filterArticles(query);
                },
              )
            : Text(
                showingArchived ? 'Archived News' : 'News',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: colorScheme.onBackground,
                ),
              ),
        actions: [
          if (isSelecting)
            IconButton(
              icon: Icon(Icons.archive, color: colorScheme.onBackground),
              onPressed: archiveSelectedArticles,
            ),
          if (isSelecting)
            IconButton(
              icon: Icon(Icons.delete, color: colorScheme.onBackground),
              onPressed: deleteSelectedArticles,
            ),
          if (!isSelecting)
            IconButton(
              icon: Icon(isSearching ? Icons.close : Icons.search, color: colorScheme.onBackground),
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
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserHeader(),
                  const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        TabButton(text: 'Today'),
                        // Add more TabButtons as needed
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: List.generate(filteredArticles.length, (index) {
                      var article = filteredArticles[index];
                      return GestureDetector(
                        onLongPress: () => toggleSelection(index),
                        child: NewsCard(
                          title: article['headline'],
                          author: article['source'],
                          date: DateTime.fromMillisecondsSinceEpoch(article['datetime'] * 1000).toString(),
                          views: '',
                          comments: '',
                          likes: '',
                          url: article['url'],
                          imageUrl: article['image'],
                          isSelected: selectedIndices.contains(index),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: colorScheme.secondary,
                child: Icon(showingArchived ? Icons.newspaper : Icons.archive, color: colorScheme.onSecondary),
                onPressed: toggleArchiveView,
              ),
            ),
          ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.rss_feed,
              size: 40,
              color: colorScheme.onBackground,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'My Feed',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () {
          // Tab action
        },
        style: ButtonStyle(
          backgroundColor: selected ? MaterialStateProperty.all(colorScheme.primary) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
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
  final String imageUrl;
  final bool isSelected;

  NewsCard({
    required this.title,
    required this.author,
    required this.date,
    required this.views,
    required this.comments,
    required this.likes,
    required this.url,
    required this.imageUrl,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: isSelected ? colorScheme.primary.withOpacity(0.3) : colorScheme.surface,
      margin: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            print('Could not launch $url');
            throw 'Could not launch $url';
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'by $author, $date',
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (views.isNotEmpty)
                          Icon(Icons.remove_red_eye, size: 16, color: colorScheme.onSurface),
                        if (views.isNotEmpty) Text(views, style: TextStyle(color: colorScheme.onSurface)),
                        const SizedBox(width: 10),
                        if (comments.isNotEmpty)
                          Icon(Icons.comment, size: 16, color: colorScheme.onSurface),
                        if (comments.isNotEmpty) Text(comments, style: TextStyle(color: colorScheme.onSurface)),
                        const SizedBox(width: 10),
                        if (likes.isNotEmpty)
                          Icon(Icons.thumb_up, size: 16, color: colorScheme.onSurface),
                        if (likes.isNotEmpty) Text(likes, style: TextStyle(color: colorScheme.onSurface)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
