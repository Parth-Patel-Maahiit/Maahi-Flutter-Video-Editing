import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editing_app/UI/UseVideo/usescreenfortrimmer.dart';
import 'package:video_editing_app/UI/components/common_save_button.dart';
import 'package:video_editing_app/services/databaseservices.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../Model/get_caption_data_model.dart';
import '../../services/databaseMethods.dart';
import '../components/common.dart';

class TrimmerView extends StatefulWidget {
  final File file;
  final String? videoID;
  TrimmerView({
    Key? key,
    required this.file,
    this.videoID,
  }) : super(key: key);
  @override
  State<TrimmerView> createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  List<GetCaptionDataModel> getCations = [];
  //File f = Widget.filePath;
  @override
  void initState() {
    super.initState();
    _loadVideo();
    getCaptionDatas();
    _getVidId();
  }

  void getCaptionDatas() async {
    if (widget.videoID != null) {
      getCations = await Databasemethods.getCaptionData(widget.videoID);
    }
    setState(() {});
  }

  Future<String> _generateThumbnail(String videoPath) async {
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

  late int vidId;
  Future<void> _getVidId() async {
    String path = widget.file.path;
    vidId = await _databaseService.getVidId(path);
    setState(() {});
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
    getratio();
  }

  _saveVideo() {
    _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) async {
        debugPrint('OUTPUT PATH: $outputPath');
        try {
          String thumbnailPath = await _generateThumbnail(outputPath);
          _databaseService.editFile(vidId, outputPath, thumbnailPath);
        } catch (e) {
          print("Error saving trimmed video to database: $e");
        }
        Navigator.of(context)
<<<<<<< Updated upstream
          ..pop
=======
          ..pop()
>>>>>>> Stashed changes
          ..pushReplacement(MaterialPageRoute(
              builder: (context) => UseScreen2(
                    filePath: outputPath,
                    videoID: widget.videoID,
                  )));
      },
    );
    setState(() {});
  }

  late double h, w;
  double? aspectRatio;

  Future<void> getratio() async {
    w = await _databaseService.getwidth(widget.file.path);
    print("width === > $w");
    h = await _databaseService.getheight(widget.file.path);
    print("height === > $h");
    aspectRatio = w / h;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.bg_color,
        body: SafeArea(
          child: SizedBox(
            height: height * 0.96,
            child: Stack(
              children: [
                if (_trimmer.videoPlayerController != null)
                  Container(
                    height: height * 0.8,
                    margin: EdgeInsets.only(top: 40),
                    child: GestureDetector(
                      onTap: () async {
                        bool playbackState =
                            await _trimmer.videoPlaybackControl(
                          startValue: _startValue,
                          endValue: _endValue,
                        );
                        setState(() => _isPlaying = playbackState);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: Colors.black,
                              child: _trimmer.videoPlayerController!.value
                                          .isInitialized &&
                                      aspectRatio != null
                                  ? AspectRatio(
                                      aspectRatio: aspectRatio!,
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: _trimmer.videoPlayerController!
                                              .value.size.width,
                                          height: _trimmer
                                              .videoPlayerController!
                                              .value
                                              .size
                                              .height,
                                          child: Stack(
                                            children: [
                                              VideoViewer(trimmer: _trimmer),
                                              Center(
                                                child: AnimatedOpacity(
                                                  opacity:
                                                      _isPlaying ? 0.0 : 1.0,
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color.fromARGB(
                                                            175, 21, 20, 20)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: 100,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (getCations.isNotEmpty)
                                                Positioned(
                                                  right: 1,
                                                  left: 1,
                                                  bottom: aspectRatio == 9 / 16
                                                      ? height * 0.1
                                                      : aspectRatio == 1 / 1
                                                          ? height * 0.6
                                                          : height * 0.75,
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 30),
                                                      child: captionData()),
                                                )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: CircularProgressIndicator(
                                      color: AppColor.home_plus_color,
                                    )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 40,
                  left: 1,
                  right: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: TrimViewer(
                      trimmer: _trimmer,
                      viewerHeight: 50.0,
                      viewerWidth: MediaQuery.of(context).size.width,
                      durationStyle: DurationStyle.FORMAT_HH_MM_SS,
                      maxVideoLength: Duration(hours: 5),
                      editorProperties: TrimEditorProperties(
                        borderPaintColor: AppColor.home_plus_color,
                        borderWidth: 4,
                        borderRadius: 5,
                        circlePaintColor: Colors.white,
                      ),
                      areaProperties: TrimAreaProperties.edgeBlur(
                        thumbnailQuality: 10,
                      ),
                      onChangeStart: (value) => _startValue = value,
                      onChangeEnd: (value) => _endValue = value,
                      onChangePlaybackState: (value) =>
                          setState(() => _isPlaying = value),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: CommonSaveButton(
                    onTap: () {
                      _saveVideo();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget captionData() {
    String startPoint = "";
    String endPoint = "";
    List<TextSpan> textSpans = [];

    for (var caption in getCations) {
      List<int> idsIntList = caption.combineIds
          .toString()
          .split(",")
          .map((id) => int.parse(id.trim()))
          .toList();
      var firstCaption = getCations.firstWhere((c) => c.id == idsIntList.first);
      var lastCaption = getCations.firstWhere((c) => c.id == idsIntList.last);
      startPoint = firstCaption.startFrom;
      endPoint = lastCaption.endTo;
      if (_trimmer.videoPlayerController!.value.position >
              parseDuration(startPoint) &&
          (_trimmer.videoPlayerController!.value.position <
              parseDuration(endPoint))) {
        textSpans.add(
          TextSpan(
            text: caption.keyword + " ",
            style: TextStyle(
              fontWeight:
                  caption.isBold == "1" ? FontWeight.bold : FontWeight.normal,
              fontStyle:
                  caption.isItalic == "1" ? FontStyle.italic : FontStyle.normal,
              decoration: caption.isUnderLine == "1"
                  ? TextDecoration.underline
                  : TextDecoration.none,
              fontSize: 70,
              color: Color(int.parse(caption.textColor.toString())),
            ),
          ),
        );
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 30.0, color: Colors.white),
          children: textSpans,
        ),
      ),
    );
  }
}
