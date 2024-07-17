import 'package:flutter/material.dart';
import 'package:video_editing_app/Model/filepath.dart';
import 'package:video_editing_app/UI/Video_Preview/script_preview.dart';
import 'package:video_editing_app/services/databaseservices.dart';
import '../util/app_color.dart';
import 'components/coomon_file_list.dart';

class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late Future<List<FilePath>> _data;

  bool isMultiSelect = false;

  @override
  void initState() {
    super.initState();
    _data = _databaseService.getFilesWithHighestVersion();
    _databaseService.getfile();
  }

  Future<void> _refreshData() async {
    await _databaseService.getFilesWithHighestVersion();

    setState(() {
      _data = _databaseService.getFilesWithHighestVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "On my device",
                  style: TextStyle(
                      color: AppColor.white_color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              CoomonFileList(
                data: _data,
                isScroll: false,
                onTap: (file) {
                  _playVideo(file.path, file.vid_id.toString());
                },
                onLongPress: (file) {
                  _showDeleteMenu(context, file);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteMenu(BuildContext context, FilePath file) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: Color.fromARGB(255, 23, 23, 23),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.delete, color: AppColor.red_color),
                  title: Text(
                    'Delete',
                    style: TextStyle(color: AppColor.red_color),
                  ),
                  onTap: () => _deleteFile(file),
                ),
                ListTile(
                    leading: Icon(Icons.drive_file_rename_outline_rounded,
                        color: AppColor.white_color),
                    title: Text(
                      'Rename',
                      style: TextStyle(color: AppColor.white_color),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showRenameDialog(context, file);
                    }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteFile(FilePath file) async {
    await _databaseService
        .deleteFile(file.vid_id); // Assuming a deleteFile method exists
    await _databaseService.deleteCaptionData(file.vid_id);
    setState(() {
      _data = _databaseService
          .getFilesWithHighestVersion(); // Refresh the file list
    });
    Navigator.pop(context); // Close the bottom sheet
  }

  void _playVideo(String videoPath, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VideoSavePage(
                isBackExport: true,
                filePath: videoPath,
                videoID: id,
              )),
    ).then((_) {
      print("hello is best mc");
      _data = _databaseService.getFilesWithHighestVersion();
      setState(() {});
    });
  }

  void _showRenameDialog(BuildContext context, FilePath file) {
    TextEditingController _controller = TextEditingController(text: file.name);

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
                _renameFile(file, _controller.text);
                Navigator.pop(context);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameFile(FilePath file, String newName) async {
    if (newName.isNotEmpty) {
      await _databaseService.renameFile(file.vid_id, newName);
      setState(() {
        _data = _databaseService.getFilesWithHighestVersion();
      });
    }
  }
}


// import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit_config.dart';
// import 'package:flutter/material.dart';
// import 'package:video_editing_app/FFmpeg/test_api.dart';
// import 'package:video_editing_app/FFmpeg/video_util.dart';
// import 'package:video_editing_app/Model/filepath.dart';
// import 'package:video_editing_app/UI/Video_Preview/script_preview.dart';
// import 'package:video_editing_app/services/databaseservices.dart';
// import '../util/app_color.dart';
// import 'components/coomon_file_list.dart';

// class MyProjectsScreen extends StatefulWidget {
//   const MyProjectsScreen({super.key});

//   @override
//   State<MyProjectsScreen> createState() => _MyProjectsScreenState();
// }

// class _MyProjectsScreenState extends State<MyProjectsScreen> with RouteAware {
//   final DatabaseService _databaseService = DatabaseService.instance;
//   late Future<List<FilePath>> _data;

//   bool isMultiSelect = false;

//   @override
//   void initState() {
//     super.initState();
//     _data = _databaseService.getFilesWithHighestVersion();
//     _databaseService.getfile();
//     FFmpegKitConfig.init().then((_) {
//       VideoUtil.registerApplicationFonts();

//       Test.testCommonApiMethods();
//       Test.testParseArguments();
//       Test.setSessionHistorySizeTest();
//     });
//   }

//   Future<void> _refreshData() async {
//     await _databaseService.getFilesWithHighestVersion();

//     setState(() {
//       _data = _databaseService.getFilesWithHighestVersion();
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final routeObserver = RouteObserverProvider.of(context);
//     routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
//   }

//   @override
//   void dispose() {
//     final routeObserver = RouteObserverProvider.of(context);
//     routeObserver.unsubscribe(this);
//     super.dispose();
//   }

//   @override
//   void didPopNext() {
//     // Called when the current route has been popped off, revealing this route
//     _refreshData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(4),
//       child: RefreshIndicator(
//         onRefresh: _refreshData,
//         child: SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   "On my device",
//                   style: TextStyle(
//                       color: AppColor.white_color,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               CoomonFileList(
//                 data: _data,
//                 isScroll: false,
//                 onTap: (file) {
//                   _playVideo(file.path, file.vid_id.toString());
//                 },
//                 onLongPress: (file) {
//                   _showDeleteMenu(context, file);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeleteMenu(BuildContext context, FilePath file) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(20), topRight: Radius.circular(20)),
//             color: Color.fromARGB(255, 23, 23, 23),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Wrap(
//               children: [
//                 ListTile(
//                   leading: Icon(Icons.delete, color: AppColor.red_color),
//                   title: Text(
//                     'Delete',
//                     style: TextStyle(color: AppColor.red_color),
//                   ),
//                   onTap: () => _deleteFile(file),
//                 ),
//                 ListTile(
//                     leading: Icon(Icons.drive_file_rename_outline_rounded,
//                         color: AppColor.white_color),
//                     title: Text(
//                       'Rename',
//                       style: TextStyle(color: AppColor.white_color),
//                     ),
//                     onTap: () {
//                       Navigator.pop(context);
//                       _showRenameDialog(context, file);
//                     }),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _deleteFile(FilePath file) async {
//     await _databaseService
//         .deleteFile(file.vid_id); // Assuming a deleteFile method exists
//     await _databaseService.deleteCaptionData(file.vid_id);
//     setState(() {
//       _data = _databaseService
//           .getFilesWithHighestVersion(); // Refresh the file list
//     });
//     Navigator.pop(context); // Close the bottom sheet
//   }

//   void _playVideo(String videoPath, String id) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => VideoSavePage(
//                 isBackExport: true,
//                 filePath: videoPath,
//                 videoID: id,
//               )),
//     ).then((_) {
//       _refreshData();
//     });
//   }

//   void _showRenameDialog(BuildContext context, FilePath file) {
//     TextEditingController _controller = TextEditingController(text: file.name);

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Rename File'),
//           content: TextField(
//             controller: _controller,
//             decoration: InputDecoration(hintText: "Enter new name"),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 _renameFile(file, _controller.text);
//                 Navigator.pop(context);
//               },
//               child: Text('Rename'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _renameFile(FilePath file, String newName) async {
//     if (newName.isNotEmpty) {
//       await _databaseService.renameFile(file.vid_id, newName);
//       setState(() {
//         _data = _databaseService.getFilesWithHighestVersion();
//       });
//     }
//   }
// }
