// import 'dart:io';
// import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_video/return_code.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_editing_app/Model/filepath.dart';
// import 'package:video_editing_app/UI/UseVideo/usescreen.dart';
// import 'package:video_editing_app/UI/VideoMerge/projectvideos.dart';
// import 'package:video_editing_app/UI/components/common.dart';
// import 'package:video_editing_app/services/databaseservices.dart';
// import 'package:video_editing_app/util/app_color.dart';
// import 'package:video_editing_app/util/app_images.dart';
// import 'package:video_player/video_player.dart';

// import '../../Model/get_caption_data_model.dart';
// import '../../widget/button.dart';
// import '../../widget/video_caption.dart';

// class VideoMerge extends StatefulWidget {
//   final String filepath;
//   final String pickedfilepath;
//   final String? videoID;
//   const VideoMerge({
//     super.key,
//     required this.filepath,
//     required this.pickedfilepath,
//     this.videoID,
//   });

//   @override
//   State<VideoMerge> createState() => _VideoMergeState();
// }

// class _VideoMergeState extends State<VideoMerge> {
//   DatabaseService _databaseService = DatabaseService.instance;
//   late String pickedFilePath;
//   late String outputpath;
//   late VideoPlayerController _pickedvideoPlayerController;

//   late Future<List<FilePath>> _data;
//   List<GetCaptionDataModel> _getCations = [];
//   bool isloading = false;
//   bool isPlaying = false;

//   double? aspectRatio;

//   @override
//   void initState() {
//     super.initState();
//     pickedFilePath = widget.pickedfilepath;
//     _data = _databaseService.getfile();
//     _initializeVideoPlayerpick().then((_) {
//       setState(() {
//         isPlaying = true;
//       });
//     });
//     _getVidId();
//   }

//   late int vidId;

//   Future<void> _getVidId() async {
//     String path = pickedFilePath;
//     vidId = await _databaseService.getVidId(path);
//     setState(() {});
//   }

//   late double h, w;

//   Future<void> getratio() async {
//     w = await _databaseService.getwidth(pickedFilePath);
//     print("width === > $w");
//     h = await _databaseService.getheight(pickedFilePath);
//     print("height === > $h");
//     aspectRatio = w / h;
//   }

//   @override
//   void dispose() {
//     _pickedvideoPlayerController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickVideo() async {
//     try {
//       final FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.video,
//         allowCompression: false,
//       );

//       if (result != null) {
//         pickedFilePath = result.files.single.path!;
//         print("yash ==> $pickedFilePath");
//         // _initializeVideoPlayerpick(pickedFilePath);
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => VideoMerge(
//                 videoID: widget.videoID,
//                 filepath: widget.filepath,
//                 pickedfilepath: pickedFilePath,
//               ),
//             ));
//       }
//     } catch (e) {}
//   }

//   Future<String> _getOutputDirectoryPath() async {
//     final directory = await getDownloadsDirectory();
//     print("directory ========>  $directory");
//     String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
//     return '${directory?.path}/output_$timestamp.mp4';
//   }

//   Future<void> _mergeafter(String vid1, String vid2, bool isafter) async {
//     // outputpath = await _getOutputDirectoryPath();
//     String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
//     outputpath = "/storage/emulated/0/Download/output_$timestamp.mp4";
//     print("Output path ==>  $outputpath");

//     // String command =
//     //     //'-i $vid1 -i $vid2 -filter_complex concat=n=2:v=1:a=1 -y $outputpath';
//     //     '-i $vid1 -i $vid2 -filter_complex "[0:v] [0:a] [1:v] [1:a] concat=n=2:v=1:a=1 [v] [a]" -map "[v]" -map "[a]" -c:v libx264 -c:a aac -b:a 128k -y $outputpath';

//     // String command =
//     //     '-i $vid1 -i $vid2 -filter_complex "[0:v] [0:a] [1:v] [1:a] concat=n=2:v=1:a=1 [v] [a]" -map "[v]" -map "[a]" -c:v h264 -c:a aac -b:a 128k -y $outputpath';

//     // final command =
//     //     "-i $vid1 -i $vid2 -i $vid3 -filter_complex \"[0:v]scale=1080:1920,fps=30,format=yuv420p[v0];[1:v]scale=1080:1920,fps=30,format=yuv420p[v1];[2:v]scale=1080:1920,fps=30,format=yuv420p[v2];[v0][0:a][v1][1:a][v2][2:a]concat=n=3:v=1:a=1[outv][outa]\" -map \"[outv]\" -map \"[outa]\" -c:v mpeg4 -c:a aac -b:a 128k -y $outputpath";

//     // print("Merging command: $command");

//     // final command =
//     //     "-i $vid1 -i $vid2 -filter_complex \"[0:v]scale=1080:1920,fps=30,format=yuv420p[v0];[1:v]scale=1080:1920,fps=30,format=yuv420p[v1];[v0][0:a][v1][1:a]concat=n=2:v=1:a=1[outv][outa]\" -map \"[outv]\" -map \"[outa]\" -c:v mpeg4 -c:a aac -b:a 128k -y $outputpath";

//     // final command = """
//     // -i $vid1 -i $vid2 -filter_complex
//     // "[0:v]scale='if(gt(a,3840/2160),3840,-2)':'if(gt(a,3840/2160),-2,2160)',pad=3840:2160:(3840-iw)/2:(2160-ih)/2,format=yuv420p[v0];
//     //  [1:v]scale='if(gt(a,3840/2160),3840,-2)':'if(gt(a,3840/2160),-2,2160)',pad=3840:2160:(3840-iw)/2:(2160-ih)/2,format=yuv420p[v1];
//     //  [v0][0:a][v1][1:a]concat=n=2:v=1:a=1[outv][outa]"
//     // -map "[outv]" -map "[outa]" -c:v mpeg4 -b:v 8M -c:a aac -b:a 256k -y $outputpath
//     // """;

//     //  final command = """
//     //   -loglevel verbose -err_detect explode -i $vid1 -i $vid2 -filter_complex
//     //   "[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[outv][outa]"
//     //   -map "[outv]" -map "[outa]" -c:v mpeg4 -b:v 8M -c:a aac -b:a 256k -y $outputpath
//     //   """;

//     // String command =
//     //     "-i $vid1 -i $vid2 -filter_complex \"[0:v]scale=1080:1920,fps=30,format=yuv420p[v0];"
//     //     "[1:v]scale=1080:1920,fps=30,format=yuv420p[v1];"
//     //     "[v0][0:a][v1][1:a]concat=n=2:v=1:a=1[outv][outa]\" "
//     //     "-map \"[outv]\" -map \"[outa]\" -c:v mpeg4 -b:v 4M -c:a aac -b:a 128k -y $outputpath";
//     String command;

//     if (isafter) {
//       command = "-i $vid1 -i $vid2 -filter_complex \""
//           "[0:v]scale='if(gt(a,1080/1920),1080,-2)':'if(gt(a,1080/1920),-2,1920)',pad=1080:1920:(1080-iw)/2:(1920-ih)/2,fps=12,format=yuv420p[v0];"
//           "[1:v]scale='if(gt(a,1080/1920),1080,-2)':'if(gt(a,1080/1920),-2,1920)',pad=1080:1920:(1080-iw)/2:(1920-ih)/2,fps=12,format=yuv420p[v1];"
//           "[v0][0:a][v1][1:a]concat=n=2:v=1:a=1[outv][outa]\" "
//           "-map \"[outv]\" -map \"[outa]\" -c:v mpeg4 -b:v 4M -c:a aac -b:a 128k -y $outputpath";

//       print("Merging command: $command");
//     } else {
//       command = "-i $vid2 -i $vid1 -filter_complex \""
//           "[0:v]scale='if(gt(a,1080/1920),1080,-2)':'if(gt(a,1080/1920),-2,1920)',pad=1080:1920:(1080-iw)/2:(1920-ih)/2,fps=12,format=yuv420p[v0];"
//           "[1:v]scale='if(gt(a,1080/1920),1080,-2)':'if(gt(a,1080/1920),-2,1920)',pad=1080:1920:(1080-iw)/2:(1920-ih)/2,fps=12,format=yuv420p[v1];"
//           "[v0][0:a][v1][1:a]concat=n=2:v=1:a=1[outv][outa]\" "
//           "-map \"[outv]\" -map \"[outa]\" -c:v mpeg4 -b:v 4M -c:a aac -b:a 128k -y $outputpath";
//     }

//     FFmpegKit.execute(command).then((session) async {
//       final returnCode = await session.getReturnCode();
//       final logs = await session.getAllLogs();
//       logs.forEach((log) {
//         print("FFmpeg log: ${log.getMessage()}");
//       });

//       if (ReturnCode.isSuccess(returnCode)) {
//         print("Log 1--------------------------------------> SUCCESS");
//         String thumbnailPath = await generateThumbnail(outputpath);
//         //_databaseService.addfile(outputpath, thumbnailPath,);
//         _databaseService.editFile(
//             int.parse(widget.videoID!), outputpath, thumbnailPath);
//         setState(() {
//           isloading = false;
//         });
//         Navigator.of(context)
//           ..pop()
//           ..pushReplacement(MaterialPageRoute(
//             builder: (context) => UseScreen(
//               filePath: outputpath,
//               videoID: widget.videoID,
//             ),
//           ));
//       } else if (ReturnCode.isCancel(returnCode)) {
//         print("Log 2--------------------------------------> CANCEL");
//       } else {
//         print("Log 3--------------------------------------> ERROR");
//         print("${returnCode}");
//       }
//     });
//   }

//   Future<void> _initializeVideoPlayerpick() async {
//     print("Initializing video player with file path: ${pickedFilePath}");
//     if (!File(pickedFilePath).existsSync()) {
//       print("File does not exist at path: ${pickedFilePath}");
//       return;
//     }
//     try {
//       _pickedvideoPlayerController =
//           VideoPlayerController.file(File(pickedFilePath));
//       await _pickedvideoPlayerController.initialize();
//       await _pickedvideoPlayerController.setLooping(false);
//       await _pickedvideoPlayerController.play();

//       _pickedvideoPlayerController.addListener(() {
//         print("position ==== > ${_pickedvideoPlayerController.value.position}");
//         final isFinished = _pickedvideoPlayerController.value.position >=
//             _pickedvideoPlayerController.value.duration;
//         if (isFinished && _pickedvideoPlayerController.value.isInitialized) {
//           setState(() {
//             isPlaying = false;
//           });
//           _pickedvideoPlayerController.pause();
//         }
//       });

//       setState(() {
//       });
//     } catch (e) {
//       print("Error initializing video player: ${e.toString()}");
//     }
//   }

//   Future Projects() {
//     return showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Color.fromARGB(255, 23, 23, 23),
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(25), topRight: Radius.circular(25)),
//           ),
//           child: Stack(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     Text(
//                       "Select frome projects",
//                       style:
//                           TextStyle(color: AppColor.white_color, fontSize: 22),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: 40),
//                 child: _filePathList(),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _filePathList() {
//     return FutureBuilder<List<FilePath>>(
//       future: _data,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//               child:
//                   CircularProgressIndicator(color: AppColor.home_plus_color));
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(child: Text('No files found.'));
//         } else {
//           return GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2, // Number of items per row
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//               childAspectRatio: 0.75, // Adjusted aspect ratio to fit text
//             ),
//             itemCount: snapshot.data?.length ?? 0,
//             itemBuilder: (context, index) {
//               FilePath file = snapshot.data![index];
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             //border: isMultiSelect ? Border.all() : null,
//                           ),
//                           child: InkWell(
//                             splashFactory: NoSplash.splashFactory,
//                             highlightColor: Colors.transparent,
//                             // onLongPress: () {
//                             //   _showDeleteMenu(context, file);
//                             // /storage/emulated/0/Download/output_2024-06-18T12-39-35.717556.mp4
//                             //   setState(() {
//                             //     isMultiSelect = true;
//                             //   });
//                             // },
//                             onTap: () {
//                               pickedFilePath = file.path;
//                               print("yash2 ===> $pickedFilePath");
//                               _initializeVideoPlayerpick();
//                               Navigator.pop(context);
//                             },
//                             child: Image.file(
//                               File(file.thumbnail),
//                               fit: BoxFit.cover,
//                               width: double.infinity,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(4.0),
//                       child: Text(
//                         file.path.split('/').last,
//                         style: TextStyle(color: AppColor.white_color),
//                         textAlign: TextAlign.center,
//                         overflow:
//                             TextOverflow.ellipsis, // Handle long file names
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }

//   void _togglePlayPause() {
//     final isFinished = _pickedvideoPlayerController.value.position ==
//         _pickedvideoPlayerController.value.duration;
//     setState(() {
//       if (_pickedvideoPlayerController.value.isPlaying) {
//         _pickedvideoPlayerController.pause();
//         isPlaying = false;
//       } else {
//         if (_pickedvideoPlayerController.value.position >=
//             _pickedvideoPlayerController.value.duration) {
//           _pickedvideoPlayerController.seekTo(Duration.zero);
//           isPlaying = true;
//         }
//         _pickedvideoPlayerController.play();
//         isPlaying = true;
//       }
//       if (isFinished == true) {
//         isPlaying = false;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: SafeArea(
//         child: isloading
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Lottie.asset(
//                       AppImages.splace,
//                     ),
//                     Text(
//                       "Merging Video Please wait",
//                       style:
//                           TextStyle(color: AppColor.white_color, fontSize: 24),
//                     )
//                   ],
//                 ),
//               )
//             : Stack(
//                 children: [
//                   VideoCaption(
//                     onTapToggle: _togglePlayPause,
//                     aspectRatio: aspectRatio,
//                     getCations: _getCations,
//                     height: height,
//                     isPlaying: isPlaying,
//                     videoPlayerController: _pickedvideoPlayerController,
//                   ),
//                   Positioned(
//                       bottom: 20,
//                       left: 1,
//                       right: 1,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           children: [
//                             CommonButton(
//                               bgcolor: AppColor.elevated_bg_color,
//                               text: "Before",
//                               image: AppImages.edit,
//                               onPressed: () {
//                                 setState(() {
//                                   isloading = true;
//                                   _pickedvideoPlayerController.pause();
//                                 });
//                                 _mergeafter(widget.filepath,
//                                     widget.pickedfilepath, false);
//                               },
//                             ),
//                             SizedBox(
//                               width: 20,
//                             ),
//                             CommonButton(
//                               bgcolor: AppColor.elevated_bg_color,
//                               text: "After",
//                               image: AppImages.edit,
//                               onPressed: () {
//                                 setState(() {
//                                   isloading = true;
//                                   _pickedvideoPlayerController.pause();
//                                 });
//                                 _mergeafter(widget.filepath,
//                                     widget.pickedfilepath, true);
//                               },
//                             ),
//                           ],
//                         ),
//                       )),
//                   Positioned(
//                     top: 50,
//                     left: 1,
//                     right: 1,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 15),
//                       child: Row(
//                         children: [
//                           CommonButton(
//                             bgcolor: AppColor.elevated_bg_color,
//                             text: "Gallary",
//                             image: AppImages.gallary,
//                             onPressed: () {
//                               _pickVideo();
//                             },
//                           ),
//                           SizedBox(
//                             width: 10,
//                           ),
//                           CommonButton(
//                             bgcolor: AppColor.elevated_bg_color,
//                             text: "Videos",
//                             image: AppImages.folder,
//                             onPressed: () {
//                               Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => ProjectVideos(
//                                       filepath: widget.filepath,
//                                     ),
//                                   ));

//                               // Navigator.of(context)
//                               //   ..pop()
//                               //   ..pop()
//                               //   ..pushReplacement(MaterialPageRoute(
//                               //     builder: (context) => ProjectVideos(
//                               //       filepath: widget.filepath,
//                               //     ),
//                               //   ));
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//       ),
//     );
//   }
// }

// new!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

import 'dart:io';
import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_video/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editing_app/Model/filepath.dart';
import 'package:video_editing_app/UI/UseVideo/usescreen.dart';
import 'package:video_editing_app/UI/VideoMerge/projectvideos.dart';
import 'package:video_editing_app/UI/components/common.dart';
import 'package:video_editing_app/services/databaseservices.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/util/app_images.dart';
import 'package:video_player/video_player.dart';

import '../../widget/button.dart';

class VideoMerge extends StatefulWidget {
  final String filepath;
  final String pickedfilepath;
  final String? VidId;
  const VideoMerge({
    super.key,
    required this.filepath,
    required this.pickedfilepath, this.VidId,
  });

  @override
  State<VideoMerge> createState() => _VideoMergeState();
}

class _VideoMergeState extends State<VideoMerge> {
  DatabaseService _databaseService = DatabaseService.instance;
  late String pickedFilePath;
  late String outputpath;
  late VideoPlayerController _pickedvideoPlayerController;

  late Future<List<FilePath>> _data;
  bool isloading = false;

  double? aspectRatio;

  @override
  void initState() {
    super.initState();
    pickedFilePath = widget.pickedfilepath;
    _data = _databaseService.getfile();
    _initializeVideoPlayerpick();
  }

  late double h, w;

  Future<void> getratio() async {
    w = await _databaseService.getwidth(pickedFilePath);
    print("width === > $w");
    h = await _databaseService.getheight(pickedFilePath);
    print("height === > $h");
    aspectRatio = w / h;
  }

  @override
  void dispose() {
    _pickedvideoPlayerController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowCompression: false,
      );

      if (result != null) {
        pickedFilePath = result.files.single.path!;
        print("path ==> $pickedFilePath");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VideoMerge(
                filepath: widget.filepath,
                pickedfilepath: pickedFilePath,
                VidId: widget.VidId,
              ),
            ));
      }
    } catch (e) {}
  }

  Future<String> _getOutputDirectoryPath() async {
    final directory = await getApplicationCacheDirectory();
    print("directory ========>  $directory");
    String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return '${directory?.path}/output_$timestamp.mp4';
  }

  Future<void> _mergeafter(String vid1, String vid2, bool isafter) async {
    outputpath = await _getOutputDirectoryPath();
    // String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    // outputpath = "/storage/emulated/0/Download/output_$timestamp.mp4";
    print("Output path ==>  $outputpath");

    // String command =
    //     //'-i $vid1 -i $vid2 -filter_complex concat=n=2:v=1:a=1 -y $outputpath';
    //     '-i $vid1 -i $vid2 -filter_complex "[0:v] [0:a] [1:v] [1:a] concat=n=2:v=1:a=1 [v] [a]" -map "[v]" -map "[a]" -c:v libx264 -c:a aac -b:a 128k -y $outputpath';

    // String command =
    //     '-i $vid1 -i $vid2 -filter_complex "[0:v] [0:a] [1:v] [1:a] concat=n=2:v=1:a=1 [v] [a]" -map "[v]" -map "[a]" -c:v h264 -c:a aac -b:a 128k -y $outputpath';

    // final command =
    //     "-i $vid1 -i $vid2 -i $vid3 -filter_complex \"[0:v]scale=1080:1920,fps=30,format=yuv420p[v0];[1:v]scale=1080:1920,fps=30,format=yuv420p[v1];[2:v]scale=1080:1920,fps=30,format=yuv420p[v2];[v0][0:a][v1][1:a][v2][2:a]concat=n=3:v=1:a=1[outv][outa]\" -map \"[outv]\" -map \"[outa]\" -c:v mpeg4 -c:a aac -b:a 128k -y $outputpath";

    // print("Merging command: $command");

    // final command =
    //     "-i $vid1 -i $vid2 -filter_complex \"[0:v]scale=1080:1920,fps=30,format=yuv420p[v0];[1:v]scale=1080:1920,fps=30,format=yuv420p[v1];[v0][0:a][v1][1:a]concat=n=2:v=1:a=1[outv][outa]\" -map \"[outv]\" -map \"[outa]\" -c:v mpeg4 -c:a aac -b:a 128k -y $outputpath";

    // final command = """
    // -i $vid1 -i $vid2 -filter_complex
    // "[0:v]scale='if(gt(a,3840/2160),3840,-2)':'if(gt(a,3840/2160),-2,2160)',pad=3840:2160:(3840-iw)/2:(2160-ih)/2,format=yuv420p[v0];
    //  [1:v]scale='if(gt(a,3840/2160),3840,-2)':'if(gt(a,3840/2160),-2,2160)',pad=3840:2160:(3840-iw)/2:(2160-ih)/2,format=yuv420p[v1];
    //  [v0][0:a][v1][1:a]concat=n=2:v=1:a=1[outv][outa]"
    // -map "[outv]" -map "[outa]" -c:v mpeg4 -b:v 8M -c:a aac -b:a 256k -y $outputpath
    // """;

    //  final command = """
    //   -loglevel verbose -err_detect explode -i $vid1 -i $vid2 -filter_complex
    //   "[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[outv][outa]"
    //   -map "[outv]" -map "[outa]" -c:v mpeg4 -b:v 8M -c:a aac -b:a 256k -y $outputpath
    //   """;

    // String command =
    //     "-i $vid1 -i $vid2 -filter_complex \"[0:v]scale=1080:1920,fps=30,format=yuv420p[v0];"
    //     "[1:v]scale=1080:1920,fps=30,format=yuv420p[v1];"
    //     "[v0][0:a][v1][1:a]concat=n=2:v=1:a=1[outv][outa]\" "
    //     "-map \"[outv]\" -map \"[outa]\" -c:v mpeg4 -b:v 4M -c:a aac -b:a 128k -y $outputpath";
    String command;

    if (isafter) {
      command = "-i $vid1 -i $vid2 -filter_complex \""
          "[0:v]scale='if(gt(a,1080/1920),1080,-2)':'if(gt(a,1080/1920),-2,1920)',pad=1080:1920:(1080-iw)/2:(1920-ih)/2,fps=12,format=yuv420p[v0];"
          "[1:v]scale='if(gt(a,1080/1920),1080,-2)':'if(gt(a,1080/1920),-2,1920)',pad=1080:1920:(1080-iw)/2:(1920-ih)/2,fps=12,format=yuv420p[v1];"
          "[v0][0:a][v1][1:a]concat=n=2:v=1:a=1[outv][outa]\" "
          "-map \"[outv]\" -map \"[outa]\" -c:v mpeg4 -b:v 4M -c:a aac -b:a 128k -y $outputpath";

      print("Merging command: $command");
    } else {
      command = "-i $vid2 -i $vid1 -filter_complex \""
          "[0:v]scale='if(gt(a,1080/1920),1080,-2)':'if(gt(a,1080/1920),-2,1920)',pad=1080:1920:(1080-iw)/2:(1920-ih)/2,fps=12,format=yuv420p[v0];"
          "[1:v]scale='if(gt(a,1080/1920),1080,-2)':'if(gt(a,1080/1920),-2,1920)',pad=1080:1920:(1080-iw)/2:(1920-ih)/2,fps=12,format=yuv420p[v1];"
          "[v0][0:a][v1][1:a]concat=n=2:v=1:a=1[outv][outa]\" "
          "-map \"[outv]\" -map \"[outa]\" -c:v mpeg4 -b:v 4M -c:a aac -b:a 128k -y $outputpath";
    }

    FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogs();
      logs.forEach((log) {
        print("FFmpeg log: ${log.getMessage()}");
      });

      if (ReturnCode.isSuccess(returnCode)) {
        print("Log 1--------------------------------------> SUCCESS");
        String thumbnailPath = await generateThumbnail(outputpath);
        //_databaseService.addfile(outputpath, thumbnailPath,);
        _databaseService.editFile(int.parse(widget.VidId!),outputpath, thumbnailPath);
        Navigator.of(context)
          ..pop()
          ..pushReplacement(MaterialPageRoute(
            builder: (context) => UseScreen(
              filePath: outputpath,
              videoID: widget.VidId,
            ),
          ));
      } else if (ReturnCode.isCancel(returnCode)) {
        print("Log 2--------------------------------------> CANCEL");
      } else {
        print("Log 3--------------------------------------> ERROR");
        print("${returnCode}");
      }
    });
  }

  Future<void> _initializeVideoPlayerpick() async {
    print("Initializing video player with file path: ${pickedFilePath}");
    if (!File(pickedFilePath).existsSync()) {
      print("File does not exist at path: ${pickedFilePath}");
      return;
    }
    try {
      //_pickedvideoPlayerController.dispose()
      _pickedvideoPlayerController =
          VideoPlayerController.file(File(pickedFilePath));
      await _pickedvideoPlayerController.initialize();
      await _pickedvideoPlayerController.setLooping(false);
      await _pickedvideoPlayerController.play();

      _pickedvideoPlayerController.addListener(() {
        final isFinished = _pickedvideoPlayerController.value.position >=
            _pickedvideoPlayerController.value.duration;
        if (isFinished && _pickedvideoPlayerController.value.isInitialized) {
          print("Video finished playing");
          setState(() {
            //isPlaying = false;
          });
          _pickedvideoPlayerController.pause();
        }
      });

      setState(() {});
    } catch (e) {
      print("Error initializing video player: ${e.toString()}");
    }
  }

  Future Projects() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 23, 23, 23),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Select frome projects",
                      style:
                          TextStyle(color: AppColor.white_color, fontSize: 22),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: _filePathList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filePathList() {
    return FutureBuilder<List<FilePath>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No files found.'));
        } else {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of items per row
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75, // Adjusted aspect ratio to fit text
            ),
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              FilePath file = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            //border: isMultiSelect ? Border.all() : null,
                          ),
                          child: InkWell(
                            splashFactory: NoSplash.splashFactory,
                            highlightColor: Colors.transparent,
                            // onLongPress: () {
                            //   _showDeleteMenu(context, file);
                            // /storage/emulated/0/Download/output_2024-06-18T12-39-35.717556.mp4
                            //   setState(() {
                            //     isMultiSelect = true;
                            //   });
                            // },
                            onTap: () {
                              pickedFilePath = file.path;
                              print("yash2 ===> $pickedFilePath");
                              _initializeVideoPlayerpick();
                              Navigator.pop(context);
                            },
                            child: Image.file(
                              File(file.thumbnail),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        file.path.split('/').last,
                        style: TextStyle(color: AppColor.white_color),
                        textAlign: TextAlign.center,
                        overflow:
                            TextOverflow.ellipsis, // Handle long file names
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  void _togglePlayPause() {
    final isFinished = _pickedvideoPlayerController.value.position ==
        _pickedvideoPlayerController.value.duration;
    setState(() {
      if (_pickedvideoPlayerController.value.isPlaying) {
        _pickedvideoPlayerController.pause();
      } else {
        if (_pickedvideoPlayerController.value.position >=
            _pickedvideoPlayerController.value.duration) {
          _pickedvideoPlayerController.seekTo(Duration.zero);
        }
        _pickedvideoPlayerController.play();
      }
      if (isFinished == true) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            color: AppColor.black_color,
                            child: _pickedvideoPlayerController
                                    .value.isInitialized
                                ? AspectRatio(
                                    aspectRatio: 1 / 1,
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(500),
                                        ),
                                        width: _pickedvideoPlayerController
                                            .value.size.width,
                                        height: _pickedvideoPlayerController
                                            .value.size.height,
                                        child: Stack(
                                          children: [
                                            VideoPlayer(
                                                _pickedvideoPlayerController),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 20,
                      left: 1,
                      right: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            CommonButton(
                              bgcolor: AppColor.elevated_bg_color,
                              text: "Before",
                              image: AppImages.edit,
                              onPressed: () {
                                setState(() {
                                  isloading = true;
                                  _pickedvideoPlayerController.pause();
                                });
                                _mergeafter(widget.filepath,
                                    widget.pickedfilepath, false);
                              },
                            ),

                            SizedBox(
                              width: 20,
                            ),
                            CommonButton(
                              bgcolor: AppColor.elevated_bg_color,
                              text: "After",
                              image: AppImages.edit,
                              onPressed: () {
                                setState(() {
                                  isloading = true;
                                  _pickedvideoPlayerController.pause();
                                });
                                _mergeafter(widget.filepath,
                                    widget.pickedfilepath, true);
                              },
                            ),
                          ],
                        ),
                      )),
                  Positioned(
                    top: 50,
                    left: 1,
                    right: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          CommonButton(
                            bgcolor: AppColor.elevated_bg_color,
                            text: "Gallary",
                            image: AppImages.gallary,
                            onPressed: () {
                              _pickVideo();
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          CommonButton(
                            bgcolor: AppColor.elevated_bg_color,
                            text: "Videos",
                            image: AppImages.folder,
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectVideos(
                                      filepath: widget.filepath,
                                    ),
                                  ));
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
