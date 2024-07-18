import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_editing_app/Model/filepath.dart';
import 'package:video_editing_app/Model/get_caption_data_model.dart';
import 'package:video_editing_app/UI/UseVideo/useformerge.dart';
import 'package:video_editing_app/UI/UseVideo/usefortrimeview.dart';
import 'package:video_editing_app/UI/Video_Preview/export_scree.dart';
import 'package:video_editing_app/Audio_Pick/AudioPicker.dart';
import 'package:video_editing_app/services/databaseservices.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/widget/button.dart';
import 'package:video_editing_app/widget/common_ratio_widget.dart';
import 'package:video_player/video_player.dart';

import '../../services/databaseMethods.dart';
import '../../util/app_images.dart';
import '../../widget/editing_button.dart';
import '../../widget/video_caption.dart';
import '../components/common.dart';
import '../components/common_back_button.dart';
import '../components/common_save_button.dart';
import '../components/coomon_file_list.dart';

class VideoSavePage extends StatefulWidget {
  final String filePath;
  final String? audiopath;
  final String? videoID;
  final bool isBackExport;

  VideoSavePage({
    Key? key,
    required this.filePath,
    this.audiopath,
    this.videoID,
    required this.isBackExport,
  }) : super(key: key);

  @override
  _VideoSavePageState createState() => _VideoSavePageState();
}

class _VideoSavePageState extends State<VideoSavePage>
    with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService.instance;

  late VideoPlayerController _videoPlayerController;
  final ItemScrollController? _scrollControllerList = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  bool isPlaying = false;
  bool isvisible = false;
  double? aspectRatio;

  Timer? _autoScrollTimer;
  late String _outputPath;
  late String originalratio;

  //late List<String> scriptParts; //new

  late String script;
  late Future<List<FilePath>> _data;
  late String pickedfile;
  late int id;

  int activeCaptionIndex = -1;

  double? fixRatio;

  late int min, max;

  String action = "";

  List<GetCaptionDataModel> _getCations = [];

  @override
  void initState() {
    super.initState();
    getCaptionDatas();
    _outputPath = widget.filePath;
    getminversion();
    getmaxversion();
    getratio();
    _data = _databaseService.getFilesWithHighestVersion();
    _initializeVideoPlayer().then((_) {
      setState(() {
        isPlaying = true;
      });
    });
  }

  void setActiveCaptionIndex(int index) {
    setState(() {
      activeCaptionIndex = index;
    });
  }

  Future<void> getmaxversion() async {
    if (widget.videoID != null) {
      max = await Databasemethods.getmaxversions(widget.videoID!);
    }
    setState(() {});
  }

  Future<void> getminversion() async {
    if (widget.videoID != null) {
      min = await Databasemethods.getminversions(widget.videoID!);
    }
    setState(() {});
  }

  void getCaptionDatas() async {
    if (widget.videoID != null) {
      _getCations = await Databasemethods.getCaptionData(widget.videoID);
    }
    setState(() {});
  }

  void _scrollToActiveCaption() {
    final currentPosition = _videoPlayerController.value.position;
    for (int i = 0; i < _getCations.length; i++) {
      final caption = _getCations[i];
      final start = parseDuration(caption.startFrom);
      final end = parseDuration(caption.endTo);

      if (currentPosition >= start && currentPosition <= end) {
        _scrollControllerList?.scrollTo(
          index: i,
          duration: Duration(milliseconds: 50),
          alignment: 0.5,
        );
        break;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _videoPlayerController.removeListener(() {
      // _updateCaptions();
      _scrollToActiveCaption();
    });
    _videoPlayerController.dispose();
    super.dispose();
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
        print("position ==== > ${_videoPlayerController.value.position}");
        _scrollToActiveCaption();
        final isFinished = _videoPlayerController.value.position >=
            _videoPlayerController.value.duration;
        if (isFinished && _videoPlayerController.value.isInitialized) {
          setState(() {
            isPlaying = false;
          });
          _videoPlayerController.pause();
        }
      });

      setState(() {});
    } catch (e) {
      errorHandler(context);
      print("Error initializing video player: ${e.toString()}");
    }
  }

  bool maxver = true;
  bool minver = false;

  Future<void> forward() async {
    print("Function called");
    try {
      int maxVersion = await _databaseService
          .getHighestVersionByVidId(int.parse(widget.videoID!));
      int currentVersion =
          await _databaseService.getCurrentVersionByPAth(_outputPath);

      if (currentVersion < maxVersion) {
        String newOutputPath = await _databaseService
            .getFilepathForward(_outputPath, increment: 1);
        if (newOutputPath.isNotEmpty) {
          print("New version after increment: $newOutputPath");
          _outputPath = newOutputPath;
          await _videoPlayerController.dispose();
          await _initializeVideoPlayer();
        } else {
          print("Failed to get new version path.");
        }
        setState(() {
          minver = false;
          maxver = (currentVersion + 1 == maxVersion);
        });
      } else {
        setState(() {
          maxver = true;
        });
      }
    } catch (e) {
      print("Not Working!!!!");
    }
  }

  Future<void> backward() async {
    print("Function called");
    try {
      int minVersion = await _databaseService
          .getLowestVersionByVidId(int.parse(widget.videoID!));
      int currentVersion =
          await _databaseService.getCurrentVersionByPAth(_outputPath);

      if (currentVersion > minVersion) {
        String newOutputPath = await _databaseService
            .getFilepathBackward(_outputPath, decrement: 1);
        if (newOutputPath.isNotEmpty) {
          print("New version after decrement: $newOutputPath");
          _outputPath = newOutputPath;
          await _videoPlayerController.dispose();
          await _initializeVideoPlayer();
        } else {
          print("Failed to get new version path.");
        }
        setState(() {
          maxver = false;
          minver = (currentVersion - 1 == minVersion);
        });
      } else {
        setState(() {
          minver = true;
        });
        print("Already at the lowest version.");
      }
    } catch (e) {
      print("Not Working!!!!");
    }
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
    fixRatio ??= w / h;
  }

  Future<void> _changeAspectRatio(
    double w,
    double h,
  ) async {
    try {
      setState(() {
        aspectRatio = w / h;
      });
      await _databaseService.changeRatio(_outputPath, w, h);
      await getratio();
    } catch (e) {
      print("Error in _changeAspectRatio: $e");
    }
  }

  void _editScriptPart(int index, String newText) {
    List<String> parts =
        script.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (index < 0 || index >= parts.length) {
      return;
    }
    parts[index] = newText;
    setState(() {
      script = parts.join(' ');
    });
  }

  late String audiopath;

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      audiopath = result.files.single.path!;
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioPicker(
              audiopath: audiopath,
              filepath: _outputPath,
              videoID: widget.videoID,
            ),
          ));
    } else {
      print('Audio file picking canceled');
    }
  }

  Future<void> _audio() async {
    await _pickAudio();
  }

  void _shareVideo() {
    Share.shareFiles([_outputPath], text: 'Check out this video!');
    //Share.share(_outputPath);
  }

  late String pickedFilePath;

  Future<void> _pickVideo() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowCompression: false,
      );

      if (result != null) {
        pickedFilePath = result.files.single.path!;

        navigat();
      }
    } catch (e) {}
  }

  void navigat() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UseScreenmerge(
                  filePath: widget.filePath,
                  pickedfilePath: pickedFilePath,
                  videoID: widget.videoID,
                )));
  }

  // on call back
  void backButton(Widget? widget) {
    if (widget != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => widget,
          ));
    } else {
      Navigator.pop(context);
    }
  }

  bool _keyboardVisible = false;
  String videoAction = "";

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    double height = MediaQuery.of(context).size.height;
    print(
        "_videoPlayerController == >  ${_videoPlayerController.value.position}");

    print(
        "videoplayer aspect ration == > ${_videoPlayerController.value.aspectRatio} ");
    print("Original aspect ratio ==> $aspectRatio");
    if (_videoPlayerController.value.isPlaying) {
      videoAction = "isPlaying";
      isPlaying = true;
      action = "";
    }

    return PopScope(
      canPop: !widget.isBackExport,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if (_keyboardVisible) {
          FocusScope.of(context).requestFocus(new FocusNode());
        } else {
          if (widget.isBackExport && widget.videoID != null) {
            backButton(ExportScreen(
              filePath: _outputPath,
              videoID: widget.videoID!,
            ));
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.bg_color,
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
              if (_getCations.isNotEmpty)
                Visibility(
                  visible: true,
                  child: Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: getCpationList(!isPlaying &&
                          (action == "isStyle" ||
                              action == "isHighilight" ||
                              action == "isMerge" ||
                              action == "isSplit"))),
                ),
              if (!isPlaying)
                Positioned(
                    top: 40,
                    left: 20,
                    child: CommonBackButton(
                      onTap: () {
                        if (_keyboardVisible) {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        } else {
                          if (widget.isBackExport && widget.videoID != null) {
                            backButton(ExportScreen(
                              filePath: _outputPath,
                              videoID: widget.videoID!,
                            ));
                          }
                        }
                      },
                    )),
              if (!isPlaying && !_keyboardVisible)
                Positioned(right: 20, top: 100, child: getEditingMenu()),
              if (!isPlaying && !_keyboardVisible)
                Positioned(
                    top: 40,
                    left: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color.fromARGB(169, 67, 67, 67),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13.0, vertical: 13.0),
                        child: Row(
                          children: [
                            EditingButton(
                              onTap: backward,
                              imagePath: "assets/backward.png",
                              imageColor: minver
                                  ? const Color.fromARGB(255, 65, 65, 65)
                                  : Colors.white,
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            EditingButton(
                              onTap: forward,
                              imagePath: "assets/forward.png",
                              imageColor: maxver
                                  ? const Color.fromARGB(255, 65, 65, 65)
                                  : Colors.white,
                            ),
                          ],
                        ),
                      ),
                    )),
              if (!isPlaying && !_keyboardVisible)
                Positioned(
                    top: 40,
                    right: 20,
                    child: CommonSaveButton(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExportScreen(
                                filePath: _outputPath,
                                videoID: widget.videoID!,
                              ),
                            ));
                      },
                    )),
              if (!isPlaying && !_keyboardVisible && action == "isHighilight")
                Positioned(
                    bottom: 100,
                    child: Padding(
                      padding: EdgeInsets.only(left: 40),
                      child: Row(
                        children: [
                          CommonBackButton(
                            onTap: () {
                              action = "isStyle";
                              setState(() {});
                            },
                          ),
                          getHighlighgtButtons(
                              text: "",
                              color: Color(int.parse(
                                  _getCations[activeCaptionIndex]
                                      .textColor
                                      .toString())),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor: Color(int.parse(
                                              _getCations[activeCaptionIndex]
                                                  .textColor
                                                  .toString())),
                                          onColorChanged: (Color color) {
                                            if (activeCaptionIndex != -1) {
                                              String colorString =
                                                  '0x${color.value.toRadixString(16)}';
                                              _getCations[activeCaptionIndex]
                                                  .textColor = colorString;
                                              _databaseService.updatecolor(
                                                  _getCations[
                                                          activeCaptionIndex]
                                                      .id
                                                      .toString(),
                                                  colorString.toString());
                                              setState(() {});
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                                // showModalBottomSheet(
                                //   context: context,
                                //   builder: (context) {
                                //     return SingleChildScrollView(
                                //       child: ColorPicker(
                                //         pickerColor: Color(int.parse(
                                //             _getCations[activeCaptionIndex]
                                //                 .textColor)),
                                //         onColorChanged: (Color color) {
                                //           if (activeCaptionIndex != -1) {
                                //             _getCations[activeCaptionIndex]
                                //                 .textColor = color.value;

                                //             _databaseService.updatecolor(
                                //                 _getCations[activeCaptionIndex]
                                //                     .id
                                //                     .toString(),
                                //                 color.value.toString());
                                //             setState(() {});
                                //           }
                                //         },
                                //       ),
                                //     );
                                //   },
                                // );
                              }),
                          getHighlighgtButtons(
                              isSelected:
                                  _getCations[activeCaptionIndex].isBold == "1",
                              isBold: true,
                              text: "B",
                              onTap: () {
                                String value = "0";
                                if (activeCaptionIndex != -1) {
                                  if (_getCations[activeCaptionIndex].isBold ==
                                      "1") {
                                    _getCations[activeCaptionIndex].isBold =
                                        "0";
                                    value = "0";
                                  } else {
                                    _getCations[activeCaptionIndex].isBold =
                                        "1";
                                    value = "1";
                                  }
                                  _databaseService.updatebold(
                                      _getCations[activeCaptionIndex]
                                          .id
                                          .toString(),
                                      value);
                                }
                                setState(() {});
                              }),
                          getHighlighgtButtons(
                              isSelected:
                                  _getCations[activeCaptionIndex].isItalic ==
                                      "1",
                              isItalic: true,
                              text: "I",
                              onTap: () {
                                String value = "0";
                                if (activeCaptionIndex != -1) {
                                  if (_getCations[activeCaptionIndex]
                                          .isItalic ==
                                      "1") {
                                    _getCations[activeCaptionIndex].isItalic =
                                        "0";
                                    value = "0";
                                  } else {
                                    _getCations[activeCaptionIndex].isItalic =
                                        "1";
                                    value = "1";
                                  }
                                  _databaseService.updateItalic(
                                      _getCations[activeCaptionIndex]
                                          .id
                                          .toString(),
                                      value);
                                }
                                setState(() {});
                              }),
                          getHighlighgtButtons(
                              isSelected:
                                  _getCations[activeCaptionIndex].isUnderLine ==
                                      "1",
                              isUnderLine: true,
                              text: "U",
                              onTap: () {
                                String value = "0";
                                if (activeCaptionIndex != -1) {
                                  if (_getCations[activeCaptionIndex]
                                          .isUnderLine ==
                                      "1") {
                                    _getCations[activeCaptionIndex]
                                        .isUnderLine = "0";
                                    value = "0";
                                  } else {
                                    _getCations[activeCaptionIndex]
                                        .isUnderLine = "1";
                                    value = "1";
                                  }
                                  _databaseService.updateUnderline(
                                      _getCations[activeCaptionIndex]
                                          .id
                                          .toString(),
                                      value);
                                }
                                setState(() {});
                              })
                        ],
                      ),
                    )),
              if (!isPlaying && !_keyboardVisible && action == "isStyle")
                Positioned(
                  left: 30,
                  bottom: 100,
                  child: EditingButton(
                    onTap: () {
                      action = "isHighilight";
                      setState(() {});
                    },
                    imagePath: "assets/highilight.png",
                    buttonName: "Highlight",
                    imageColor: Colors.white,
                    isBackGroundNeed: true,
                  ),
                ),
              if (!isPlaying && !_keyboardVisible && action == "isStyle")
                Positioned(
                  right: 30,
                  bottom: 100,
                  child: EditingButton(
                    onTap: () {
                      action = "isSplit";
                      setState(() {});
                    },
                    imagePath: "assets/split.png",
                    buttonName: " Split ",
                    imageColor: Colors.white,
                    isBackGroundNeed: true,
                  ),
                ),
              if (!isPlaying && !_keyboardVisible && action == "isSplit")
                Positioned(
                  bottom: 100,
                  child: Padding(
                    padding: EdgeInsets.only(left: 40),
                    child: Row(
                      children: [
                        CommonBackButton(
                          onTap: () {
                            action = "isStyle";
                            setState(() {});
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        EditingButton(
                          onTap: () {
                            getSpite(true);
                            setState(() {});
                          },
                          imagePath: "assets/split.png",
                          buttonName: "Before",
                          imageColor: Colors.white,
                          isBackGroundNeed: true,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        EditingButton(
                          onTap: () {
                            setState(() {
                              getSpite(false);
                            });
                          },
                          imagePath: "assets/split.png",
                          buttonName: "After",
                          imageColor: Colors.white,
                          isBackGroundNeed: true,
                        ),
                      ],
                    ),
                  ),
                ),
              if (!isPlaying && !_keyboardVisible && action == "isStyle")
                Positioned(
                  right: 100,
                  bottom: 100,
                  child: EditingButton(
                    onTap: () {
                      action = "isMerge";
                      setState(() {});
                    },
                    imagePath: "assets/merge.png",
                    buttonName: " Merge ",
                    imageColor: Colors.white,
                    isBackGroundNeed: true,
                  ),
                ),
              if (!isPlaying && !_keyboardVisible && action == "isMerge")
                Positioned(
                  bottom: 100,
                  child: Padding(
                    padding: EdgeInsets.only(left: 40),
                    child: Row(
                      children: [
                        CommonBackButton(
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                            action = "isStyle";
                            setState(() {});
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        EditingButton(
                          onTap: () {
                            getMarge(true);
                            setState(() {});
                          },
                          imagePath: "assets/merge.png",
                          buttonName: "Before",
                          imageColor: Colors.white,
                          isBackGroundNeed: true,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        EditingButton(
                          onTap: () {
                            getMarge(false);
                            setState(() {});
                          },
                          imagePath: "assets/merge.png",
                          buttonName: "After",
                          imageColor: Colors.white,
                          isBackGroundNeed: true,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void getMarge(bool isMergeBefore) {
    String mergingCombineIds = isMergeBefore
        ? _getCations[activeCaptionIndex - 1].combineIds
        : _getCations[activeCaptionIndex + 1].combineIds;
    _databaseService.getCaptionMerga(
        combineIds: _getCations[activeCaptionIndex].combineIds,
        mergingCombineIds: mergingCombineIds,
        isMergeBefore: isMergeBefore);
    if (_getCations[activeCaptionIndex].combineIds != mergingCombineIds) {
      String finalIds = "";
      if (isMergeBefore) {
        finalIds =
            "$mergingCombineIds,${_getCations[activeCaptionIndex].combineIds}";
      } else {
        finalIds =
            "${_getCations[activeCaptionIndex].combineIds},$mergingCombineIds";
      }
      List<int> idsIntList =
          finalIds.split(",").map((id) => int.parse(id.trim())).toList();
      getUpdateData(idsIntList);
    }
  }

  void getSpite(bool isSplitBefore) {
    print(
        "activeCaptionIndex ==== > ${_getCations[activeCaptionIndex].combineIds} ==== > ${_getCations[activeCaptionIndex].id}");

    _databaseService.getSplitTextUpdate(
        combineIds: _getCations[activeCaptionIndex].combineIds,
        mainIndexId: _getCations[activeCaptionIndex].id.toString(),
        isSplitBefore: isSplitBefore);
    List<int> idsIntList = _getCations[activeCaptionIndex]
        .combineIds
        .toString()
        .split(",")
        .map((id) => int.parse(id.trim()))
        .toList();
    List<int> splittingIds = [];
    List<int> staysIds = [];
    for (var id in idsIntList) {
      if (isSplitBefore) {
        (id < _getCations[activeCaptionIndex].id ? splittingIds : staysIds)
            .add(id);
      } else {
        (id > _getCations[activeCaptionIndex].id ? splittingIds : staysIds)
            .add(id);
      }
    }
    getUpdateData(splittingIds);
    getUpdateData(staysIds);
  }

  void getUpdateData(List<int> ids) {
    String idsString = ids.join(',');
    for (var id in ids) {
      for (var data in _getCations) {
        if (id == data.id) {
          data.combineIds = idsString;
        }
      }
    }
    print("idsString ==== > ${idsString}");
    setState(() {});
  }

  Widget getHighlighgtButtons(
      {Function()? onTap,
      bool isItalic = false,
      bool isUnderLine = false,
      bool isBold = false,
      required String text,
      Color? color,
      bool isSelected = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          height: 40,
          width: 40,
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: color != null
                  ? color
                  : isSelected
                      ? Colors.white
                      : Color.fromARGB(101, 158, 158, 158)),
          child: isItalic
              ? Image.asset(
                  "assets/I.png",
                  color: isSelected ? Colors.black : Colors.white,
                  height: 23,
                  width: 23,
                  scale: 25,
                  fit: BoxFit.scaleDown,
                )
              : Center(
                  child: Text(
                    text,
                    style: TextStyle(
                        fontSize: 23,
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: isBold ? FontWeight.bold : null,
                        decorationThickness: 3,
                        decorationColor:
                            isSelected ? Colors.black : Colors.white,
                        decoration: isUnderLine
                            ? TextDecoration.underline
                            : TextDecoration.none),
                  ),
                ),
        ),
      ),
    );
  }

  // Widget getCpationList(bool isPlaying) {
  //   return SizedBox(
  //     height: 45,
  //     //  isPlaying ? 45 : 0,
  //     child: ScrollablePositionedList.builder(
  //       shrinkWrap: true,
  //       initialAlignment: BorderSide.strokeAlignCenter,
  //       itemScrollController: _scrollControllerList,
  //       itemPositionsListener: _positionsListener,
  //       itemCount: _getCations.length,
  //       scrollDirection: Axis.horizontal,
  //       itemBuilder: (context, index) {
  //         GetCaptionDataModel caption = _getCations[index];
  //         final isActive = _videoPlayerController.value.position >=
  //                 parseDuration(caption.startFrom) &&
  //             _videoPlayerController.value.position <=
  //                 parseDuration(caption.endTo);

  //         if (isActive) {
  //           activeCaptionIndex = index;
  //           print("Active index ==> $activeCaptionIndex");
  //         }
  //         return Container(
  //           margin: index == 0
  //               ? EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.4)
  //               : index == _getCations.length - 1
  //                   ? EdgeInsets.only(
  //                       right: MediaQuery.of(context).size.width * 0.4)
  //                   : null,
  //           decoration: isActive
  //               ? BoxDecoration(
  //                   color: const Color.fromARGB(255, 58, 55, 55),
  //                   borderRadius: BorderRadius.circular(5),
  //                   border: Border.all(color: Colors.blue, width: 2.0),
  //                 )
  //               : null,
  //           child: InkWell(
  //             onTap: !isActive
  //                 ? () {
  //                     print("caption.startFrom === > ${caption.startFrom}");
  //                     if (action != "") {
  //                       action = "isStyle";
  //                     }
  //                     _videoPlayerController
  //                         .seekTo(parseDuration(caption.startFrom) +
  //                             Duration(milliseconds: 5))
  //                         .then((_) {
  //                       setState(() {}); // Ensures the UI updates after seeking
  //                     });
  //                   }
  //                 : null,
  //             child: EditableWord(
  //               isActive: isActive,
  //               text: caption.keyword,
  //               onSubmitted: (newText) {
  //                 _databaseService.getUpdateCaptionValueById(
  //                     mainIndexId: caption.id.toString(),
  //                     combineIds: caption.combineIds,
  //                     text: newText);
  //                 setState(() {
  //                   _getCations[index].keyword = newText;
  //                 });
  //               },
  //             ),
  //             onDoubleTap: () {},
  //           ),
  //         );
  //       },
  //     ),

  //   );
  // }
  Widget getCpationList(bool isPlaying) {
    return SizedBox(
      height: 35,
      child: ScrollablePositionedList.builder(
        shrinkWrap: true,
        initialAlignment: BorderSide.strokeAlignCenter,
        itemScrollController: _scrollControllerList,
        itemPositionsListener: _positionsListener,
        itemCount:
            _getCations.length + 1, // Add 1 to the item count for the icon
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index == _getCations.length) {
            // If it's the last index, add the icon
            return Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(169, 67, 67, 67),
              ),
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.4,
              ),
              child: IconButton(
                onPressed: _addNewCaption,
                icon: Icon(Icons.add),
                iconSize: 20,
              ),
            );
          }
          GetCaptionDataModel caption = _getCations[index];
          final isActive = _videoPlayerController.value.position >=
                  parseDuration(caption.startFrom) &&
              _videoPlayerController.value.position <=
                  parseDuration(caption.endTo);
          if (isActive) {
            activeCaptionIndex = index;
            print("Active index ==> $activeCaptionIndex");
          }

          return Container(
            margin: index == 0
                ? EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.4)
                : EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.014),
            padding: EdgeInsets.symmetric(horizontal: 7),
            decoration: isActive
                ? BoxDecoration(
                    color: const Color.fromARGB(255, 58, 55, 55),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.blue, width: 2.0),
                  )
                : BoxDecoration(
                    color: const Color.fromARGB(255, 58, 55, 55),
                    borderRadius: BorderRadius.circular(5),
                  ),
            child: InkWell(
              onTap: !isActive
                  ? () {
                      print("caption.startFrom === > ${caption.startFrom}");
                      if (action != "") {
                        action = "isStyle";
                      }
                      _videoPlayerController
                          .seekTo(parseDuration(caption.startFrom) +
                              Duration(milliseconds: 5))
                          .then((_) {
                        setState(() {}); // Ensures the UI updates after seeking
                      });
                    }
                  : null,
              child: EditableWord(
                isActive: isActive,
                text: caption.keyword,
                onSubmitted: (newText) {
                  _databaseService.getUpdateCaptionValueById(
                      mainIndexId: caption.id.toString(),
                      combineIds: caption.combineIds,
                      text: newText);
                  setState(() {
                    _getCations[index].keyword = newText;
                  });
                },
              ),
              onDoubleTap: () {},
            ),
          );
        },
      ),
    );
  }

  Duration parseDuration(String duration) {
    List<String> parts = duration.split(':');
    List<String> secondsParts = parts[2].split('.');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(secondsParts[0]);
    int milliseconds = int.parse(secondsParts[1]);
    return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds);
  }

// Helper function to format the duration back to a string in the format "HH:mm:ss.SSS"
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String threeDigits(int n) => n.toString().padLeft(3, "0");
    String hours = twoDigits(duration.inHours.remainder(24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds = threeDigits(duration.inMilliseconds.remainder(1000));
    return "$hours:$minutes:$seconds.$milliseconds";
  }

  void _addNewCaption() async {
    if (_getCations.isNotEmpty) {
      String starttime = _getCations.last.endTo;

      String endtime =
          formatDuration(parseDuration(starttime) + Duration(milliseconds: 500))
              .toString();
      int id = await _databaseService.addLastCaptions(
          keywords: "Hello",
          startTime: starttime,
          text: "Hello",
          toTime: endtime,
          videoId: widget.videoID!);

      final defaultCaption = GetCaptionDataModel(
        id: id,
        vidId: widget.videoID,
        startFrom: starttime,
        endTo: endtime,
        keyword: 'Hello',
        text: 'Hello',
        textColor: "0xFFFFFFFF",
        backgroundColor: "0xFFFF0000",
        isBold: "0",
        isUnderLine: "0",
        isItalic: "0",
        combineIds: '$id',
      );

      // Update the list and refresh the UI
      setState(() {
        _getCations.add(defaultCaption);
      });
    }
  }

  Widget getEditingMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(169, 67, 67, 67),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 8),
        child: Column(
          children: [
            EditingButton(
              onTap: bootomsheet,
              imagePath: "assets/shapes.png",
              buttonName: "Format",
            ),
            divider(),
            EditingButton(
              onTap: _audio,
              imagePath: "assets/music.png",
              buttonName: "Audio",
            ),
            divider(),
            EditingButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UseScreentrime(
                            filePath: _outputPath,
                            videoID: widget.videoID,
                          )),
                );
              },
              imagePath: "assets/trim.png",
              buttonName: "Trim",
            ),
            divider(),
            EditingButton(
              onTap: options,
              imagePath: "assets/merge.png",
              buttonName: "Merge",
            ),
            if (_getCations.isNotEmpty) divider(),
            if (_getCations.isNotEmpty)
              EditingButton(
                onTap: () {
                  setState(() {
                    if (action != "") {
                      action = "";
                    } else {
                      action = "isStyle";
                    }
                  });
                },
                imagePath: "assets/style.png",
                buttonName: "style",
              ),
          ],
        ),
      ),
    );
  }

  Widget divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      color: Color.fromARGB(159, 212, 210, 210),
      width: 35,
      height: 2,
    );
  }

  bool _isquare = false;
  bool _isoriginal = true;
  bool _islanscap = false;
  bool _isportrait = false;

  Future bootomsheet() {
    double height = fixRatio == 1
        ? 60
        : fixRatio! < 1
            ? 70
            : 35;
    double? width = fixRatio == 1
        ? 60
        : fixRatio! < 1
            ? 35
            : null;

    return showModalBottomSheet(
      barrierColor: Color.fromARGB(0, 0, 0, 0),
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(212, 0, 0, 0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            ),
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 30),
                    child: Row(
                      children: [
                        Text(
                          "Aspect Ratio",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CommonRatioWidget(
                          height: height,
                          width: width,
                          title: "Original",
                          borderColor: _isoriginal
                              ? Colors.blueAccent.shade700
                              : Colors.transparent,
                          onTap: () {
                            if (fixRatio == 1) {
                              _changeAspectRatio(1, 1);
                            } else if (fixRatio! < 1) {
                              _changeAspectRatio(9, 16);
                            } else if (fixRatio! > 1) {
                              _changeAspectRatio(4, 3);
                            }
                            setState(() {
                              _isquare = false;
                              _isoriginal = true;
                              _isportrait = false;
                              _islanscap = false;
                            });
                          },
                        ),
                        CommonRatioWidget(
                          width: 35,
                          height: 70,
                          title: "Portrait",
                          borderColor: _isportrait
                              ? Colors.blueAccent.shade700
                              : Colors.transparent,
                          onTap: () {
                            _changeAspectRatio(9, 16);
                            setState(() {
                              _isquare = false;
                              _isoriginal = false;
                              _isportrait = true;
                              _islanscap = false;
                            });
                          },
                        ),
                        CommonRatioWidget(
                          height: 35,
                          title: "Landscap",
                          borderColor: _islanscap
                              ? Colors.blueAccent.shade700
                              : Colors.transparent,
                          onTap: () {
                            _changeAspectRatio(4, 3);
                            setState(() {
                              _isquare = false;
                              _isoriginal = false;
                              _isportrait = false;
                              _islanscap = true;
                            });
                          },
                        ),
                        CommonRatioWidget(
                          height: 60,
                          width: 60,
                          title: "Square",
                          borderColor: _isquare
                              ? Colors.blueAccent.shade700
                              : Colors.transparent,
                          onTap: () {
                            _changeAspectRatio(1, 1);
                            setState(() {
                              _isquare = true;
                              _isoriginal = false;
                              _isportrait = false;
                              _islanscap = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future options() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(212, 0, 0, 0),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, bottom: 20, right: 10),
                    child: Text(
                      "Select From",
                      style: TextStyle(
                          color: AppColor.white_color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      CommonButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _pickVideo();
                        },
                        text: "Gallery",
                        bgcolor: AppColor.elevated_bg_color,
                        image: AppImages.gallary,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      CommonButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _Projects();
                        },
                        text: "Projects",
                        bgcolor: AppColor.elevated_bg_color,
                        image: AppImages.folder,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _Projects() async {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(212, 0, 0, 0),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: Text(
                      "Select from projects",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.only(top: 70),
                child: CoomonFileList(
                  data: _data,
                  isScroll: true,
                  onTap: (file) {
                    pickedfile = file.path;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UseScreenmerge(
                            filePath: _outputPath,
                            pickedfilePath: pickedfile,
                            videoID: widget.videoID,
                          ),
                        ));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EditableWord extends StatefulWidget {
  final String text;
  final ValueChanged<String> onSubmitted;
  final bool isActive;

  EditableWord(
      {required this.text, required this.onSubmitted, required this.isActive});

  @override
  _EditableWordState createState() => _EditableWordState();
}

class _EditableWordState extends State<EditableWord> {
  late TextEditingController _controller;
  late double _width;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _width = _calculateTextWidth(widget.text) + 10; // Add padding
    _controller.addListener(_updateWidth);
  }

  double _calculateTextWidth(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: 16)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }

  void _updateWidth() {
    setState(() {
      _width = _calculateTextWidth(_controller.text) + 16; // Add padding
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateWidth);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 58, 55, 55),
          borderRadius: BorderRadius.circular(5)),
      alignment: Alignment.center,
      child: widget.isActive
          ? TextField(
              controller: _controller,
              enableInteractiveSelection: false,
              style: TextStyle(
                  color: AppColor.white_color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              onChanged: (text) {
                print("onChanged === > $text");
                widget.onSubmitted(text);
              },
              onSubmitted: (text) {
                print("onSubmitted === > $text");
                widget.onSubmitted(text);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.all(1),
              ),
            )
          : Text(
              widget.text,
              style: TextStyle(
                  color: AppColor.white_color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
    );
  }
}
