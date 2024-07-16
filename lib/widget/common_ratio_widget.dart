import 'package:flutter/material.dart';
import 'package:video_editing_app/util/app_color.dart';

class CommonRatioWidget extends StatelessWidget {
  const CommonRatioWidget(
      {super.key,
      required this.onTap,
      required this.borderColor,
      required this.title,
      this.width,
      this.height});
  final Function() onTap;
  final Color borderColor;
  final double? width;
  final double? height;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: InkWell( 
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 40, 36, 36),
              border: Border.all(width: 3, color: borderColor),
              borderRadius: BorderRadius.circular(15)),
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: width,
                        height: height,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColor.white_color, width: 2),
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ],
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
