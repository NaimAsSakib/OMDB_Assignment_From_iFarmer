import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../api/dto/movie_models.dart';
import '../movie_details/controller/movie_details_controller.dart';

class MovieInfoWidget extends StatelessWidget {
  const MovieInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MovieDetailsController>();

    return Obx(() {
      final movie = controller.movieDetails.value ?? controller.movie.value;
      if (movie == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie Poster
                _buildMoviePoster(movie),
                const SizedBox(width: 16),

                // Movie Basic Info
                Expanded(child: _buildBasicInfo(movie)),
              ],
            ),
            const SizedBox(height: 24),

            // Movie Description
            _buildDescription(movie),
            const SizedBox(height: 24),

            // Movie Details Grid
            _buildDetailsGrid(movie),
          ],
        ),
      );
    });
  }

  Widget _buildMoviePoster(Movie movie) {
    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: movie.poster,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[800],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie, size: 40, color: Colors.white54),
                SizedBox(height: 8),
                Text(
                  'No Image',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo(Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            _buildInfoChip(movie.year, Icons.calendar_today),
            const SizedBox(width: 8),
            _buildInfoChip(movie.type.toUpperCase(), Icons.category),
          ],
        ),

        if (movie.imdbRating != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${movie.imdbRating}/10',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],

        if (movie.runtime != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                movie.runtime!,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.blue, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Movie movie) {
    if (movie.plot == null || movie.plot!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plot',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.plot!,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(Movie movie) {
    final details = <String, String?>{
      'Director': movie.director,
      'Actors': movie.actors,
      'Genre': movie.genre,
      'Year': movie.year,
      'Type': movie.type,
      'Runtime': movie.runtime,
      'IMDb Rating': movie.imdbRating,
    };

    final validDetails = details.entries
        .where((entry) => entry.value != null && entry.value!.isNotEmpty)
        .toList();

    if (validDetails.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...validDetails.map((entry) => _buildDetailRow(entry.key, entry.value!)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
