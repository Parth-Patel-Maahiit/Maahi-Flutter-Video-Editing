import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_editing_app/UI/on_boarding_screens/login.dart';
import 'package:video_editing_app/UI/on_boarding_screens/signup.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/util/app_images.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg_color,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                ),
                SizedBox(
                    height: 150,
                    width: 150,
                    child: Lottie.asset(
                      AppImages.splace,
                    )),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Welcome to the App!",
                  style: TextStyle(fontSize: 26, color: AppColor.white_color),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 60, right: 50),
                  child: Text(
                    "Professional basic video editing features, record your precious moments of your daily life. ",
                    style: TextStyle(
                        color: AppColor.onboarding_text_color, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(34, 50, 34, 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          splashFactory: NoSplash.splashFactory,
                          highlightColor: Colors.transparent,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppColor.white_color,
                                borderRadius: BorderRadius.circular(25)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.google_logo,
                                    height: 25,
                                    width: 25,
                                  ),
                                  Text("Continue with google",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.black_color)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                            splashFactory: NoSplash.splashFactory,
                            highlightColor: Colors.transparent,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: AppColor.white_color,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Continue with password",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.black_color),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpScreen(),
                                  ));
                            }),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                InkWell(
                  splashFactory: NoSplash.splashFactory,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(
                    "I have an account",
                    style: TextStyle(color: AppColor.white_color, fontSize: 20),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
