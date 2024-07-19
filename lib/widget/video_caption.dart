import 'package:flutter/material.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/util/app_images.dart';
import 'package:video_player/video_player.dart';

import '../../../Model/get_caption_data_model.dart' as getcaptiondatamodel;
import '../UI/components/common.dart';

class VideoCaption extends StatelessWidget {
  const VideoCaption(
      {super.key,
      required this.onTapToggle,
      required this.videoPlayerController,
      required this.isPlaying,
      required this.aspectRatio,
      required this.height,
      required this.getCations,
      this.width = 180,
      this.isLogoShow = false});
  final Function() onTapToggle;
  final VideoPlayerController videoPlayerController;
  final bool isPlaying;
  final double? aspectRatio;
  final double height;
  final double width;
  final bool isLogoShow;
  final List<getcaptiondatamodel.GetCaptionDataModel> getCations;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapToggle,
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Colors.black,
              child: videoPlayerController.value.isInitialized &&
                      aspectRatio != null
                  ? AspectRatio(
                      aspectRatio: aspectRatio!,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: videoPlayerController.value.size.width,
                          height: videoPlayerController.value.size.height,
                          child: Stack(
                            children: [
                              VideoPlayer(videoPlayerController),
                              Center(
                                child: AnimatedOpacity(
                                  opacity: isPlaying ? 0.0 : 1.0,
                                  duration: Duration(milliseconds: 300),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromARGB(175, 21, 20, 20)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 100,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (getCations.isNotEmpty)
                                Positioned(
                                  right: 1,
                                  left: 1,
                                  bottom: aspectRatio == 9 / 16
                                      ? height * 0.1
                                      : aspectRatio == 1 / 1
                                          ? height * 0.37
                                          : height * 0.5,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.55),
                                      child: captionData()),
                                ),
                              if (isLogoShow)
                                Positioned(
                                  right: aspectRatio == 9 / 16
                                      ? width * 0.4
                                      : width * 0.05,
                                  top: aspectRatio == 9 / 16
                                      ? height * 0.04
                                      : aspectRatio == 1 / 1
                                          ? height * 0.23
                                          : height * 0.38,
                                  child: Image(
                                    height: 90,
                                    image: AssetImage(AppImages.logo),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                      color: AppColor.home_plus_color,
                    )),
            ),
          ),
        ),
      ),
    );
  }

  Widget captionData() {
    String startPoint = "";
    String endPoint = "";
    List<TextSpan> textSpans = [];

    for (var caption in getCations) {
      List<int> idsIntList = caption.combineIds
          .toString()
          .split(",")
          .map((id) => int.parse(id.trim()))
          .toList();
      var firstCaption = getCations.firstWhere((c) => c.id == idsIntList.first);
      var lastCaption = getCations.firstWhere((c) => c.id == idsIntList.last);
      startPoint = firstCaption.startFrom;
      endPoint = lastCaption.endTo;
      if (videoPlayerController.value.position > parseDuration(startPoint) &&
          (videoPlayerController.value.position < parseDuration(endPoint))) {
        textSpans.add(
          TextSpan(
            text: caption.keyword + " ",
            style: TextStyle(
              // backgroundColor:
              // Color(int.parse(caption.backgroundColor.toString())),
              fontWeight:
                  caption.isBold == "1" ? FontWeight.bold : FontWeight.normal,
              fontStyle:
                  caption.isItalic == "1" ? FontStyle.italic : FontStyle.normal,
              decoration: caption.isUnderLine == "1"
                  ? TextDecoration.underline
                  : TextDecoration.none,
              fontSize: 70,
              color: Color(int.parse(caption.textColor.toString())),
              // background: Paint()
              //   ..color = Color(int.parse(caption.backgroundColor.toString())),
            ),
          ),
        );
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 30.0, color: Colors.white),
          children: textSpans,
        ),
      ),
    );
  }
}
