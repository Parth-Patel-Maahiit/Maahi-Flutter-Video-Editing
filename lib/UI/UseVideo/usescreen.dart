import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_editing_app/UI/Video_Preview/script_preview.dart';

class UseScreen extends StatefulWidget {
  final String filePath;
  final String? videoID;
  const UseScreen({
    Key? key,
    required this.filePath,
    this.videoID,
  }) : super(key: key);

  @override
  State<UseScreen> createState() => _UseScreenState();
}

class _UseScreenState extends State<UseScreen> {
  //late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VideoSavePage(
              isBackExport: true,
              filePath: widget.filePath,
              videoID: widget.videoID,
            ),
            // builder: (context) => MergeVideo(filePath: widget.filePath,),
          ));
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
          // child: _videoPlayerController.value.isInitialized
          //     ? AspectRatio(
          //         //controller: _videoPlayerController,
          //         aspectRatio: 16 / 9,
          //         //placeholder: Center(child: CircularProgressIndicator()),
          //         child: VideoPlayer(_videoPlayerController),
          //       )
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
