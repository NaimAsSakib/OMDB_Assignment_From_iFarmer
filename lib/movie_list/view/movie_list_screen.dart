import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../api/dto/listing_filter.dart';
import '../../api/dto/movie_models.dart';
import '../../widgets/filter_chip_widget.dart';
import '../../widgets/loading_grid_widget.dart';
import '../../widgets/movie_grid_item.dart';
import '../controller/movie_list_controller.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({Key? key}) : super(key: key);

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late TextEditingController _searchController;
  late RefreshController _refreshController;
  late ScrollController _scrollController;
  late MovieListController _controller;

  bool _isScrollLoading = false;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _refreshController = RefreshController(initialRefresh: false);
    _scrollController = ScrollController();
    _controller = Get.put(MovieListController(), permanent: false);

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigationArguments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleNavigationArguments() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      final filter = arguments['filter'] as ListingFilter?;
      if (filter != null) {
        _controller.loadMoviesWithFilter(filter);
        return;
      }
    }

    _controller.loadMoviesWithFilter(ListingFilter.predefinedFilters.first);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    final threshold = maxScroll - 100;


    if (currentScroll >= threshold) {
      if (_controller.canLoadMore) {

        if (!_isScrollLoading) {
          _isScrollLoading = true;
          _controller.loadMoreMovies().then((_) {
            _isScrollLoading = false;
          }).catchError((error) {
            _isScrollLoading = false;
          });
        } else {
        }
      } else {
      }
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          FilterChipWidget(controller: _controller),
          Expanded(child: _buildMoviesGrid()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Obx(() => Text(
        _controller.selectedFilter.value?.displayName ?? 'Movies',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      )),
      actions: [
        Obx(() => Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              '${_controller.movies.length} of ${_controller.totalResults.value}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search movies...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: Obx(() => _controller.searchQuery.value.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchController.clear();
              _controller.clearSearch();
            },
            icon: const Icon(Icons.clear, color: Colors.white54),
          )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            _controller.searchMovies(query);
          }
        },
      ),
    );
  }

  Widget _buildMoviesGrid() {
    return Obx(() {
      if (_controller.isInitialLoading) {
        return const LoadingGridWidget();
      }

      if (!_controller.hasMovies && !_controller.isLoading.value) {
        return _buildEmptyState();
      }

      return SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: () async {
          await _controller.refreshMovies();
          _refreshController.refreshCompleted();
        },
        header: const WaterDropHeader(waterDropColor: Colors.blue),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo is ScrollUpdateNotification) {
              final currentScroll = scrollInfo.metrics.pixels;
              final maxScroll = scrollInfo.metrics.maxScrollExtent;
              final threshold = maxScroll - 100;

              if (currentScroll >= threshold &&
                  _controller.canLoadMore &&
                  !_isScrollLoading) {
                _triggerLoadMore();
              }
            }
            return false;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _controller.movies.length,
                  itemBuilder: (context, index) {
                    final movie = _controller.movies[index];
                    return MovieGridItem(
                      movie: movie,
                      onTap: () => _navigateToDetails(movie),
                    );
                  },
                ),
                _buildLoadMoreIndicator(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (_controller.isLoadingMore.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Loading page ${_controller.currentPage.value + 1}...',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        );
      }

      if (!_controller.hasMoreData.value && _controller.hasMovies) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'All movies loaded!',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        );
      }

      if (_controller.hasMoreData.value && _controller.hasMovies) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Scroll for more...',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: () {
                  _triggerLoadMore();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Text(
                  'Load More',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Current: ${_controller.movies.length} of ${_controller.totalResults.value}',
                style: const TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ],
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 80, color: Colors.white54),
          SizedBox(height: 16),
          Text(
            'No movies found',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching for different keywords',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _triggerLoadMore() {
    if (_isScrollLoading) return;

    _isScrollLoading = true;

    _controller.loadMoreMovies().then((_) {
      _isScrollLoading = false;
    }).catchError((error) {
      _isScrollLoading = false;
    });
  }

  void _navigateToDetails(Movie movie) {
    Get.toNamed('/details', arguments: movie);
  }
}