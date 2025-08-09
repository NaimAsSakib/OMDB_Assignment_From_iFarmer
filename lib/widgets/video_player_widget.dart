import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../movie_details/controller/movie_details_controller.dart';


class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MovieDetailsController>();

    return Obx(() {
      if (controller.isVideoLoading.value) {
        return _buildLoadingState();
      }

      if (controller.videoError.value != null) {
        return _buildErrorState(controller.videoError.value!);
      }

      if (!controller.isVideoInitialized.value) {
        return _buildInitialState(controller);
      }

      if (controller.chewieController == null) {
        return _buildLoadingState();
      }

      return _buildVideoPlayer(controller);
    });
  }

  Widget _buildLoadingState() {
    return Container(
      height: 250,
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 250,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            const Text(
              'Video Error',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(MovieDetailsController controller) {
    return Container(
      height: 250,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline, color: Colors.white, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Ready to Play',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.startVideoPlayback,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(MovieDetailsController controller) {
    return Container(
      height: 250,
      child: Chewie(
        controller: controller.chewieController!,
      ),
    );
  }
}