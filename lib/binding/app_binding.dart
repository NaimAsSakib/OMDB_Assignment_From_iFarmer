import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

import '../api/api_service/api_service.dart';
import '../movie_details/service/video_storage_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<VideoStorageService>(VideoStorageService(), permanent: true);
  }
}