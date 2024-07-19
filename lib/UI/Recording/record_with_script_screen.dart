import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editing_app/API/commonapicall.dart';
import 'package:video_editing_app/CommonMettods/common_sharedPreferences.dart';
import 'package:video_editing_app/Model/login_model.dart';
import 'package:video_editing_app/UI/Video_Preview/script_preview.dart';
import 'package:video_editing_app/UI/components/common.dart';
import 'package:video_editing_app/services/databaseservices.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/util/app_images.dart';

class RecordWithScriptScreen extends StatefulWidget {
  final String title;
  final String script;

  const RecordWithScriptScreen({
    super.key,
    required this.title,
    required this.script,
  });

  @override
  State<RecordWithScriptScreen> createState() => _RecordWithScriptScreenState();
}

class _RecordWithScriptScreenState extends State<RecordWithScriptScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  LoginModel? _login = LoginModel();

  late ScrollController _scrollController;
  late Timer _autoScrollTimer;
  late Duration scdu = Duration(seconds: 4);

  bool isfont = false;
  bool isspeed = false;

  CameraAspectRatios ratio = CameraAspectRatios.ratio_16_9;

  // late SensorPosition _currentSensor;
  // Sensor? sensor;

  String filePath = "";
  CaptureRequest? captureRequest;
  String _recordingTime = '00:00';
  late Timer _timer;
  int _recordingDuration = 0;
  bool settimer = false;
  CameraAspectRatios _aspectRatio = CameraAspectRatios.ratio_16_9;

  double fsize = 24;
  double _scrollspeed = 100.0;
  bool isrecording = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _autoScrollTimer.cancel();
    _timer.cancel();
    super.dispose();
  }

  late String script_id;

  Future<void> AddSript(String title, String script) async {
    var loginData = await getStoreApidata("loginData");
    if (loginData != null) {
      _login = LoginModel.fromJson(loginData);
    }

    print(_login!.data);

    if (_login != null && _login!.data?.id != null) {
      var response = await CommonApiCall.getApiData(
          action:
              "action=add_script&user_id=${_login!.data?.id}&title=$title&script_text=$script");

      if (response != null) {
        final responseData = json.decode(response.body);
        print(_login?.data);
        print("id of the script is === >>>${responseData["data"]}");
        setState(() {
          script_id = responseData["data"];
        });

        if (responseData['status'] == 'success') {
          print("Script added successfully");
        } else {
          print("Failed to add script: ${responseData['message']}");
        }
      } else {
        print('Error: Response is null');
      }
    } else {
      print('Error: User is not logged in');
    }
  }

  Future<void> AddVideo(String title, String id, String path) async {
    var loginData = await getStoreApidata("loginData");
    if (loginData != null) {
      _login = LoginModel.fromJson(loginData);
    }

    if (_login != null && _login!.data?.id != null) {
      var response = await CommonApiCall.getApiData(
          action:
              "user_id=${_login!.data?.id}&action=add_video&title=$title&script_id=$id&file_name=$path");
      if (response != null) {
        final responseData = json.decode(response.body);
        print(_login?.data);
        if (responseData['status'] == 'success') {
          print("Script added successfully");
        } else {
          print("Failed to add script: ${responseData['message']}");
        }
      } else {
        print('Error: Response is null');
      }
    } else {
      print('Error: User is not logged in');
    }
  }

  void _startRecordingTimer() {
    _recordingDuration = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _recordingDuration++;
      final minutes = _recordingDuration ~/ 60;
      final seconds = _recordingDuration % 60;
      setState(() {
        _recordingTime =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });
    });
  }

  void _stopRecordingTimer() {
    _timer.cancel();
    setState(() {
      _recordingTime = '00:00';
    });
  }

  _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent) {
        _autoScrollTimer.cancel();
      } else {
        _scrollController.animateTo(
          _scrollController.offset + _scrollspeed,
          duration: scdu,
          curve: Curves.linear,
        );
      }
    });
    // }
  }

  Future<String> _buildFilePath(SensorPosition position) async {
    final Directory extDir = await getTemporaryDirectory();
    final Directory testDir =
        await Directory('${extDir.path}/camerawesome').create(recursive: true);
    return '${testDir.path}/${position == SensorPosition.front ? 'front_' : 'back_'}${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  // Future<void> _handleOnPress(CameraState state) async {
  //   if (state is VideoRecordingCameraState) {
  //     if (_recordingDuration <= 1) {
  //       await Future.delayed(Duration(seconds: 1 - _recordingDuration));
  //     }
  //     await state.stopRecording();
  //     String durationOfVideo = _recordingTime;
  //     _stopRecordingTimer();
  //     if (captureRequest?.path != null) {
  //       filePath = captureRequest!.path!;
  //       try {
  //         String thumbnailPath = await generateThumbnail(filePath);

  //         await _databaseService.addfile(
  //             filePath, thumbnailPath, widget.title, widget.title, 9, 16);

  //         AddVideo(widget.title, script_id, filePath);

  //         // Calculate intervals
  //         print("durationOfVideo === > $durationOfVideo");
  //         int videoID = await _databaseService.getVidId(filePath);
  //         final int durationInSeconds = parseDuration(durationOfVideo);
  //         print("Video duration: $durationInSeconds seconds");

  //         final int intervalMilliseconds = 500;
  //         // final int delayMilliseconds = 100;
  //         final int totalIntervals =
  //             (durationInSeconds * 1000 / intervalMilliseconds).ceil();
  //         // final int totalIntervals = (durationInSeconds *
  //         //         1000 /
  //         //         (intervalMilliseconds + delayMilliseconds))
  //         //     .ceil();

  //         List<String> parts = widget.script
  //             .split(RegExp(r'\s+'))
  //             .where((part) => part.isNotEmpty)
  //             .toList();
  //         int partIndex = 0;
  //         for (int i = 0; i < totalIntervals && partIndex < parts.length; i++) {
  //           final int startTimeMs = i * intervalMilliseconds;
  //           final int endTimeMs = startTimeMs + intervalMilliseconds;
  //           final String startTime =
  //               _formatDuration(Duration(milliseconds: startTimeMs));
  //           final String endTime =
  //               _formatDuration(Duration(milliseconds: endTimeMs));
  //           await _databaseService.addCaptions(
  //             videoId: videoID.toString(),
  //             startTime: startTime,
  //             toTime: endTime,
  //             keywords: parts[partIndex],
  //             text: parts[partIndex],
  //           );
  //           partIndex++;
  //         }
  //         //var ff = _databaseService.addfile(filePath);
  //         Navigator.of(context)
  //           ..pop()
  //           ..pushReplacement(
  //             MaterialPageRoute(
  //                 builder: (context) => VideoSavePage(
  //                       videoID: videoID.toString(),
  //                       filePath: filePath,
  //                       isBackExport: true,
  //                     )),
  //           );
  //         print("File is saved successfully to the database");
  //       } catch (e) {
  //         print("Error storing file == > ${e.toString()}");
  //       }
  //       setState(() {
  //         isrecording = false;
  //         settimer = false;
  //         //myfile = File(filePath);
  //       });
  //     }
  //   } else if (state is VideoCameraState) {
  //     captureRequest = await state.startRecording();
  //     _startRecordingTimer();
  //     _startAutoScroll();
  //     AddSript(widget.title, widget.script);
  //     setState(() {
  //       isrecording = true;
  //       isspeed = true;
  //       isfont = false;
  //       settimer = true;
  //     });
  //   }
  // }

  Future<void> _handleOnPress(CameraState state) async {
    if (state is VideoRecordingCameraState) {
      if (_recordingDuration <= 1) {
        await Future.delayed(Duration(seconds: 1 - _recordingDuration));
      }
      await state.stopRecording();
      String durationOfVideo = _recordingTime;
      _stopRecordingTimer();
      if (captureRequest?.path != null) {
        filePath = captureRequest!.path!;
        try {
          String thumbnailPath = await generateThumbnail(filePath);

          await _databaseService.addfile(
              filePath, thumbnailPath, widget.title, widget.title, 9, 16);

          AddVideo(widget.title, script_id, filePath);

          // Calculate intervals
          print("durationOfVideo === > $durationOfVideo");
          int videoID = await _databaseService.getVidId(filePath);
          final int durationInSeconds = parseDuration(durationOfVideo);
          print("Video duration: $durationInSeconds seconds");

          final int intervalMilliseconds = 500;
          final int firstWordDuration = 1000; // 1 second

          List<String> parts = widget.script
              .split(RegExp(r'\s+'))
              .where((part) => part.isNotEmpty)
              .toList();
          int partIndex = 0;

          // Handle the first word separately
          if (partIndex < parts.length) {
            await _databaseService.addCaptions(
              videoId: videoID.toString(),
              startTime: _formatDuration(Duration(milliseconds: 0)),
              toTime:
                  _formatDuration(Duration(milliseconds: firstWordDuration)),
              keywords: parts[partIndex],
              text: parts[partIndex],
            );
            partIndex++;
          }

          // Handle the rest of the words
          for (int i = 1;
              i < durationInSeconds * 1000 / intervalMilliseconds &&
                  partIndex < parts.length;
              i++) {
            final int startTimeMs =
                firstWordDuration + (i - 1) * intervalMilliseconds;
            final int endTimeMs = startTimeMs + intervalMilliseconds;
            final String startTime =
                _formatDuration(Duration(milliseconds: startTimeMs));
            final String endTime =
                _formatDuration(Duration(milliseconds: endTimeMs));
            await _databaseService.addCaptions(
              videoId: videoID.toString(),
              startTime: startTime,
              toTime: endTime,
              keywords: parts[partIndex],
              text: parts[partIndex],
            );
            partIndex++;
          }

          Navigator.of(context)
            ..pop()
            ..pushReplacement(
              MaterialPageRoute(
                  builder: (context) => VideoSavePage(
                        videoID: videoID.toString(),
                        filePath: filePath,
                        isBackExport: true,
                      )),
            );
          print("File is saved successfully to the database");
        } catch (e) {
          print("Error storing file == > ${e.toString()}");
        }
        setState(() {
          isrecording = false;
          settimer = false;
          //myfile = File(filePath);
        });
      }
    } else if (state is VideoCameraState) {
      captureRequest = await state.startRecording();
      _startRecordingTimer();
      _startAutoScroll();
      AddSript(widget.title, widget.script);
      setState(() {
        isrecording = true;
        isspeed = true;
        isfont = false;
        settimer = true;
      });
    }
  }

  int parseDuration(String duration) {
    final parts = duration.split(':');
    final minutes = int.parse(parts[0]);
    final seconds = int.parse(parts[1]);
    return minutes * 60 + seconds;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    final String threeDigitMilliseconds =
        (duration.inMilliseconds.remainder(1000)).toString().padLeft(3, '0');
    return "00:$twoDigitMinutes:$twoDigitSeconds.$threeDigitMilliseconds";
  }

  void _increaseScrollSpeed() {
    setState(() {
      _scrollspeed += 100.0;
    });
  }

  void _decreaseScrollSpeed() {
    setState(() {
      _scrollspeed = (_scrollspeed - 100.0).clamp(100.0, double.infinity);
    });
  }

  void _increasefontsize() {
    setState(() {
      fsize = fsize + 1;
    });
  }

  void _decreasefontsize() {
    setState(() {
      if (fsize >= 2) {
        fsize = fsize - 1;
      } else {
        fsize = 1;
      }
    });
  }

  void _switchCamera(CameraState state) {
    setState(() {
      state.switchCameraSensor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraAwesomeBuilder.custom(
            progressIndicator: Center(
              child: CircularProgressIndicator(
                color: AppColor.home_plus_color,
              ),
            ),
            builder: (state, preview) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  isrecording
                      ? Container(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "",
                                    style: TextStyle(color: Colors.yellow),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(40),
                                        border: Border.all(
                                            color: AppColor.white_color,
                                            width: 3)),
                                    child: InkWell(
                                      splashFactory: NoSplash.splashFactory,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        _handleOnPress(state);
                                        setState(() {
                                          isrecording = false;
                                        });
                                      },
                                      child: Icon(
                                        Icons.stop,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container(
                          color: Color.fromARGB(127, 37, 34, 34),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: isspeed
                                              ? Border.all(
                                                  color: AppColor.white_color)
                                              : null,
                                          shape: BoxShape.rectangle),
                                      child: Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (isspeed == true) {
                                                  isspeed = false;
                                                } else {
                                                  isspeed = true;
                                                  if (isfont == true) {
                                                    isfont = false;
                                                  }
                                                }
                                              });
                                            },
                                            icon: ImageIcon(
                                                AssetImage(AppImages.speed)),
                                            color: AppColor.white_color,
                                          ),
                                          Text("speed",
                                              style: TextStyle(
                                                  color: AppColor.white_color))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: isfont
                                              ? Border.all(
                                                  color: AppColor.white_color)
                                              : null),
                                      child: Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (isfont == true) {
                                                  isfont = false;
                                                } else {
                                                  isfont = true;
                                                  if (isspeed == true) {
                                                    isspeed = false;
                                                  }
                                                }
                                              });
                                            },
                                            icon: ImageIcon(
                                                AssetImage(AppImages.A)),
                                            color: AppColor.white_color,
                                          ),
                                          Text("Font",
                                              style: TextStyle(
                                                  color: AppColor.white_color))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        splashFactory: NoSplash.splashFactory,
                                        highlightColor: Colors.transparent,
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                              color: AppColor.white_color),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            //color: AppColor.white_color,
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                border: Border.all(
                                                    color: AppColor.white_color,
                                                    width: 3)),
                                            child: InkWell(
                                              splashFactory:
                                                  NoSplash.splashFactory,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () {
                                                _handleOnPress(state);
                                                //state.switchCameraSensor();
                                                setState(() {
                                                  isrecording = true;
                                                });
                                              },
                                              child: Icon(
                                                // state is VideoRecordingCameraState
                                                //     ? Icons.stop
                                                Icons.circle,
                                                color: Colors.red,
                                                size: 50,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        // onPressed: _switchCamera,
                                        onPressed: () {
                                          state.switchCameraSensor();
                                          // state.
                                          //_switchCamera;
                                        },
                                        icon: ImageIcon(
                                          AssetImage(AppImages.camera_flip),
                                          color: AppColor.white_color,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                ],
              );
            },
            sensorConfig: SensorConfig.single(
              sensor: Sensor.position(SensorPosition.front),
              aspectRatio: _aspectRatio,
              flashMode: FlashMode.auto,
            ),
            enablePhysicalButton: true,
            previewAlignment: Alignment.center,
            previewFit: CameraPreviewFit.fitHeight,
            saveConfig: SaveConfig.video(
                videoOptions: VideoOptions(
                  quality: VideoRecordingQuality.highest,
                  enableAudio: true,
                  ios: CupertinoVideoOptions(
                    fps: 30,
                  ),
                  android: AndroidVideoOptions(
                    bitrate: 6000,
                    fallbackStrategy: QualityFallbackStrategy.lower,
                  ),
                ),
                mirrorFrontCamera: true),
            //availableFilters: awesomePresetFiltersList,
          ),
          Positioned(
            top: 98,
            left: 1,
            right: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 300,
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                    //color: Colors.black.withOpacity(0.5),
                    //borderRadius: BorderRadius.circular(8.0),
                    ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(
                    widget.script,
                    style: TextStyle(
                        color: AppColor.white_color,
                        fontSize: fsize,
                        fontStyle: FontStyle.normal),
                  ),
                ),
              ),
            ),
          ),
          isfont
              ? Positioned(
                  top: 550,
                  left: 1,
                  right: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        splashFactory: NoSplash.splashFactory,
                        highlightColor: Colors.transparent,
                        onTap: _increasefontsize,
                        child: Container(
                          //color: Colors.amber,
                          child: ImageIcon(
                            AssetImage(AppImages.plus1),
                            size: 40,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        "${fsize}",
                        style: TextStyle(color: AppColor.white_color),
                      ),
                      SizedBox(width: 20),
                      InkWell(
                        splashFactory: NoSplash.splashFactory,
                        highlightColor: Colors.transparent,
                        onTap: _decreasefontsize,
                        child: Container(
                          //color: Colors.amber,
                          child: ImageIcon(
                            AssetImage(AppImages.minus),
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          isspeed
              ? Positioned(
                  top: 550,
                  left: 1,
                  right: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        //color: Colors.blue,
                        child: Row(
                          children: [
                            InkWell(
                              splashFactory: NoSplash.splashFactory,
                              highlightColor: Colors.transparent,
                              onTap: _increaseScrollSpeed,
                              child: Container(
                                //color: Colors.amber,
                                child: ImageIcon(
                                  AssetImage(AppImages.plus1),
                                  size: 40,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Text(
                              "${_scrollspeed / 10}",
                              style: TextStyle(color: AppColor.white_color),
                            ),
                            SizedBox(width: 20),
                            InkWell(
                              splashFactory: NoSplash.splashFactory,
                              highlightColor: Colors.transparent,
                              onTap: _decreaseScrollSpeed,
                              child: Container(
                                //color: Colors.amber,
                                child: ImageIcon(
                                  AssetImage(AppImages.minus),
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          Positioned(
            top: 60,
            left: 1,
            right: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: settimer ? Colors.red : Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _recordingTime,
                    style: TextStyle(
                      color: AppColor.white_color,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
