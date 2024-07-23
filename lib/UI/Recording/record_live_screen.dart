import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editing_app/API/commonapicall.dart';
import 'package:video_editing_app/Model/login_model.dart';
import 'package:video_editing_app/UI/UseVideo/usescreen.dart';
import 'package:video_editing_app/UI/components/common.dart';

import 'package:video_editing_app/services/databaseservices.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/util/app_images.dart';

import '../../CommonMettods/common_sharedPreferences.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  SensorPosition _currentSensorPosition = SensorPosition.front;
  CameraAspectRatios _aspectRatio = CameraAspectRatios.ratio_16_9;
  String _recordingTime = '00:00';
  late Timer _timer;
  int _recordingDuration = 0;
  bool isrecording = false;

  late int vid_id;
  late int status = 0;

  @override
  void initState() {
    super.initState();
    //_currentSensorPosition = SensorPosition.back; // Default to back camera
    print("original ratio is ===> ${_aspectRatio.toString()}");
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  LoginModel? _login = LoginModel();
  late String script_id;

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

  String filePath = "";
  CaptureRequest? captureRequest;
  //late File myfile;

  Future<String> _buildFilePath(String fileName) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    print("app directory path ==> $appDocDir");
    return '${appDocDir.path}/$fileName';
  }

  void _handleOnPress(CameraState state) async {
    if (state is VideoRecordingCameraState) {
      if (_recordingDuration <= 1) {
        await Future.delayed(Duration(seconds: 1 - _recordingDuration));
      }
      await state.stopRecording();
      _stopRecordingTimer();
      if (captureRequest?.path != null) {
        filePath = captureRequest!.path!;
        try {
          String thumbnailPath = await generateThumbnail(filePath);
          vid_id = 1;
          setState(() {
            status++;
          });
          String name = filePath.split('/').last;
          await _databaseService.addfile(
            filePath,
            thumbnailPath,
            name,
            name,
            9,
            16,
          );
          // AddVideo("", script_id, "");

          print("File is saved successfully to the database");
        } catch (e) {
          print("Error storing file == > ${e.toString()}");
        }
        int videoID = await _databaseService.getVidId(filePath);
        print("vidID ==>  $videoID");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UseScreen(
                    filePath: filePath,
                    videoID: videoID.toString(),
                  )),
        );

        setState(() {
          isrecording = false;
        });
      }
    } else if (state is VideoCameraState) {
      captureRequest = await state.startRecording();
      _startRecordingTimer();
    }
  }

  void _switchCamera() {
    setState(() {
      _currentSensorPosition = (_currentSensorPosition == SensorPosition.back)
          ? SensorPosition.front
          : SensorPosition.back;
    });
  }

  void _changeAspectRatio(CameraAspectRatios aspectRatio) {
    setState(() {
      _aspectRatio = aspectRatio;
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
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 35),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(40),
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
                                          // state is VideoRecordingCameraState
                                          Icons.stop,
                                          // : Icons.circle,
                                          color: AppColor.red_color,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          color: AppColor.container_color,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
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
                                                setState(() {
                                                  isrecording = true;
                                                });
                                              },
                                              child: Icon(
                                                Icons.circle,
                                                color: AppColor.red_color,
                                                size: 50,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          state.switchCameraSensor();
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
              sensor: Sensor.position(_currentSensorPosition),
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
          ),
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
                    color:
                        isrecording ? AppColor.red_color : AppColor.time_color,
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
