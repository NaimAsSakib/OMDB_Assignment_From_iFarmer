import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/dto/movie_models.dart';
import '../../widgets/movie_info_widget.dart';
import '../../widgets/video_player_widget.dart';
import '../controller/movie_details_controller.dart';


class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({Key? key}) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late MovieDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(MovieDetailsController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const VideoPlayerWidget(),

                Obx(() {
                  if (_controller.isLoadingDetails.value) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const MovieInfoWidget();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Obx(() {
        final movie = _controller.movie.value;
        return Text(
          movie?.title ?? 'Movie Details',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      }),
      actions: [
        IconButton(
          onPressed: () async {
            final hasSaved = await _controller.hasSavedPosition();
            if (hasSaved) {
              _showPlaybackOptionsDialog();
            } else {
              _controller.startVideoPlayback();
            }
          },
          icon: const Icon(Icons.play_circle_outline, color: Colors.white),
        ),
        IconButton(
          onPressed: () {
            Get.snackbar('Feature', 'Add to Watchlist - Coming Soon!');
          },
          icon: const Icon(Icons.favorite_border, color: Colors.white),
        ),
      ],
    );
  }

  void _showPlaybackOptionsDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Resume Playback?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'You have a saved position for this video. Would you like to resume or start from the beginning?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _controller.resetVideo();
              _controller.startVideoPlayback();
            },
            child: const Text('Start Over'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _controller.startVideoPlayback();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }
}

