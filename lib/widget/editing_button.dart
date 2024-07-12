import 'package:flutter/material.dart';

class EditingButton extends StatelessWidget {
  const EditingButton({
    super.key,
    required this.onTap,
    required this.imagePath,
    this.buttonName,
    this.imageColor = Colors.white,
    this.backColor = const Color.fromARGB(169, 67, 67, 67),
    this.isBackGroundNeed = false,
  });
  final Function() onTap;
  final String imagePath;
  final String? buttonName;
  final Color imageColor;
  final Color backColor;
  final bool isBackGroundNeed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        padding: isBackGroundNeed ? const EdgeInsets.all(10) : null,
        decoration: isBackGroundNeed
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: backColor,
              )
            : null,
        child: Column(
          children: [
            Image.asset(imagePath, color: imageColor, height: 25),
            if (buttonName != null)
              Text(
                buttonName!,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              )
          ],
        ),
      ),
    );
  }
}
