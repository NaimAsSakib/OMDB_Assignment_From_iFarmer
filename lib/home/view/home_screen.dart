import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              )),

              const SizedBox(height: 24),

              // Latest Movies Rail
              Obx(() => MovieRail(
                title: 'Latest Movies (2022)',
                movies: controller.latestMovies,
                isLoading: controller.isLoadingLatest.value,
                onMovieTap: (movie) => _navigateToDetails(movie),
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
    Get.snackbar('Info', 'navigating to details soon!!');
  }

}