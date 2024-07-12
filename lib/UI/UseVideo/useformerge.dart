import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_editing_app/UI/VideoMerge/videomerge.dart';

class UseScreenmerge extends StatefulWidget {
  final String filePath;
  final String pickedfilePath;
   final String? videoID;

  const UseScreenmerge({
    Key? key,
    required this.filePath,
    required this.pickedfilePath, this.videoID,

  }) : super(key: key);

  @override
  State<UseScreenmerge> createState() => _UseScreenState();
}

class _UseScreenState extends State<UseScreenmerge> {
  //late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => VideoMerge(
                  filepath: widget.filePath,
                  pickedfilepath: widget.pickedfilePath,
                  videoID: widget.videoID, )));
    });

    //_initializePlayer();
  }

  // Future<void> _initializePlayer() async {
  //   try {
  //     _videoPlayerController =
  //         VideoPlayerController.file(File(widget.filePath));
  //     await _videoPlayerController.initialize();
  //     setState(() {}); // Update the UI after successful initialization
  //   } catch (e) {
  //     print('Error initializing video player: $e');
  //     // Handle the error appropriately (e.g., show an error message)
  //   }
  // }

  // @override
  // void dispose() {
  //   _videoPlayerController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: Center(
        child: Container(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
