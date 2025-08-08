import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../api/dto/movie_models.dart';

class MovieRail extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final bool isLoading;
  final Function(Movie) onMovieTap;
  final VoidCallback? onSeeAll;

  const MovieRail({
    Key? key,
    required this.title,
    required this.movies,
    required this.isLoading,
    required this.onMovieTap,
    this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRailHeader(),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: isLoading ? _buildShimmerRail() : _buildMovieList(),
        ),
      ],
    );
  }

  Widget _buildRailHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMovieList() {
    if (movies.isEmpty) {
      return const Center(
        child: Text(
          'No movies available',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieCard(movie);
      },
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => onMovieTap(movie),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: movie.poster,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.movie,
                      size: 30,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              movie.year,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerRail() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[600]!,
          child: Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: double.infinity,
                  color: Colors.grey[800],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  width: 60,
                  color: Colors.grey[800],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}