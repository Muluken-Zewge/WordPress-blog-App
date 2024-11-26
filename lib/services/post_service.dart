import 'dart:convert';

import 'package:word_press_api/constants/constants.dart';
import 'package:word_press_api/model/post_model.dart';
import 'package:http/http.dart' as http;

class PostService {
  Future<List<Post>> fetchPosts() async {
    try {
      final url = Uri.parse(baseUrl);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> postJson = json.decode(response.body);
        final posts = postJson.map((json) => Post.fromJson(json)).toList();
        return posts;
      } else {
        throw Exception('Failed with ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load posts');
    }
  }
}
