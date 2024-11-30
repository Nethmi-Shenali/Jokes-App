import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/joke_model.dart';

class JokeService {
  final String _baseUrl = 'https://official-joke-api.appspot.com/jokes';

  Future<List<Joke>> getRandomJokes(int count) async {
    final response = await http.get(Uri.parse('$_baseUrl/random/$count'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((joke) => Joke.fromJson(joke)).toList();
    } else {
      throw Exception('Failed to load jokes');
    }
  }

  Future<List<Joke>> getJokesByType(String type, int count) async {
    // Note: This API might not support filtering by type
    // For now, we'll just get random jokes
    return getRandomJokes(count);
  }
}
