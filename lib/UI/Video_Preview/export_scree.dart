import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_video/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_editing_app/Model/get_caption_data_model.dart';
import 'package:video_editing_app/UI/Video_Preview/script_preview.dart';
import 'package:video_editing_app/services/databaseservices.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/util/app_images.dart';
import 'package:video_player/video_player.dart';

import '../../widget/button.dart';
import '../../widget/video_caption.dart';

class ExportScreen extends StatefulWidget {
  final String videoID;
  final String filePath;
  const ExportScreen(
      {super.key, required this.videoID, required this.filePath});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;

  late VideoPlayerController _videoPlayerController;

  late String _outputPath;

  double? aspectRatio;
  bool isPlaying = false;
  String isactive = "Standard";

  List<GetCaptionDataModel> _getCations = [];

  @override
  void initState() {
    super.initState();
    _outputPath = widget.filePath;
    getCaptionData();
    getratio();
    _initializeVideoPlayer().then((_) {
      setState(() {
        isPlaying = true;
      });
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _shareVideo() {
    Share.shareFiles([_outputPath], text: 'Check out this video!');
  }

  void getCaptionData() async {
    // ignore: unnecessary_null_comparison
    if (widget.videoID != null) {
      var captionData =
          await _databaseService.getCaptionForVideo(videoId: widget.videoID);
      var captionAllDate = captionData
          .map((item) => GetCaptionDataModel.fromJson(item))
          .toList();
      if (captionData.isNotEmpty) {
        setState(() {
          _getCations = captionAllDate;
          print("Caption data === > $_getCations");
        });
      }
    }
    setState(() {});
  }

  Future<void> _initializeVideoPlayer() async {
    print("Initializing video player with file path: ${_outputPath}");
    if (!File(_outputPath).existsSync()) {
      print("File does not exist at path: ${_outputPath}");
      return;
    }
    try {
      _videoPlayerController = VideoPlayerController.file(File(_outputPath));
      await _videoPlayerController.initialize();
      await _videoPlayerController.setLooping(false);
      await getratio();
      await _videoPlayerController.play();

      _videoPlayerController.addListener(() {
        final isFinished = _videoPlayerController.value.position >=
            _videoPlayerController.value.duration;
        if (isFinished && _videoPlayerController.value.isInitialized) {
          print("Video finished playing");
          setState(() {
            isPlaying = false;
          });
          _videoPlayerController.pause();
        }
        setState(() {});
      });
      setState(() {});
    } catch (e) {
      print("Error initializing video player: ${e.toString()}");
    }
  }

  Duration _parseDuration(String time) {
    final parts = time.split(':');
    final secondsParts = parts[2].split('.');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(secondsParts[0]),
      milliseconds: int.parse(secondsParts[1]),
    );
  }

  void _togglePlayPause() {
    final isFinished = _videoPlayerController.value.position ==
        _videoPlayerController.value.duration;
    setState(() {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
        isPlaying = false;
      } else {
        if (_videoPlayerController.value.position >=
            _videoPlayerController.value.duration) {
          _videoPlayerController.seekTo(Duration.zero);
          isPlaying = true;
        }
        getratio();
        _videoPlayerController.play();
        isPlaying = true;
      }
      if (isFinished == true) {
        isPlaying = false;
      }
    });
  }

  late double h, w;

  Future<void> getratio() async {
    w = await _databaseService.getwidth(_outputPath);
    print("width === > $w");
    h = await _databaseService.getheight(_outputPath);
    print("height === > $h");
    aspectRatio = w / h;
  }

  @override
  Widget build(BuildContext context) {
    if (_videoPlayerController.value.isPlaying) {
      isPlaying = true;
    }

    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(78, 0, 0, 0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color: AppColor.white_color,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  InkWell(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(78, 0, 0, 0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          margin: EdgeInsets.all(2),
                          // color: Colors.amber,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.more_horiz,
                              size: 20,
                              color: AppColor.white_color,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 10, right: 10),
                child: Stack(
                  children: [
                    VideoCaption(
                      onTapToggle: _togglePlayPause,
                      aspectRatio: aspectRatio,
                      getCations: _getCations,
                      height: height,
                      isPlaying: isPlaying,
                      videoPlayerController: _videoPlayerController,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                      width: 2, color: AppColor.grey_color)),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 4,
                                  right: 4,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    types(
                                        "Standard",
                                        isactive == "Standard"
                                            ? AppColor.elevated_bg_color
                                            : Colors.transparent, () {
                                      setState(() {
                                        isactive = "Standard";
                                      });
                                    }),
                                    types(
                                        "HD",
                                        isactive == "HD"
                                            ? AppColor.elevated_bg_color
                                            : Colors.transparent, () {
                                      setState(() {
                                        isactive = "HD";
                                      });
                                    }),
                                    types(
                                        "4K",
                                        isactive == "4K"
                                            ? AppColor.elevated_bg_color
                                            : Colors.transparent, () {
                                      setState(() {
                                        isactive = "4K";
                                      });
                                    }),
                                  ],
                                ),
                              )))
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColor.elevated_bg_color,
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 17),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Remove watermark",
                                    style: TextStyle(
                                        color: AppColor.white_color,
                                        fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      CommonButton(
                        bgcolor: AppColor.elevated_bg_color,
                        text: "Edit",
                        image: AppImages.edit,
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoSavePage(
                                  isBackExport: true,
                                  filePath: _outputPath,
                                  videoID: widget.videoID,
                                ),
                              ));
                        },
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      CommonButton(
                        bgcolor: AppColor.home_plus_color,
                        text: "Export",
                        image: AppImages.export,
                        onPressed: () {
                          // _shareVideo();
                          srtconverter(convertCaptionsToJson(_getCations));
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  String convertCaptionsToJson(List<GetCaptionDataModel> captions) {
    List<Map<String, dynamic>> jsonData =
        captions.map((caption) => caption.toJson()).toList();
    return jsonEncode(jsonData);
  }

  void srtconverter(String jsonData) async {
    List<dynamic> captionData = jsonDecode(jsonData);

    String formatTime(String time) {
      return time.replaceAll('.', ',');
    }

    String formatText(Map<String, dynamic> caption) {
      String text = caption['text'];

      String formattedText =
          '<font color="#${caption['text_color'].toString().substring(2)}">$text</font>';

      if (caption['is_bold'] == "1") {
        formattedText = '<b>$formattedText</b>';
      }
      if (caption['is_italic'] == "1") {
        formattedText = '<i>$formattedText</i>';
      }
      if (caption['is_underline'] == "1") {
        formattedText = '<u>$formattedText</u>';
      }

      return formattedText;
    }

    String formatTextForCombine(Map<String, dynamic> caption) {
      String text = caption['text'];

      String formattedText = "$text";
      // '<font color="#${caption['text_color'].toString().substring(2)}">$text</font>';

      if (caption['is_bold'] == "1") {
        formattedText = '<b>$formattedText</b>';
      }
      if (caption['is_italic'] == "1") {
        formattedText = '<i>$formattedText</i>';
      }
      if (caption['is_underline'] == "1") {
        formattedText = '<u>$formattedText</u>';
      }

      return formattedText;
    }

    String createSrtContent(List<dynamic> captions) {
      StringBuffer srtContent = StringBuffer();
      int counter = 1;

      Map<String, Map<String, dynamic>> combinedCaptions = {};

      for (var caption in captions) {
        List<int> idsIntList = caption['combine_ids']
            .toString()
            .split(",")
            .map((id) => int.parse(id.trim()))
            .toList();

        if (idsIntList.length == 1) {
          combinedCaptions[caption['id'].toString()] = caption;
        } else {
          String combinedId = idsIntList.join("-");
          if (!combinedCaptions.containsKey(combinedId)) {
            combinedCaptions[combinedId] = {
              'start_from': caption['start_from'],
              'end_to': caption['end_to'],
              'text': formatTextForCombine(caption),
              'is_bold': caption['is_bold'],
              'is_italic': caption['is_italic'],
              'is_underline': caption['is_underline'],
              'text_color': caption['text_color'],
              'background_color': caption['background_color'],
            };
          } else {
            combinedCaptions[combinedId]?['end_to'] = caption['end_to'];
            combinedCaptions[combinedId]?['text'] += ' ' + caption['text'];
          }
        }
      }

      combinedCaptions.forEach((id, caption) {
        String formattedText = formatText({
          'text': caption['text'],
          'is_bold': caption['is_bold'],
          'is_italic': caption['is_italic'],
          'is_underline': caption['is_underline'],
          'text_color': caption['text_color']
        });
        srtContent.writeln('${counter++}');
        srtContent.writeln(
            '${formatTime(caption["start_from"])} --> ${formatTime(caption["end_to"])}');
        srtContent.writeln(formattedText);
        srtContent.writeln();
      });

      return srtContent.toString();
    }

    String srtContent = createSrtContent(captionData);

    print('srtContent ==> $srtContent');

    Future<void> saveFile(String content, String extension) async {
      String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final directory = await getApplicationCacheDirectory();
      final filePath = '${directory.path}/captions_$timestamp.$extension';
      final file = File(filePath);
      await file.writeAsString(content);
      srtFilePath = filePath;
      print('$extension file saved at: $filePath');
      setState(() {});
    }

    await saveFile(srtContent, 'srt');
    ffmpegButton();
  }

  String srtFilePath = "";
  void ffmpegButton() {
    print("ffmpge start");
    String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    int height = _videoPlayerController.value.size.height.round();
    int width = _videoPlayerController.value.size.width.round();
    print("width === > ${_videoPlayerController.value.size.width.toString()}");
    print(
        "height === > ${_videoPlayerController.value.size.height.toString()}");
    String command =
        '''-y -i "$_outputPath" -vf "subtitles='$srtFilePath:force_style=Fontname=Trueno'" -s ${width}x$height "/storage/emulated/0/Download/output_$timestamp.mp4"''';
    print("command === > $command");
    FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();

      final allLogs = await session.getAllLogs();
      allLogs.forEach((log) {
        print("session logs ==== > ${log.getMessage()}");
      });
      final satastic = await session.getAllStatistics();
      print("session satastic ==== > ${satastic.toString()}");
      satastic.forEach((satastic) {
        print("session Time ==== > ${satastic.getTime()}");
        print("session VideoQuality ==== > ${satastic.getVideoQuality()}");
      });
      print("session commonds === > ${session.getCommand()}");
      print("session Arguments === > ${session.getArguments()}");

      if (ReturnCode.isSuccess(returnCode)) {
        print("Log 1--------------------------------------> SUCCESS");
        setState(() {});
      } else if (ReturnCode.isCancel(returnCode)) {
        print("Log 2--------------------------------------> CANCEL");
      } else {
        print("Log 3--------------------------------------> ERROR");
        print('Error adding subtitles: ${await session.getFailStackTrace()}');
        print("${returnCode}");
      }
    });
  }

  Widget types(String text, Color color, Function() ontap) {
    return Expanded(
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        onTap: ontap,
        child: Container(
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: TextStyle(color: AppColor.white_color, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
