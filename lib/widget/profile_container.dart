import 'package:flutter/material.dart';
import 'package:video_editing_app/util/app_color.dart';

// ignore: must_be_immutable
class ProfileContainer extends StatelessWidget {
  late Icon icon;
  late String text;
  final Function() ontap;
  ProfileContainer({super.key, required this.icon, required this.text, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        onTap: ontap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.bg_color_1,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
            child: Row(
              children: [
                icon,
                SizedBox(
                  width: 20,
                ),
                Text(
                  text,
                  style: TextStyle(
                      color: AppColor.white_color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
