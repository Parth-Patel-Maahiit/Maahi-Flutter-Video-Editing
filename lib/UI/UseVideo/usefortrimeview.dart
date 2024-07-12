import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_editing_app/UI/Video_trimmer/trimmer_view.dart';

import '../../util/app_color.dart';

class UseScreentrime extends StatefulWidget {
  final String filePath;
  final String? videoID;

  const UseScreentrime({
    Key? key,
    required this.filePath,
    this.videoID,
  }) : super(key: key);

  @override
  State<UseScreentrime> createState() => _UseScreenState();
}

class _UseScreenState extends State<UseScreentrime> {
  //late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => TrimmerView(
                    file: File(widget.filePath),
                    videoID: widget.videoID!,
                  )));
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
          child: CircularProgressIndicator(
            color: AppColor.home_plus_color,
          ),
        ),
      ),
    );
  }
}
