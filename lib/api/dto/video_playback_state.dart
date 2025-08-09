class VideoPlaybackState {
  final String movieId;
  final Duration position;
  final DateTime lastPlayed;

  VideoPlaybackState({
    required this.movieId,
    required this.position,
    required this.lastPlayed,
  });

  Map<String, dynamic> toJson() {
    return {
      'movieId': movieId,
      'position': position.inMilliseconds,
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  factory VideoPlaybackState.fromJson(Map<String, dynamic> json) {
    return VideoPlaybackState(
      movieId: json['movieId'],
      position: Duration(milliseconds: json['position']),
      lastPlayed: DateTime.parse(json['lastPlayed']),
    );
  }
}