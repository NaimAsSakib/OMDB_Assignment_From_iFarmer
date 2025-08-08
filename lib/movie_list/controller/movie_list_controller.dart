import 'package:get/get.dart';

import '../../api/api_service/api_service.dart';
import '../../api/dto/listing_filter.dart';
import '../../api/dto/movie_models.dart';

class MovieListController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final movies = <Movie>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final currentPage = 1.obs;
  final totalResults = 0.obs;
  final selectedFilter = Rx<ListingFilter?>(null);
  final searchQuery = ''.obs;

  static const int moviesPerPage = 10;

  @override
  void onInit() {
    super.onInit();
  }

  /// Load movies with a specific filter
  Future<void> loadMoviesWithFilter(ListingFilter filter) async {
    try {
      selectedFilter.value = filter;
      currentPage.value = 1;
      movies.clear();
      hasMoreData.value = true;
      isLoading.value = true;
      searchQuery.value = '';

      await _fetchMovies(filter, 1);

      update(['filter_${filter.title}']);

    } catch (e) {
      Get.snackbar('Error', 'Failed to load movies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load movies with search query
  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) return;

    try {
      searchQuery.value = query;
      currentPage.value = 1;
      movies.clear();
      hasMoreData.value = true;
      isLoading.value = true;

      final searchFilter = ListingFilter(
        title: 'Search Results',
        query: query,
        displayName: 'Search: $query',
      );
      selectedFilter.value = searchFilter;

      await _fetchMovies(searchFilter, 1);
    } catch (e) {
      Get.snackbar('Error', 'Failed to search movies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more movies (pagination) - COMPLETELY FIXED VERSION
  Future<void> loadMoreMovies() async {
    if (!hasMoreData.value) {
      return;
    }

    if (isLoadingMore.value) {
      return;
    }

    if (isLoading.value) {
      return;
    }

    if (selectedFilter.value == null) {
      return;
    }

    try {
      isLoadingMore.value = true;
      final nextPage = currentPage.value + 1;

      await _fetchMovies(selectedFilter.value!, nextPage);

      currentPage.value = nextPage;

    } catch (e) {
      Get.snackbar('Error', 'Failed to load more movies: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshMovies() async {
    if (selectedFilter.value != null) {
      await loadMoviesWithFilter(selectedFilter.value!);
    }
  }

  Future<void> _fetchMovies(ListingFilter filter, int page) async {
    MovieResponse response;

    if (filter.year != null) {
      response = await _apiService.getMoviesByYear(filter.year!, page: page);
    } else {
      response = await _apiService.searchMovies(filter.query, page: page);
    }

    final newTotalResults = int.tryParse(response.totalResults) ?? 0;
    totalResults.value = newTotalResults;

    List<Movie> updatedMovies;
    if (page == 1) {
      updatedMovies = response.search;
    } else {
      updatedMovies = List<Movie>.from(movies);
      updatedMovies.addAll(response.search);
    }

    movies.value = updatedMovies;

    final currentMovieCount = movies.length;
    final hasMore = currentMovieCount < newTotalResults && response.search.isNotEmpty;
    hasMoreData.value = hasMore;
  }

  void clearSearch() {
    searchQuery.value = '';
    if (selectedFilter.value != null && selectedFilter.value!.title != 'Search Results') {
      loadMoviesWithFilter(selectedFilter.value!);
    } else {
      loadMoviesWithFilter(ListingFilter.predefinedFilters.first);
    }
  }

  bool get isInitialLoading => isLoading.value && movies.isEmpty;
  bool get hasMovies => movies.isNotEmpty;
  bool get canLoadMore {
    final result = hasMoreData.value && !isLoadingMore.value && !isLoading.value;
    return result;
  }
}
