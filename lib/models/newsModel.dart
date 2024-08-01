class News {
  final String title;
  final String link;
  final String pubDate;

  News({required this.title, required this.link, required this.pubDate});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'] as String,
      link: json['link'] as String,
      pubDate: json['pubDate'] as String,
    );
  }
}

List<News> newsFromJson(List<dynamic> jsonData) {
  return jsonData.map((item) => News.fromJson(item)).toList();
}
