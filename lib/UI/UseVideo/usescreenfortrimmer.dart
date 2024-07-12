import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_editing_app/UI/Video_Preview/script_preview.dart';

class UseScreen2 extends StatefulWidget {
  final String filePath;
  final String? videoID;
  const UseScreen2({
    Key? key,
    required this.filePath,
    this.videoID,
  }) : super(key: key);

  @override
  State<UseScreen2> createState() => _UseScreenState();
}

class _UseScreenState extends State<UseScreen2> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VideoSavePage(
              isBackExport: true,
              videoID: widget.videoID,
              filePath: widget.filePath,
            ),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
