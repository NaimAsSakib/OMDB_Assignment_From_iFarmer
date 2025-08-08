import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/dto/listing_filter.dart';
import '../../api/dto/movie_models.dart';
import '../../widgets/movie_carousel.dart';
import '../../widgets/movie_rail.dart';
import '../controller/home_controller.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'OTT App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to search screen
              Get.snackbar('Info', 'Search feature coming soon!');
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigate to profile screen
              Get.snackbar('Info', 'Profile feature coming soon!');
            },
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshData();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Carousel Section
              Obx(() => MovieCarousel(
                movies: controller.carouselMovies,
                isLoading: controller.isLoadingCarousel.value,
                onMovieTap: (movie) => _navigateToDetails(movie),
              )),

              const SizedBox(height: 32),

              // Batman Movies Rail
              Obx(() => MovieRail(
                title: 'Batman Movies',
                movies: controller.batmanMovies,
                isLoading: controller.isLoadingBatman.value,
                onMovieTap: (movie) => _navigateToDetails(movie),
                onSeeAll: () => _navigateToListing('Batman'),
              )),

              const SizedBox(height: 24),

              // Latest Movies Rail
              Obx(() => MovieRail(
                title: 'Latest Movies (2022)',
                movies: controller.latestMovies,
                isLoading: controller.isLoadingLatest.value,
                onMovieTap: (movie) => _navigateToDetails(movie),
                onSeeAll: () => _navigateToListing('2022'),
              )),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to movie details screen
  void _navigateToDetails(Movie movie) {
    Get.toNamed('/details', arguments: movie);
  }

  /// Navigate to listing screen with specific filter
  void _navigateToListing(String filter) {
    ListingFilter? selectedFilter;

    if (filter == 'Batman') {
      selectedFilter = ListingFilter.predefinedFilters.firstWhere(
            (f) => f.query == 'Batman',
        orElse: () => const ListingFilter(
          title: 'Batman Movies',
          query: 'Batman',
          type: 'movie',
          displayName: 'Batman Collection',
        ),
      );
    } else if (filter == '2022') {
      selectedFilter = ListingFilter.predefinedFilters.firstWhere(
            (f) => f.year == '2022',
        orElse: () => const ListingFilter(
          title: 'Latest 2022',
          query: 'movie',
          year: '2022',
          type: 'movie',
          displayName: 'Latest 2022 Movies',
        ),
      );
    }

    Get.toNamed('/listing', arguments: {
      'filter': selectedFilter,
      'title': selectedFilter?.displayName ?? 'Movies',
    });

    Get.snackbar(
      'Navigate',
      'Opening ${selectedFilter?.displayName ?? filter} listing',
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}