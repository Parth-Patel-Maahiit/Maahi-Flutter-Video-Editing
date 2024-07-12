import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_editing_app/Model/filepath.dart';
import 'package:video_editing_app/UI/VideoMerge/videomerge.dart';
import 'package:video_editing_app/services/databaseservices.dart';
import 'package:video_editing_app/util/app_color.dart';

class ProjectVideos extends StatefulWidget {
  final String filepath;
  const ProjectVideos({super.key, required this.filepath});

  @override
  State<ProjectVideos> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<ProjectVideos> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late Future<List<FilePath>> _data;

  @override
  void initState() {
    super.initState();
    _data = _databaseService.getfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                "Select video to merge",
                style: TextStyle(color: AppColor.white_color, fontSize: 22),
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(child: _filePathList()),
            ],
          ),
        ),
      ),
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
                          ),
                          child: InkWell(
                             splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
                            onLongPress: () {
                              _showDeleteMenu(context, file);
                              setState(() {});
                            },
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoMerge(
                                      filepath: widget.filepath,
                                      pickedfilepath: file.path,
                                    ),
                                  ));
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
                        // file.path.split('/').last,
                        file.title,
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

  void _showDeleteMenu(BuildContext context, FilePath file) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: const Color.fromARGB(255, 105, 105, 105)),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteFile(FilePath file) async {
    await _databaseService
        .deleteFile(file.id); // Assuming a deleteFile method exists
    setState(() {
      _data = _databaseService.getfile(); // Refresh the file list
    });
    Navigator.pop(context); // Close the bottom sheet
  }

  // void _playVideo(String videoPath, int id,int status) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) => VideoSavePage(
  //               filePath: videoPath,
  //               ratio: CameraAspectRatios.ratio_16_9,
  //               script: '', vid_id: id, status: status,
  //             )),
  //   );
  // }
}
