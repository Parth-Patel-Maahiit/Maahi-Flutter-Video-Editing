import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_video/log.dart';
import 'package:ffmpeg_kit_flutter_video/return_code.dart';
import 'package:ffmpeg_kit_flutter_video/session.dart';
import 'package:ffmpeg_kit_flutter_video/statistics.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editing_app/UI/UseVideo/usescreen.dart';
import 'package:video_editing_app/UI/components/common.dart';
import 'package:video_editing_app/services/databaseservices.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/util/app_images.dart';

import '../widget/button.dart';

class AudioPicker extends StatefulWidget {
  final String? audiopath;
  final String filepath;
  final String? videoID;

  const AudioPicker({
    super.key,
    this.audiopath,
    required this.filepath,
    this.videoID,
  });

  @override
  State<AudioPicker> createState() => _AudioPickerState();
}

class _AudioPickerState extends State<AudioPicker> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _audioPath;
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isSeeking = false;

  bool isloading = false;
  late int id;

  @override
  void initState() {
    super.initState();

    // Set the initial audio path from the widget if available
    _audioPath = widget.audiopath;

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (!_isSeeking) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _position = Duration.zero;
        isPlaying = false;
      });
    });
    _getVidId();
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      String? audioPath = result.files.single.path;
      setState(() {
        _audioPath = audioPath;
      });
      print("path ==> $audioPath");
    } else {
      // User canceled the picker
      print('Audio file picking canceled');
      _showSnackBar('Audio file picking canceled');
    }
  }

  Future<void> _playPauseAudio() async {
    if (_audioPath == null) {
      await _pickAudio();
    }
    if (_audioPath != null) {
      if (isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          isPlaying = false;
        });
      } else {
        await _audioPlayer.play(DeviceFileSource(_audioPath!));
        setState(() {
          isPlaying = true;
        });
      }
    }
  }

  void _seekAudio(double value) {
    final position = value * _duration.inMilliseconds;
    _audioPlayer.seek(Duration(milliseconds: position.round()));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  late int vidId;

  Future<void> _getVidId() async {
    vidId = await _databaseService.getVidId(widget.filepath);
    setState(() {});
  }

  Future<String> _getOutputDirectoryPath() async {
    final directory = await getDownloadsDirectory();
    print("directory ========>  $directory");
    String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    // return '${directory?.path}/output_$timestamp.mp4'; // Include timestamp in the file name
    return '/storage/emulated/0/Download/output_$timestamp.mp4'; // Include timestamp in the file name
  }

  late String outputpath;

  Future<void> _merge() async {
    outputpath = await _getOutputDirectoryPath();

    // Add your merging command logic here, e.g., using FFmpeg
    //  '-i $downloadDirPath/mib2.mp4 -i $downloadDirPath/aduio.mp3 -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 -y $downloadDirPath/output909.mp4'; // working add audio
    String command =
        '-i ${widget.filepath} -i $_audioPath -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 -shortest -y $outputpath';
    print("Merging command: $command");

    // Execute the merging command

    FFmpegKit.executeAsync(command, (Session session) async {
      // CALLED WHEN SESSION IS EXECUTED
      print("session =========> ${session.getCommand()}");
    }, (Log log) {
      print("log =========> ${log.getMessage()}");
      // CALLED WHEN SESSION PRINTS LOGS
    }, (Statistics statistics) {
      print("log =========> ${statistics.getTime()}");
      // CALLED WHEN SESSION GENERATES STATISTICS
    });
    FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        print("Log 1--------------------------------------> SUCCESS");
        String thumbnailPath = await generateThumbnail(outputpath);
        _databaseService.editFile(vidId, outputpath, thumbnailPath);
        setState(() {
          isloading = false;
        });

        Navigator.of(context)
          ..pop()
          ..pushReplacement(MaterialPageRoute(
              builder: (context) => UseScreen(
                    filePath: outputpath,
                    videoID: widget.videoID,
                  )));
      } else if (ReturnCode.isCancel(returnCode)) {
        // CANCEL
        print("Log 2--------------------------------------> CANCEL");
      } else {
        // ERROR
        print("Log 3--------------------------------------> ERROR");
        print("${returnCode}");
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg_color,
      body: SafeArea(
        child: isloading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      AppImages.splace,
                    ),
                    Text(
                      "Merging Video Please wait",
                      style:
                          TextStyle(color: AppColor.white_color, fontSize: 24),
                    )
                  ],
                ),
              )
            : Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          splashFactory: NoSplash.splashFactory,
                          highlightColor: Colors.transparent,
                          onTap: _playPauseAudio,
                          child: Container(
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: AppColor.white_color,
                              size: 50,
                            ),
                          ),
                        ),
                        Slider(
                          min: 0.0,
                          max: _duration.inMilliseconds.toDouble(),
                          value: (_position.inMilliseconds.toDouble())
                              .clamp(0.0, _duration.inMilliseconds.toDouble()),
                          onChanged: (value) {
                            setState(() {
                              _position = Duration(milliseconds: value.round());
                            });
                          },
                          onChangeStart: (value) {
                            setState(() {
                              _isSeeking = true;
                            });
                          },
                          onChangeEnd: (value) {
                            _seekAudio(value / _duration.inMilliseconds);
                            setState(() {
                              _isSeeking = false;
                            });
                          },
                        ),
                        Text(
                          '${_position.toString().split('.').first} / ${_duration.toString().split('.').first}',
                          style: TextStyle(color: AppColor.white_color),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 1,
                    right: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CommonButton(
                            bgcolor: AppColor.elevated_bg_color,
                            text: "Pick Audio",
                            image: AppImages.folder,
                            onPressed: () {
                              _pickAudio();
                            },
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          CommonButton(
                            bgcolor: AppColor.elevated_bg_color,
                            text: "Merge",
                            image: AppImages.folder,
                            onPressed: () {
                              setState(() {
                                isloading = true;
                                _audioPlayer.pause();
                              });
                              _merge();
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
