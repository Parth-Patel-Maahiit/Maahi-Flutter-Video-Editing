import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_video/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_editing_app/FFmpeg/video_util.dart';
import 'package:video_editing_app/Model/filepath.dart';
import 'package:video_editing_app/Model/get_caption_data_model.dart';
import 'package:video_editing_app/UI/Projects.dart';
import 'package:video_editing_app/UI/Video_Preview/script_preview.dart';
import 'package:video_editing_app/UI/components/common.dart';
import 'package:video_editing_app/UI/components/common_back_button.dart';
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

class _ExportScreenState extends State<ExportScreen>
    with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService.instance;

  late VideoPlayerController _videoPlayerController;
  MenuController? controller;
  late AnimationController progressController;
  late String _outputPath;

  double? aspectRatio;
  bool isPlaying = false;
  String isactive = "Standard";
  String action = "";
  String option = "";
  late double size;

  late String name;

  List<GetCaptionDataModel> _getCations = [];
  List<FilePath> getfile = [];

  @override
  void initState() {
    super.initState();
    _outputPath = widget.filePath;
    _initi();
    getVideo();
    getCaptionData();
    getsize();
    getratio();
    _initializeVideoPlayer().then((_) {
      setState(() {
        isPlaying = true;
        print(
            "width === > ${_videoPlayerController.value.size.width.toString()}");
        print(
            "height === > ${_videoPlayerController.value.size.height.toString()}");
      });
    });
  }

  Future<void> getsize() async {
    print("video id ==> ${widget.videoID}");
    size = await _databaseService.getfontsize(int.parse(widget.videoID));
    print("size = $size");
  }

  Future<void> _initi() async {
    name = await _databaseService.getFileNameByVIdID(int.parse(widget.videoID));
    print("Name ===> $name");
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _shareVideo() {
    Share.shareFiles([finalpath], text: 'Check out this video!');
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
        });
      }
    }
    setState(() {});
  }

  void getVideo() async {
    getfile.clear();
    // ignore: unnecessary_null_comparison
    if (widget.videoID != null) {
      var videofile = await _databaseService.getVideoFile(
          videoId: int.parse(widget.videoID));
      print("videofile.first[0] =====> ${videofile.first["font_size"]}");

      if (videofile.isNotEmpty) {
        print(
            "videofileff f ======================================> ${videofile.first["font_size"]}");

        setState(() {
          getfile.add(FilePath(
              id: videofile.first["id"],
              vid_id: videofile.first["vid_id"],
              path: videofile.first["content"],
              thumbnail: videofile.first["thumbnail"],
              version: videofile.first["version"],
              title: videofile.first["title"],
              width: videofile.first["width"],
              height: videofile.first["height"],
              date: videofile.first["date"],
              name: videofile.first["name"],
              font_size: videofile.first["font_size"]));
        });
      }
    }
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
      errorHandler(context);
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
    h = await _databaseService.getheight(_outputPath);
    print("w ===> $w");
    print("h ===> $h");
    aspectRatio = w / h;
  }

  @override
  Widget build(BuildContext context) {
    if (_videoPlayerController.value.isPlaying) {
      isPlaying = true;
    }

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectsScreen(),
          ),
          (route) => false,
        );
      },
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              if (action == "")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonBackButton(onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectsScreen(),
                          ),
                          (route) => false,
                        );
                      }),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(169, 67, 67, 67),
                        ),
                        child: MenuAnchor(
                          style: const MenuStyle(
                            //elevation: MaterialStateProperty.all(10),
                            //side: MaterialStateProperty.all(BorderSide(width: 2, color: Colors.grey)),
                            alignment: AlignmentDirectional(-9, 0.7),
                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            surfaceTintColor: MaterialStatePropertyAll(
                                AppColor.elevated_bg_color),
                            backgroundColor: MaterialStatePropertyAll(AppColor
                                .elevated_bg_color), // Set background color to transparent
                            // padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                          ),
                          builder: (BuildContext context,
                              MenuController _controller, Widget? child) {
                            controller = _controller;
                            return IconButton(
                              onPressed: () {
                                if (_controller.isOpen) {
                                  _controller.close();
                                } else {
                                  _controller.open();
                                }
                              },
                              icon: const Icon(Icons.more_horiz),
                              color: Colors.white,
                              tooltip: 'Show menu',
                            );
                          },
                          menuChildren: [
                            SizedBox(
                              width: width * 0.6,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    child: InkWell(
                                      onTap: () => _showRenameDialog(context),
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  "Rename Project",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "T",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    height: 2,
                                    color: Colors.grey,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () => _deleteFile(
                                          int.parse(widget.videoID)),
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  "Delete Project",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color:
                                                          AppColor.red_color),
                                                ),
                                              ],
                                            ),
                                            Icon(
                                              Icons.delete,
                                              color: AppColor.red_color,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 40, left: 10, right: 10),
                  child: Stack(
                    children: [
                      VideoCaption(
                        width: width,
                        isLogoShow: true,
                        onTapToggle: _togglePlayPause,
                        aspectRatio: aspectRatio,
                        getCations: _getCations,
                        height: height,
                        isPlaying: isPlaying,
                        videoPlayerController: _videoPlayerController,
                        getfile: getfile,
                      ),
                    ],
                  ),
                ),
              ),
              if (action == "")
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
                                          width: 2,
                                          color: AppColor.grey_color)),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 4,
                                      right: 4,
                                      top: 4,
                                      bottom: 4,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                              action = "export";
                              progressController = AnimationController(
                                vsync: this,
                                duration: const Duration(seconds: 4),
                              )..addListener(() {
                                  setState(() {});
                                });
                              progressController.repeat();
                              if (_getCations.isNotEmpty) {
                                srtconverter(
                                    convertCaptionsToJson(_getCations));
                              } else {
                                ffmpegButton(false);
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              if (action == "export")
                SizedBox(
                  height: height * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Preparing Your video",
                        style: TextStyle(
                            color: AppColor.white_color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        child: Text(
                          "Please don't close the app or lock your screen while this is in progress",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColor.grey_color),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LinearPercentIndicator(
                              barRadius: Radius.circular(10),
                              width: 200,
                              lineHeight: 7.0,
                              percent: progressController.value,
                              backgroundColor: AppColor.elevated_bg_color,
                              progressColor: AppColor.home_plus_color,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            AssetImage(AppImages.insta),
                            size: 30,
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          ImageIcon(AssetImage(AppImages.tiktok), size: 30),
                          SizedBox(
                            width: 25,
                          ),
                          ImageIcon(AssetImage(AppImages.youtube), size: 30),
                        ],
                      )
                    ],
                  ),
                ),
              if (action == "Done")
                SizedBox(
                  height: height * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ImageIcon(
                        AssetImage(AppImages.done),
                        color: AppColor.white_color,
                        size: 30,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Saved to gallery",
                        style: TextStyle(
                            color: AppColor.white_color,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 20),
                        child: Row(
                          children: [
                            CommonButton(
                                image: AppImages.export,
                                onPressed: () {
                                  _shareVideo();
                                },
                                text: "Share",
                                bgcolor: AppColor.home_plus_color),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                        child: Row(
                          children: [
                            CommonButton(
                                image: AppImages.done,
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectsScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                text: "Done",
                                bgcolor: AppColor.elevated_bg_color),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  /* void vttConverter(String jsonData) async {
    List<dynamic> captionData = jsonDecode(jsonData);

    String formatTime(String time) {
      return time.replaceAll('.', ',');
    }

    String formatText(Map<String, dynamic> caption) {
      String text = caption['text'];
      String textColor = caption['text_color'].toString().substring(2);
      String bgColor = caption['background_color'].toString().substring(2);
      String formattedText = '<c.yellow.bg_blue>$text</c>';

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

    String formatTextForCombine(
        Map<String, dynamic> caption, List<dynamic> captions) {
      List<int> idsIntList = caption['combine_ids']
          .toString()
          .split(",")
          .map((id) => int.parse(id.trim()))
          .toList();
      String finlText = "";
      for (var id in idsIntList) {
        var currentCaption = captions[id];
        String text = currentCaption['keyword'];
        String textColor = currentCaption['text_color'].toString().substring(2);
        String bgColor =
            currentCaption['background_color'].toString().substring(2);
        String formattedText = '<c.yellow.bg_blue>$text</c>';

        if (currentCaption['is_bold'] == "1") {
          formattedText = '<b>$formattedText</b>';
        }
        if (currentCaption['is_italic'] == "1") {
          formattedText = '<i>$formattedText</i>';
        }
        if (currentCaption['is_underline'] == "1") {
          formattedText = '<u>$formattedText</u>';
        }
        print("Combine Ids datas === > $id ==== > ${formattedText}");
        finlText += '$formattedText '; // Add a space between words
      }

      return finlText.trim();
    }

    String createVttContent(
      List<dynamic> captions,
    ) {
      StringBuffer vttContent = StringBuffer();
      vttContent.writeln('WEBVTT');

      Map<String, Map<String, dynamic>> combinedCaptions = {};

      for (var caption in captions) {
        List<int> idsIntList = caption['combine_ids']
            .toString()
            .split(",")
            .map((id) => int.parse(id.trim()))
            .toList();
        if (idsIntList.length == 1) {
          combinedCaptions[caption['id'].toString()] = {
            'start_from': caption['start_from'],
            'end_to': caption['end_to'],
            'text': formatText(caption),
          };
        } else {
          String combinedId = idsIntList.join("-");
          if (!combinedCaptions.containsKey(combinedId)) {
            combinedCaptions[combinedId] = {
              'start_from': caption['start_from'],
              'end_to': caption['end_to'],
              'text': formatTextForCombine(caption, captions),
            };
          } else {
            combinedCaptions[combinedId]?['end_to'] = caption['end_to'];
          }
        }
      }

      combinedCaptions.forEach((id, caption) {
        vttContent.writeln();
        vttContent.writeln('${caption["start_from"]} --> ${caption["end_to"]}');
        vttContent.writeln(caption["text"]);
      });

      return vttContent.toString();
    }

    // String createAssContent(List<dynamic> captions) {
    //   StringBuffer assContent = StringBuffer();
    //   assContent.writeln('[Script Info]');
    //   assContent.writeln('; Script generated by srtconverter');
    //   assContent.writeln('Title: Example');
    //   assContent.writeln('ScriptType: v4.00+');
    //   assContent.writeln('PlayDepth: 0');
    //   assContent.writeln('[V4+ Styles]');
    //   assContent.writeln(
    //       'Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding');
    //   assContent.writeln(
    //       'Style: Default,Arial,20,&H00FFFFFF,&H000000FF,&H00000000,&H64000000,-1,0,0,0,100,100,0,0,1,1,0,2,10,10,10,1');
    //   assContent.writeln('[Events]');
    //   assContent.writeln(
    //       'Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text');

    //   Map<String, Map<String, dynamic>> combinedCaptions = {};

    //   for (var caption in captions) {
    //     List<int> idsIntList = caption['combine_ids']
    //         .toString()
    //         .split(",")
    //         .map((id) => int.parse(id.trim()))
    //         .toList();
    //     if (idsIntList.length == 1) {
    //       combinedCaptions[caption['id'].toString()] = {
    //         'start_from': caption['start_from'],
    //         'end_to': caption['end_to'],
    //         'text': formatText(caption),
    //       };
    //     } else {
    //       String combinedId = idsIntList.join("-");
    //       if (!combinedCaptions.containsKey(combinedId)) {
    //         combinedCaptions[combinedId] = {
    //           'start_from': caption['start_from'],
    //           'end_to': caption['end_to'],
    //           'text': formatTextForCombine(caption, captions),
    //         };
    //       } else {
    //         combinedCaptions[combinedId]?['end_to'] = caption['end_to'];
    //       }
    //     }
    //   }

    //   combinedCaptions.forEach((id, caption) {
    //     assContent.writeln(
    //         'Dialogue: 0,${formatTime(caption["start_from"])},${formatTime(caption["end_to"])},Default,,0,0,0,,${caption["text"]}');
    //   });

    //   return assContent.toString();
    // }

    String vttContent = createVttContent(captionData);
    // String assContent = createAssContent(captionData);
    print('vttContent ==> $vttContent');
    Future<void> saveFile(String content, String extension) async {
      String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/captions_$timestamp.$extension';
      final file = File(filePath);
      await file.writeAsString(content);
      srtFilePath = filePath;
      if (extension == "ass") {
        ffmpegButton(true, isAssFile: true);
      } else {
        ffmpegButton(true, isAssFile: false);
      }
      print('$extension file saved at: $filePath');
    }

    await saveFile(vttContent, 'vtt');
    // await saveFile(assContent, 'ass');
  } */

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
      String textColor = caption['text_color'].toString().substring(2);
      String bgColor = caption['background_color'].toString().substring(2);

      String formattedText =
          '<font color="#$textColor" background="#$bgColor">$text</font>';

      if (caption['is_bold'] == "1") {
        text = '<b>$text</b>';
      }
      if (caption['is_italic'] == "1") {
        text = '<i>$text</i>';
      }
      if (caption['is_underline'] == "1") {
        text = '<u>$text</u>';
      }

      return '$formattedText';
    }

    String formatTextForCombine(
        Map<String, dynamic> caption, List<dynamic> captions) {
      List<int> idsIntList = caption['combine_ids']
          .toString()
          .split(",")
          .map((id) => int.parse(id.trim()))
          .toList();
      String finlText = "";
      for (var id in idsIntList) {
        var currentCaption =
            captions.firstWhere((e) => e['id'] == id, orElse: () => null);
        if (currentCaption == null) {
          return "";
        }
        print("currentCaption ==== > $currentCaption");
        String text = currentCaption['keyword'];
        String textColor = currentCaption['text_color'].toString().substring(4);
        String bgColor =
            currentCaption['background_color'].toString().substring(4);
        String formattedText =
            '<font color="#$textColor" background="#$bgColor">$text</font>';

        if (currentCaption['is_bold'] == "1") {
          formattedText = '<b>$formattedText</b>';
        }
        if (currentCaption['is_italic'] == "1") {
          formattedText = '<i>$formattedText</i>';
        }
        if (currentCaption['is_underline'] == "1") {
          formattedText = '<u>$formattedText</u>';
        }
        print("Combine Ids datas === > $id ==== > $formattedText");
        finlText += '$formattedText ';
      }
      return finlText.trim(); // Trim any trailing spaces
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
          combinedCaptions[caption['id'].toString()] = {
            'start_from': caption['start_from'],
            'end_to': caption['end_to'],
            'text': formatText(caption),
          };
        } else {
          String combinedId = idsIntList.join("-");
          if (!combinedCaptions.containsKey(combinedId)) {
            print("combinedIdIF ===> $combinedId ====> $combinedCaptions");
            combinedCaptions[combinedId] = {
              'start_from': caption['start_from'],
              'end_to': caption['end_to'],
              'text': formatTextForCombine(caption, captions),
            };
          } else {
            combinedCaptions[combinedId]?['end_to'] = caption['end_to'];
          }
        }
      }

      combinedCaptions.forEach((id, caption) {
        srtContent.writeln('${counter++}');
        srtContent.writeln(
            '${formatTime(caption["start_from"])} --> ${formatTime(caption["end_to"])}');
        srtContent.writeln(caption["text"]);
        srtContent.writeln();
      });

      return srtContent.toString();
    }

    String srtContent = createSrtContent(captionData);

    print('srtContent ==> $srtContent');

    Future<void> saveFile(String content, String extension) async {
      String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/captions_$timestamp.$extension';
      final file = File(filePath);
      await file.writeAsString(content);
      srtFilePath = filePath;
      print('$extension file saved at: $filePath');
      setState(() {});
    }

    await saveFile(srtContent, 'srt');
    ffmpegButton(true, isAssFile: false);
  }

//   Future<void> _addWatermark() async {
//   setState(() {
//   });

//   try {
//     final directory = await getApplicationDocumentsDirectory();
//     final watermarkPath = 'assets/watermark.png';
//     final outputPath = '${directory.path}/output.mp4';

//     // final watermarkAbsolutePath = await _getAssetAbsolutePath(watermarkPath);

//     final ffmpegCommand =
//         '-i ${widget.filePath} -i $watermarkAbsolutePath -filter_complex "overlay=10:10" -y $outputPath';

//     //   final ffmpegCommand =
//     // '-i ${widget.filePath} -i $watermarkAbsolutePath -filter_complex "overlay=10:10" -c:v libx264 -crf 20 -preset fast -b:v 2000k -y $outputPath';

//     final session = await FFmpegKit.execute(ffmpegCommand);
//     final returnCode = await session.getReturnCode();

//     if (ReturnCode.isSuccess(returnCode)) {
//       print('Watermark added successfully');
//       setState(() {
//         _outputPath = outputPath;
//         _initializeVideoPlayer();
//       });
//     } else {
//       final logs = await session.getAllLogsAsString();
//       final statistics = await session.getStatistics();
//       print('Failed to add watermark');
//       print('FFmpeg log: $logs');
//       print('FFmpeg statistics: $statistics');
//     }
//   } catch (e) {
//     print('Error adding watermark: $e');
//   } finally {
//     setState(() {
//     });
//   }
// }

  late String finalpath;
  String srtFilePath = "";
  String waterMarkPath = "";
  // void ffmpegButton(bool isCaption, {bool isAssFile = false}) async {
  //   print("ffmpge start");
  //   String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  //   int height = _videoPlayerController.value.size.height.round();
  //   int width = _videoPlayerController.value.size.width.round();
  //   print("width === > ${_videoPlayerController.value.size.width.toString()}");
  //   print(
  //       "height === > ${_videoPlayerController.value.size.height.toString()}");

  //   await VideoUtil.assetPath(VideoUtil.ASSET_1).then((path) {
  //     waterMarkPath = path;
  //   });
  //   // String cropFilter;
  //   // if (aspectRatio == 1 / 1) {
  //   //   cropFilter = "crop=in_h:in_h";
  //   // } else if (aspectRatio == 9 / 16) {
  //   //   cropFilter = "crop=in_h*9/16:in_h";
  //   // } else if (aspectRatio == 4 / 3) {
  //   //   cropFilter = "crop=in_h*4/3:in_h";
  //   // } else {
  //   //   print("Unsupported aspect ratio");
  //   //   return;
  //   // }
  //   finalpath = "/storage/emulated/0/Download/output_$timestamp.mp4";
  //   String command = "";
  //   int watermarkWidth = 300; // Example width
  //   int watermarkHeight = 100; // Example height
  //   String resizeFilter =
  //       '[1:v]scale=$watermarkWidth:$watermarkHeight [watermark];';

  //   String overlayFilter =
  //       '[0:v][watermark]overlay=' + '(main_w-overlay_w-20):(10)';

  //   String subtitleFilter = isAssFile
  //       ? 'ass=$srtFilePath'
  //       : "subtitles='$srtFilePath':force_style='Fontname=Roboto-Condensed-Bold,Fontsize=24,Outline=1,Shadow=1'";

  //   if (isCaption) {
  //     // Construct the FFmpeg command

  //     // '''-y -i "$_outputPath" -vf "${isAssFile ? "ass=" : "subtitles="}'$srtFilePath:force_style=Fontname=Trueno'" -s ${width}x$height "/storage/emulated/0/Download/output_${extension}_$timestamp.mp4"''';

  //    // working
  //     // '-i $downloadDirPath/mib2.mp4 -i $downloadDirPath/info2-image.png -filter_complex "overlay=10:10" -y $downloadDirPath/output999.mp4';// watermark working

  //     // command =
  //     //     '''-y -i "$_outputPath" -vf "${isAssFile ? "ass=" : "subtitles="}$srtFilePath:force_style='Fontname==Roboto-Condensed-Bold,Fontsize=24,Outline=1,Shadow=1'" -s ${width}x$height $finalpath''';

  //     command =
  //         '-y -i "$_outputPath" -i "$waterMarkPath" -filter_complex "$resizeFilter $overlayFilter,$subtitleFilter" -s ${width}x$height "$finalpath"';

  //     // '''-y -i "$_outputPath" -vf "$cropFilter,${isAssFile ? "ass=" : "subtitles="}$srtFilePath:force_style='Fontname=Trueno,Fontsize=24,Outline=1,Shadow=1,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,BackColour=&H80000000'" -s ${width}x$height "/storage/emulated/0/Download/output_${extension}_$timestamp.mp4"''';
  //     // '''-y -i "$_outputPath" -vf "$cropFilter,scale=$width:$height" -c:a copy "/storage/emulated/0/Download/output_${extension}_$timestamp.mp4"''';
  //   } else {
  //     // command = '''-i $_outputPath -c:v copy -y $finalpath''';
  //     command =
  //         '-y -i "$_outputPath" -i "$waterMarkPath" -filter_complex "$resizeFilter$overlayFilter" -c:v mpeg4 -q:v 5 -c:a aac -strict -2 "$finalpath"';
  //   }
  //   print("command === > $command");
  //   FFmpegKit.execute(command).then((session) async {
  //     final returnCode = await session.getReturnCode();

  //     final allLogs = await session.getAllLogs();
  //     allLogs.forEach((log) {
  //       print("session logs ==== > ${log.getMessage()}");
  //     });
  //     final satastic = await session.getAllStatistics();
  //     print("session satastic ==== > ${satastic.toString()}");
  //     satastic.forEach((satastic) {
  //       print("session Time ==== > ${satastic.getTime()}");
  //       print("session VideoQuality ==== > ${satastic.getVideoQuality()}");
  //     });
  //     print("session commonds === > ${session.getCommand()}");
  //     print("session Arguments === > ${session.getArguments()}");

  //     if (ReturnCode.isSuccess(returnCode)) {
  //       print("Log 1--------------------------------------> SUCCESS");
  //       setState(() {
  //         action = "Done";
  //         progressController.dispose();
  //       });
  //     } else if (ReturnCode.isCancel(returnCode)) {
  //       print("Log 2--------------------------------------> CANCEL");
  //     } else {
  //       print("Log 3--------------------------------------> ERROR");
  //       print('Error adding subtitles: ${await session.getFailStackTrace()}');
  //       print("${returnCode}");

  //       setState(() {
  //         action = "";
  //         progressController.dispose();
  //       });
  //     }
  //   });
  // }

  void ffmpegButton(bool isCaption, {bool isAssFile = false}) async {
    print("ffmpge start");
    String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    // int height = _videoPlayerController.value.size.height.round();
    // int width = _videoPlayerController.value.size.width.round();
    int height = _videoPlayerController.value.size.height.round();
    int width = _videoPlayerController.value.size.width.round();

    // height = width * 4 / 3;
    // height = width * 9 / 16;

    print("width === > ${_videoPlayerController.value.size.width.toString()}");
    print(
        "height === > ${_videoPlayerController.value.size.height.toString()}");

    await VideoUtil.assetPath(VideoUtil.ASSET_1).then((path) {
      waterMarkPath = path;
    });
    // String cropFilter;
    // if (aspectRatio == 1 / 1) {
    //   cropFilter = "crop=in_h:in_h";
    // } else if (aspectRatio == 9 / 16) {
    //   cropFilter = "crop=in_h*9/16:in_h";
    // } else if (aspectRatio == 4 / 3) {
    //   cropFilter = "crop=in_h*4/3:in_h";
    // } else {
    //   print("Unsupported aspect ratio");
    //   return;
    // }
    print("w ===> $w");
    print("h ===> $h");

    finalpath = "/storage/emulated/0/Download/output_$timestamp.mp4";
    String command = "";
    int watermarkWidth = 300; // Example width
    int watermarkHeight = 100; // Example height
    String resizeFilter =
        '[1:v]scale=$watermarkWidth:$watermarkHeight [watermark];';

    String overlayFilter =
        '[0:v][watermark]overlay=' + '(main_w-overlay_w-20):(10)';

    String subtitleFilter = isAssFile
        ? 'ass=$srtFilePath'
        : "subtitles='$srtFilePath':force_style='Fontname=Roboto-Condensed-Bold,Fontsize=$size,Outline=1,Shadow=1'";

    if (isCaption) {
      if (w == 1 && h == 1) {
        // width = 1080;
        height = width;
        command =
            '-y -i "$_outputPath" -i "$waterMarkPath" -filter_complex "[0:v]crop=$width:$height:420:0[video];$resizeFilter[video][watermark]overlay=(main_w-overlay_w-20):(10),$subtitleFilter" -s ${width}x$height -c:v mpeg4 -q:v 1 -c:a aac -b:a 192k -strict -2 "$finalpath"';
      } else if (w == 4 && h == 3) {
        // width = 1080;
        double height = (width * 3) / 4;
        int h = height.round();
        command =
            '-y -i "$_outputPath" -i "$waterMarkPath" -filter_complex "[0:v]crop=$width:$h:0:555[video];$resizeFilter[video][watermark]overlay=(main_w-overlay_w-20):(10),$subtitleFilter" -s ${width}x$h -c:v mpeg4 -q:v 1 -c:a aac -b:a 192k -strict -2 "$finalpath"';
      } else {
        command =
            '-y -i "$_outputPath" -i "$waterMarkPath" -filter_complex "$resizeFilter$overlayFilter,$subtitleFilter" -s ${width}x$height -c:v mpeg4 -q:v 1 -c:a aac -b:a 192k -strict -2 "$finalpath"';
      }
      // command =
      //     '-y -i "$_outputPath" -i "$waterMarkPath" -filter_complex "$resizeFilter$overlayFilter,$subtitleFilter" -s ${width}x$height -c:v mpeg4 -q:v 1 -c:a aac -b:a 192k -strict -2 "$finalpath"';
    } else {
      if (w == 1 && h == 1) {
        height = width;
        command =
            '-y -i "$_outputPath" -i "$waterMarkPath" -filter_complex "crop=$width:$height:0:420[video],$resizeFilter[video][watermark]overlay=(main_w-overlay_w-20):(10)" -c:v mpeg4 -q:v 1 -c:a aac -b:a 192k -strict -2 "$finalpath"';
      } else if (w == 4 && h == 3) {
         double height = (width * 3) / 4;
        int h = height.round();
        command =
            '-y -i "$_outputPath" -i "$waterMarkPath" -filter_complex "crop=$width:$h:0:555[video],$resizeFilter[video][watermark]overlay=(main_w-overlay_w-20):(10)" -c:v mpeg4 -q:v 1 -c:a aac -b:a 192k -strict -2 "$finalpath"';
      } else {
        command =
            '-y -i "$_outputPath" -i "$waterMarkPath" -filter_complex "$resizeFilter$overlayFilter" -c:v mpeg4 -q:v 1 -c:a aac -strict -2 "$finalpath"';
      }
      // command =
      //     '-y -i "$_outputPath" -i "$waterMarkPath" -filter_complex "$resizeFilter$overlayFilter" -c:v mpeg4 -q:v 1 -c:a aac -strict -2 "$finalpath"';
    }
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
        setState(() {
          action = "Done";
          progressController.dispose();
        });
      } else if (ReturnCode.isCancel(returnCode)) {
        print("Log 2--------------------------------------> CANCEL");
      } else {
        print("Log 3--------------------------------------> ERROR");
        print('Error adding subtitles: ${await session.getFailStackTrace()}');
        print("${returnCode}");

        setState(() {
          action = "";
          progressController.dispose();
        });
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

  // Widget _buildMenu() {
  //   return MenuBar(style: MenuStyle(), children: [
  //     Text("Rename"),
  //   ]);
  // }

  void _showRenameDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController(text: name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename File'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Enter new name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _renameFile(int.parse(widget.videoID), _controller.text);
                Navigator.pop(context);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameFile(int videoId, String newName) async {
    if (newName.isNotEmpty) {
      await _databaseService.renameFile(videoId, newName);
      // setState(() {
      //   _data = _databaseService.getFilesWithHighestVersion();
      // });
    }
  }

  Future<void> _deleteFile(int videoId) async {
    await _databaseService
        .deleteFile(videoId); // Assuming a deleteFile method exists
    await _databaseService.deleteCaptionData(videoId);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectsScreen(),
      ),
      (route) => false,
    );
  }
}
