class Movie {
  final String imdbID;
  final String title;
  final String year;
  final String type;
  final String poster;
  final String? plot;
  final String? genre;
  final String? director;
  final String? actors;
  final String? runtime;
  final String? imdbRating;

  Movie({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.type,
    required this.poster,
    this.plot,
    this.genre,
    this.director,
    this.actors,
    this.runtime,
    this.imdbRating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      imdbID: json['imdbID'] ?? '',
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      type: json['Type'] ?? '',
      poster: json['Poster'] ?? '',
      plot: json['Plot'],
      genre: json['Genre'],
      director: json['Director'],
      actors: json['Actors'],
      runtime: json['Runtime'],
      imdbRating: json['imdbRating'],
    );
  }
}

class MovieResponse {
  final List<Movie> search;
  final String totalResults;
  final String response;

  MovieResponse({
    required this.search,
    required this.totalResults,
    required this.response,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      search: json['Search'] != null
          ? (json['Search'] as List).map((x) => Movie.fromJson(x)).toList()
          : [],
      totalResults: json['totalResults'] ?? '0',
      response: json['Response'] ?? 'False',
    );
  }
}
