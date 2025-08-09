import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:video_player/video_player.dart';

import '../../api/api_service/api_service.dart';

import '../../api/dto/movie_models.dart';
import '../service/video_storage_service.dart';
import 'package:chewie/chewie.dart';

class MovieDetailsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final VideoStorageService _storageService = Get.find<VideoStorageService>();

  // Movie data
  final movie = Rx<Movie?>(null);
  final movieDetails = Rx<Movie?>(null);
  final isLoadingDetails = true.obs;

  // Video player
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final isVideoInitialized = false.obs;
  final isVideoLoading = false.obs;
  final videoError = RxnString();
  final currentPosition = Duration.zero.obs;
  final videoDuration = Duration.zero.obs;
  final isPlaying = false.obs;

  // UI state
  final showVideoControls = true.obs;

  // Sample video URLs
  final List<String> _sampleVideoUrls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
  ];

  @override
  void onInit() {
    super.onInit();
    _setupPeriodicPositionSaving();

    _initializeFromArguments();
  }

  @override
  void onClose() {
    _saveCurrentPosition();
    _disposeVideoPlayer();
    super.onClose();
  }

  /// Initialize movie from Get.arguments
  void _initializeFromArguments() {
    try {
      final arguments = Get.arguments;

      if (arguments == null) {
        Get.snackbar('Error', 'No movie data provided');
        Get.back();
        return;
      }

      if (arguments is Movie) {
        movie.value = arguments;
        _loadMovieDetails();
      } else if (arguments is Map<String, dynamic>) {
        final movieData = arguments['movie'] as Movie?;
        if (movieData != null) {
          movie.value = movieData;
          _loadMovieDetails();
        } else {
          Get.snackbar('Error', 'Invalid movie data');
          Get.back();
        }
      } else {
        Get.snackbar('Error', 'Invalid argument type');
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load movie: $e');
      Get.back();
    }
  }

  /// Alternative method to initialize movie (if needed externally)
  void initializeMovie(Movie movieData) {
    movie.value = movieData;
    _loadMovieDetails();
  }

  /// Load detailed movie information
  Future<void> _loadMovieDetails() async {
    if (movie.value == null) {
      return;
    }

    try {
      isLoadingDetails.value = true;

      final details = await _apiService.getMovieDetails(movie.value!.imdbID);
      movieDetails.value = details;

    } catch (e) {
      Get.snackbar('Error', 'Failed to load movie details: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Initialize and start video player
  Future<void> startVideoPlayback() async {
    if (movie.value == null) {
      Get.snackbar('Error', 'No movie selected');
      return;
    }

    try {
      isVideoLoading.value = true;
      videoError.value = null;

      final urlIndex = movie.value!.imdbID.hashCode.abs() % _sampleVideoUrls.length;
      final videoUrl = _sampleVideoUrls[urlIndex];

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoPlayerController!.initialize();

      final savedPosition = await _storageService.getPlaybackPosition(movie.value!.imdbID);

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoPlay: false,
        looping: false,
        startAt: savedPosition ?? Duration.zero,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlue,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Video Error',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      // Setup listeners
      _videoPlayerController!.addListener(_videoPlayerListener);

      isVideoInitialized.value = true;
      videoDuration.value = _videoPlayerController!.value.duration;

      // Resume from saved position if available
      if (savedPosition != null && savedPosition > Duration.zero) {
        await _videoPlayerController!.seekTo(savedPosition);
        Get.snackbar(
          'Resume Playback',
          'Resuming from ${_formatDuration(savedPosition)}',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }

    } catch (e) {
      videoError.value = 'Failed to load video: $e';
      Get.snackbar('Video Error', 'Failed to load video: $e');
    } finally {
      isVideoLoading.value = false;
    }
  }

  /// Video player state listener
  void _videoPlayerListener() {
    if (_videoPlayerController != null) {
      currentPosition.value = _videoPlayerController!.value.position;
      isPlaying.value = _videoPlayerController!.value.isPlaying;

      if (_videoPlayerController!.value.hasError) {
        videoError.value = _videoPlayerController!.value.errorDescription;
      }
    }
  }

  /// Setup periodic position saving
  void _setupPeriodicPositionSaving() {
    // Save position every 10 seconds while playing
    Stream.periodic(const Duration(seconds: 10)).listen((_) {
      if (_videoPlayerController != null &&
          _videoPlayerController!.value.isInitialized &&
          _videoPlayerController!.value.isPlaying) {
        _saveCurrentPosition();
      }
    });
  }

  /// Save current playback position
  Future<void> _saveCurrentPosition() async {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized &&
        movie.value != null) {
      final position = _videoPlayerController!.value.position;
      await _storageService.savePlaybackPosition(movie.value!.imdbID, position);
    }
  }

  /// Dispose video player
  void _disposeVideoPlayer() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;
    isVideoInitialized.value = false;
  }

  /// Play/Pause video
  void togglePlayPause() {
    if (_videoPlayerController != null) {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      } else {
        _videoPlayerController!.play();
      }
    }
  }

  /// Seek to specific position
  void seekTo(Duration position) {
    _videoPlayerController?.seekTo(position);
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  /// Reset video to beginning
  void resetVideo() {
    seekTo(Duration.zero);
  }

  /// Get Chewie controller for video widget
  ChewieController? get chewieController => _chewieController;

  /// Check if video has saved position
  Future<bool> hasSavedPosition() async {
    if (movie.value == null) return false;
    final position = await _storageService.getPlaybackPosition(movie.value!.imdbID);
    return position != null && position > Duration.zero;
  }
}
