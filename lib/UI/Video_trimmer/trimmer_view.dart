import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_editing_app/Model/get_caption_data_model.dart';
import 'package:video_editing_app/UI/UseVideo/usescreenfortrimmer.dart';
import 'package:video_editing_app/UI/components/common.dart';
import 'package:video_editing_app/UI/components/common_save_button.dart';
import 'package:video_editing_app/services/databaseservices.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../widget/video_caption.dart';

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
  late VideoPlayerController _videoPlayerController;
  bool isPlaying = false;
  double? aspectRatio;
  late int vidId;
  late String _outputPath;

  List<GetCaptionDataModel> _getCations = [];

  @override
  void initState() {
    super.initState();
    _outputPath = widget.file.path;
    getCaptionData();
    getratio();
    _videoPlayerController = VideoPlayerController.file(File(_outputPath))
      ..initialize().then((_) {
        setState(() {
          getratio();
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
        });
      });
    _loadVideo();
    _getVidId();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  late double h, w;

  Future<void> getratio() async {
    w = await _databaseService.getwidth(_outputPath);
    print("width === > $w");
    h = await _databaseService.getheight(_outputPath);
    print("height === > $h");
    aspectRatio = w / h;
  }

  Future<void> _initializeVideoPlayer() async {
    print("Initializing video player with file path: ${w}");
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

  Future<void> _getVidId() async {
    String path = widget.file.path;
    vidId = await _databaseService.getVidId(path);
    setState(() {});
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
      isPlaying
          ? _videoPlayerController.play()
          : _videoPlayerController.pause();
    });
  }

  Future<void> _saveVideo() async {
    setState(() {});

    _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) async {
        setState(() {});
        debugPrint('OUTPUT PATH: $outputPath');
        try {
          String thumbnailPath = await generateThumbnail(outputPath);
          _databaseService.editFile(vidId, outputPath, thumbnailPath);
        } catch (e) {
          print("Error saving trimmed video to database: $e");
        }

        // Navigator.of(context).pushReplacement(
        // MaterialPageRoute(
        //   builder: (context) => UseScreen2(
        //     filePath: outputPath,
        //   ),
        // )
        // );
        Navigator.of(context)
          ..pop()
          ..pushReplacement(MaterialPageRoute(
            builder: (context) => UseScreen2(
              videoID: widget.videoID,
              filePath: outputPath,
            ),
          ));
      },
    );
  }

  void getCaptionData() async {
    if (widget.videoID != null) {
      var captionData =
          await _databaseService.getCaptionForVideo(videoId: widget.videoID!);
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
        body: SafeArea(
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
              Positioned(
                bottom: 30,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 17),
                  child: TrimViewer(
                      trimmer: _trimmer,
                      viewerHeight: 50.0,
                      viewerWidth: MediaQuery.of(context).size.width,
                      durationStyle: DurationStyle.FORMAT_HH_MM_SS,
                      maxVideoLength: Duration(hours: 5),
                      editorProperties: TrimEditorProperties(
                        borderPaintColor: AppColor.blue_color,
                        borderWidth: 4,
                        borderRadius: 5,
                        circlePaintColor: AppColor.white_color,
                      ),
                      areaProperties: TrimAreaProperties.edgeBlur(
                        thumbnailQuality: 10,
                      ),
                      onChangeStart: (value) => _startValue = value,
                      onChangeEnd: (value) => _endValue = value,
                      onChangePlaybackState: (value) {}),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: CommonSaveButton(
                  onTap: _saveVideo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
