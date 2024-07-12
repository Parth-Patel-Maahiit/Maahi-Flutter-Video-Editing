import 'package:flutter/material.dart';
import 'package:video_editing_app/util/app_color.dart';

class CommonSaveButton extends StatelessWidget {
  const CommonSaveButton({super.key, required this.onTap});
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(78, 176, 170, 170),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Container(
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColor.home_plus_color),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ImageIcon(
                  AssetImage("assets/check.png"),
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        onTap: onTap);
  }
}
