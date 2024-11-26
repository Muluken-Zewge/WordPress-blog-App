class Post {
  final int id;
  final String date;
  final String title;
  final String content;
  final String mediaUrl;
  final String catagory;

  Post(
      {required this.id,
      required this.date,
      required this.title,
      required this.content,
      required this.mediaUrl,
      required this.catagory});

  factory Post.fromJson(Map<String, dynamic> json) {
    String extractCategory(List<dynamic> classList) {
      final categoryString = classList.firstWhere(
        (element) => element.startsWith('category-'),
        orElse: () => '',
      );
      if (categoryString.isNotEmpty) {
        final category = categoryString.replaceFirst('category-', '');
        return category[0].toUpperCase() + category.substring(1);
      }
      return 'Unknown';
    }

    return Post(
        id: json['id'],
        date: json['date'],
        title: json['title']['rendered'],
        content: json['content']['rendered'],
        mediaUrl: json['jetpack_featured_media_url'],
        catagory: extractCategory(List<String>.from(json['class_list'])));
  }
}
