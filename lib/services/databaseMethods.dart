import '../Model/get_caption_data_model.dart' as getcaptiondatamodel;
import '../services/databaseservices.dart';

class Databasemethods {
  static DatabaseService? databaseService = DatabaseService.instance;

  static Future<List<getcaptiondatamodel.GetCaptionDataModel>> getCaptionData(
      String? videoId) async {
    List<getcaptiondatamodel.GetCaptionDataModel> getcaptionDataModel = [];
    if (databaseService != null && videoId != null) {
      var captionData =
          await databaseService?.getCaptionForVideo(videoId: videoId);
      var captionAllDate = captionData
          ?.map(
              (item) => getcaptiondatamodel.GetCaptionDataModel.fromJson(item))
          .toList();
      getcaptionDataModel = captionAllDate!;
    }
    return getcaptionDataModel;
  }

  static Future<int> getmaxversions(String? videoId) async {
    int max = 0;
    if (videoId != null) {
      final maxVersion =
          await databaseService?.getHighestVersionByVidId(int.parse(videoId));
      max = maxVersion!;
    }
    print("MAx version ==== >>>> $max");
    return max;
  }

  static Future<int> getminversions(String? videoId) async {
    int min = 0;
    if (videoId != null) {
      final minVersion =
          await databaseService?.getLowestVersionByVidId(int.parse(videoId));
      min = minVersion!;
    }
    print("MAx version ==== >>>> $min");
    return min;
  }
}
