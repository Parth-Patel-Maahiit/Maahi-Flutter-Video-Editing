import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:video_editing_app/UI/Recording/record_live_screen.dart';
import 'package:video_editing_app/UI/Script_writing/script_write.dart';
import 'package:video_editing_app/UI/Video_Preview/script_preview.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/util/app_images.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.onTap,
  }) : super(key: key);
  final Function onTap;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _messageIndex = 0;
  late Timer _timer;
  List<String> messages = [
    "Record Live",
    "Record With Script",
    "Add Caption & Edit",
    "Short/Reel Maker",
  ]; // Messages to display
  final picker = ImagePicker();
  String filepath = "";

  List<String> icons = [
    AppImages.video,
    AppImages.video,
    AppImages.subtitle,
    AppImages.reel,
  ];

  List<Color> buttoncolors = [
    AppColor.button_color,
    AppColor.home_plus_color,
    AppColor.button_color,
    AppColor.home_plus_color,
  ];

  late int id = 1;

  Future<void> _pickVideo(String type) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowCompression: false,
      );
      if (result != null) {
        String pickedFilePath = result.files.single.path!;

        if (type == "caption") {
          widget.onTap();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoSavePage(
                      filePath: pickedFilePath,
                      videoID: "0",
                      isBackExport: true,
                    )),
          );
        } else if (type == "reel") {
          widget.onTap();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoSavePage(
                      filePath: pickedFilePath,
                      videoID: "0",
                      isBackExport: true,
                    )),
          );
        }
      }
    } catch (e) {
      print("Error picking video: $e");
    }
  }

  late List<Widget> _screens = <Widget>[
    CameraPage(),
    ScriptWrite(),
    Container(), // Placeholder for the AddCaptionScreen
    Container(), // Placeholder for the ShortReelMakerScreen
  ];

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Start a timer to update the message index every 2 seconds
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        // Cancel the timer when all messages are displayed
        if (_messageIndex < messages.length) {
          _messageIndex++;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(
        _messageIndex,
        (index) {
          return Positioned(
            bottom: 10.0 + (index * 58), // Adjust the position of each button
            left: 10.0,
            right: 10.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  if (index == 2) {
                    _pickVideo("caption");
                  } else if (index == 3) {
                    _pickVideo("reel");
                  } else {
                    widget.onTap();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _screens[index],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttoncolors[index],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ImageIcon(
                        AssetImage(icons[index]),
                        color: AppColor.white_color,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        messages[index],
                        style: TextStyle(
                            color: AppColor.white_color,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
