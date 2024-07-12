import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_editing_app/CommonMettods/common_sharedPreferences.dart';
import 'package:video_editing_app/UI/Projects.dart';
import 'package:video_editing_app/util/app_images.dart';

import '../Servay/servay.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    var data = await getStoreApidata("loginData");
    Timer(const Duration(seconds: 3), () {
      if (data != null) {
        gotoNextPage(const ProjectsScreen());
      } else {
        gotoNextPage(ServayScreen());
      }
    });
  }

  void gotoNextPage(Widget widget) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 500,
                width: 500,
                child: Lottie.asset(AppImages.splace, height: 500, width: 500)),
            const SizedBox(
              height: 30,
            ),
            // RichText(
            //   text: const TextSpan(
            //     style: TextStyle(
            //       fontSize: 30.0,
            //       fontFamily: '${AppConstants.fontFamaliyNormal}',
            //     ),
            //     children: <TextSpan>[
            //       TextSpan(
            //           text: '${AppConstants.appNameStart}',
            //           style: TextStyle(
            //             fontFamily: '${AppConstants.fontFamaliyNormal}',
            //             fontWeight: FontWeight.bold,
            //             color: AppColorConstants.brightBlue,
            //           )),
            //       TextSpan(
            //           text: ' ${AppConstants.appNameEnd}',
            //           style: TextStyle(
            //             color: AppColorConstants.black,
            //             fontFamily: '${AppConstants.fontFamaliyNormal}',
            //           )),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
