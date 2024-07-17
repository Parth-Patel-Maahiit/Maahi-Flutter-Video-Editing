import 'dart:io';

import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_video/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editing_app/UI/Projects.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

void scaffoldMessengerMessage(
    {required String message, required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message,
        style: const TextStyle(
          color: AppColor.black_color,
        )),
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColor.white_color,
    duration: const Duration(seconds: 2),
    margin: const EdgeInsets.all(10.0),
  ));
}

Future<String> generateThumbnail(String videoPath) async {
  final Directory extDir = await getApplicationCacheDirectory();
  final String thumbnailPath = '${extDir.path}/${videoPath.hashCode}.jpg';
  await VideoThumbnail.thumbnailFile(
    video: videoPath,
    thumbnailPath: thumbnailPath,
    imageFormat: ImageFormat.JPEG,
    maxHeight: 500,
    quality: 100,
  );
  return thumbnailPath;
}

Duration parseDuration(String time) {
  final parts = time.split(':');
  final secondsParts = parts[2].split('.');
  return Duration(
    hours: int.parse(parts[0]),
    minutes: int.parse(parts[1]),
    seconds: int.parse(secondsParts[0]),
    milliseconds: int.parse(secondsParts[1]),
  );
}

Future<String> addWatermark(filePath) async {
  String outputPath = "";
  try {
    final directory = await getApplicationDocumentsDirectory();
    const watermarkPath = 'assets/watermark.png';
    final outputPathFinal = '${directory.path}/output.mp4';

    final watermarkAbsolutePath = await getAssetAbsolutePath(watermarkPath);

    final ffmpegCommand =
        '-i $filePath -i $watermarkAbsolutePath -filter_complex "overlay=10:10" -y $outputPath';

    final session = await FFmpegKit.execute(ffmpegCommand);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Watermark added successfully');
      outputPath = outputPathFinal;
    } else {
      final logs = await session.getAllLogsAsString();
      final statistics = await session.getStatistics();
      print('Failed to add watermark');
      print('FFmpeg log: $logs');
      print('FFmpeg statistics: $statistics');
    }
  } catch (e) {
    print('Error adding watermark: $e');
  } finally {}
  return outputPath;
}

Future<String> getAssetAbsolutePath(String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
  await tempFile.writeAsBytes(byteData.buffer.asUint8List());
  return tempFile.path;
}

String formatDateString(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  DateTime now = DateTime.now();
  Duration difference = now.difference(dateTime);

  if (difference.inHours < 12) {
    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else {
      return "${difference.inHours} hours ago";
    }
  } else if (DateFormat('yyyy-MM-dd').format(now) ==
      DateFormat('yyyy-MM-dd').format(dateTime)) {
    return "Today";
  } else if (DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: 1))) ==
      DateFormat('yyyy-MM-dd').format(dateTime)) {
    return "Yesterday";
  } else {
    return "${difference.inDays} days ago";
  }
}

void errorHandler(BuildContext context) {
  scaffoldMessengerMessage(
      message: "Something went wrong, please try again!", context: context);
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => ProjectsScreen(),
    ),
    (route) => false,
  );
}
