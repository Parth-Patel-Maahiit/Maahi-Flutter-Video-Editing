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
      required this.bgcolor});
  final String? image;
  final Function() onPressed;
  final String text;
  final Color bgcolor;

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
                if (widget.image!.isNotEmpty)
                  Image.asset(
                    widget.image!,
                    width: 20,
                    height: 20,
                    color: AppColor.white_color,
                  ),
                if (widget.image!.isNotEmpty)
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
