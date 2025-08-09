import 'dart:convert';

import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/dto/video_playback_state.dart';

class VideoStorageService extends GetxService {
  static const String _playbackKey = 'video_playback_states';
  late SharedPreferences _prefs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save playback position for a movie
  Future<void> savePlaybackPosition(String movieId, Duration position) async {
    try {
      final states = await getAllPlaybackStates();

      // Update or add the state for this movie
      states[movieId] = VideoPlaybackState(
        movieId: movieId,
        position: position,
        lastPlayed: DateTime.now(),
      );

      // Convert to JSON and save
      final Map<String, dynamic> jsonStates = {};
      states.forEach((key, value) {
        jsonStates[key] = value.toJson();
      });

      await _prefs.setString(_playbackKey, json.encode(jsonStates));
      print('💾 Saved playback position for $movieId: ${position.inSeconds}s');
    } catch (e) {
      print('❌ Error saving playback position: $e');
    }
  }

  /// Get saved playback position for a movie
  Future<Duration?> getPlaybackPosition(String movieId) async {
    try {
      final states = await getAllPlaybackStates();
      final state = states[movieId];

      if (state != null) {
        print('📖 Retrieved playback position for $movieId: ${state.position.inSeconds}s');
        return state.position;
      }

      return null;
    } catch (e) {
      print('❌ Error getting playback position: $e');
      return null;
    }
  }

  /// Get all playback states
  Future<Map<String, VideoPlaybackState>> getAllPlaybackStates() async {
    try {
      final String? jsonString = _prefs.getString(_playbackKey);
      if (jsonString == null) return {};

      final Map<String, dynamic> jsonStates = json.decode(jsonString);
      final Map<String, VideoPlaybackState> states = {};

      jsonStates.forEach((key, value) {
        states[key] = VideoPlaybackState.fromJson(value);
      });

      return states;
    } catch (e) {
      print('❌ Error getting all playback states: $e');
      return {};
    }
  }

  /// Clear playback position for a movie
  Future<void> clearPlaybackPosition(String movieId) async {
    try {
      final states = await getAllPlaybackStates();
      states.remove(movieId);

      final Map<String, dynamic> jsonStates = {};
      states.forEach((key, value) {
        jsonStates[key] = value.toJson();
      });

      await _prefs.setString(_playbackKey, json.encode(jsonStates));
      print('🗑️ Cleared playback position for $movieId');
    } catch (e) {
      print('❌ Error clearing playback position: $e');
    }
  }
}