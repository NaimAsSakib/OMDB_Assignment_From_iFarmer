import 'dart:convert';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import '../dto/movie_models.dart';
import 'package:http/http.dart' as http;


class ApiService extends GetxService {
  static const String _baseUrl = 'https://www.omdbapi.com/';
  static const String _apiKey = '82e0214b';

  final http.Client _client = http.Client();

  /// Fetch movies by search term
  Future<MovieResponse> searchMovies(String searchTerm, {int page = 1}) async {
    try {
      final url = '$_baseUrl?apikey=$_apiKey&s=$searchTerm&page=$page';
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MovieResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch movies by year
  Future<MovieResponse> getMoviesByYear(String year, {int page = 1}) async {
    try {
      final url = '$_baseUrl?apikey=$_apiKey&s=movie&y=$year&page=$page&type=movie';
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MovieResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load movies by year: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
