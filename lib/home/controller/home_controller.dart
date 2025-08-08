import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../api/api_service/api_service.dart';
import '../../api/dto/movie_models.dart';



class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Observable variables
  final carouselMovies = <Movie>[].obs;
  final batmanMovies = <Movie>[].obs;
  final latestMovies = <Movie>[].obs;

  final isLoadingCarousel = true.obs;
  final isLoadingBatman = true.obs;
  final isLoadingLatest = true.obs;

  final currentCarouselIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAllData();
  }

  /// Load all home screen data
  void _loadAllData() {
    _loadCarouselMovies();
    _loadBatmanMovies();
    _loadLatestMovies();
  }

  /// Load carousel movies (first 5 Batman movies for demo)
  Future<void> _loadCarouselMovies() async {
    try {
      isLoadingCarousel.value = true;
      final response = await _apiService.searchMovies('Batman');

      if (response.search.isNotEmpty) {
        carouselMovies.value = response.search.take(5).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load carousel movies: $e');
    } finally {
      isLoadingCarousel.value = false;
    }
  }

  /// Load Batman movies rail
  Future<void> _loadBatmanMovies() async {
    try {
      isLoadingBatman.value = true;
      final response = await _apiService.searchMovies('Batman');

      if (response.search.isNotEmpty) {
        batmanMovies.value = response.search;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load Batman movies: $e');
    } finally {
      isLoadingBatman.value = false;
    }
  }

  /// Load latest movies rail (2022)
  Future<void> _loadLatestMovies() async {
    try {
      isLoadingLatest.value = true;
      final response = await _apiService.getMoviesByYear('2022');

      if (response.search.isNotEmpty) {
        latestMovies.value = response.search;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load latest movies: $e');
    } finally {
      isLoadingLatest.value = false;
    }
  }

  Future<void> refreshData() async {
    _loadAllData();
  }

  void updateCarouselIndex(int index) {
    currentCarouselIndex.value = index;
  }
}