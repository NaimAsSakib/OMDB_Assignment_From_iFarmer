# ifarmer_task
A complete Video-on-Demand streaming application built with Flutter, featuring movie browsing, video playback with resume functionality, and a Netflix-style interface.


#### Features
# Home Screen

Auto-playing carousel with 5 featured movies
Batman Movies rail with horizontal scrolling
Latest Movies (2022) rail
Pull-to-refresh functionality

# Movie List Screen

Search functionality with real-time results
Category filters (Action, Comedy, Horror, Marvel, etc.)
Infinite scroll pagination - loads more movies automatically
Grid layout with movie posters and details

# Movie Details Screen with Video Player

Complete movie information - plot, cast, director, ratings
Video player with professional controls
Resume playback - continues from last watched position
Auto-save progress every 10 seconds

#### Tech Stack

Flutter 3.0+ with GetX state management
OMDB API for real movie data
Video Player & Chewie for video playback
SharedPreferences for resume functionality
Clean Architecture with MVVM pattern

# Installation & Setup
1. Prerequisites

Flutter SDK 3.0+
OMDB API key (free from omdbapi.com)

# Clone & Install
git clone <repository-url>
select master/video_player_screen branch
flutter pub get

# Get OMDB API Key
Visit https://www.omdbapi.com/apikey.aspx
Replace API key in lib/api/api_service/api_service.dart:
static const String _apiKey = 'YOUR_API_KEY_HERE';

# Platform Setup
Android - Add to android/app/src/main/AndroidManifest.xml:
xml<uses-permission android:name="android.permission.INTERNET" />
<application android:usesCleartextTraffic="true">
iOS - Add to ios/Runner/Info.plist:
xml<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
# Run the App
flutter run

# How to Use
Home Screen: Browse featured movies, tap any poster to view details
"See All": Navigate to listing page with more movies
Search & Filter: Find movies by name or category
Movie Details: Tap play button to start video
Resume: Return to same movie to continue from last position