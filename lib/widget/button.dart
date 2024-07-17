import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_editing_app/util/app_color.dart';

class CommonButton extends StatefulWidget {
  const CommonButton(
      {super.key,
      this.image,
      required this.onPressed,
      required this.text,
      required this.bgcolor,
      this.isimage = true});
  final String? image;
  final Function() onPressed;
  final String text;
  final Color bgcolor;
  final bool isimage;

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: widget.bgcolor),
          onPressed: widget.onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isimage)
                  Image.asset(
                    widget.image!,
                    width: 20,
                    height: 20,
                    color: AppColor.white_color,
                  ),
                if (widget.isimage)
                  SizedBox(
                    width: 13,
                  ),
                Text(widget.text,
                    style: TextStyle(
                        color: AppColor.white_color,
                        fontWeight: FontWeight.bold,
                        fontSize: 19)),
              ],
            ),
          )),
    );
  }
}
