// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_editing_app/CommonMettods/common_sharedPreferences.dart';
import 'package:video_editing_app/Model/login_model.dart';
import 'package:video_editing_app/UI/on_boarding_screens/OnBoardingScreen.dart';
import 'package:video_editing_app/UI/update_profile/profile_update.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/util/app_images.dart';
import 'package:video_editing_app/widget/profile_container.dart';

import 'Password_change/PasswordChangeScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool islogin = false;
  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _checkLoginstatus();
    _getusername();
  }

  Future<void> _checkLoginstatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      islogin = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loginData');
    await prefs.setBool('isLoggedIn', false);
    setState(() {
      islogin = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OnBoardingScreen(),
      ),
    );
  }

  Future<void> _getusername() async {
    //var data = await getStoreApidata("loginData");
    var loginDataDynamic = await getStoreApidata("loginData");

    if (loginDataDynamic != null && loginDataDynamic is Map<String, dynamic>) {
      LoginModel loginData = LoginModel.fromJson(loginDataDynamic);

      setState(() {
        name = loginData.data?.name ?? 'Guest';
        email = loginData.data!.emailId!;
        print("Name ====>   $name");
      });
    }
  }

  Future<void> _feedback() async {
    return showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              decoration: BoxDecoration(
                  // color: const Color.fromARGB(255, 58, 58, 58),
                  color: AppColor.elevated_bg_color,
                  borderRadius: BorderRadius.circular(20)),
              width: double.infinity,
              // height: 500,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Enjoying the App?",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 40),
                      child: Text(
                        "We'd love to hear from you! We're constantly working to improve the app, and add new features.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromARGB(255, 177, 177, 177),
                            fontSize: 16),
                      ),
                    ),
                    Text(
                      "Do you like using App so far?",
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 177, 177, 177)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 69, 69, 69),
                                  shape: BoxShape.circle),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: ImageIcon(
                                  AssetImage(
                                    AppImages.like,
                                  ),
                                  color: Colors.white,
                                  size: 30,
                                ),
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 69, 69, 69),
                                  shape: BoxShape.circle),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ImageIcon(
                                  AssetImage(
                                    AppImages.dislike,
                                  ),
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.bg_color_1,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColor.border_color),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 15, 0, 15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColor.green_color,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                child: Text(
                                  "Mobile PRO",
                                  style: TextStyle(
                                      color: AppColor.black_color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Unlock unlimited videos high quality video export without watermark and more",
                          style: TextStyle(
                              color: AppColor.white_color, fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Text(
                                  "Try for free",
                                  style: TextStyle(
                                      color: AppColor.black_color,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.green_color,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "Your Account",
                      style: TextStyle(
                          color: AppColor.white_color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: InkWell(
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileUpdateScreen(),
                        )).whenComplete(
                      () {
                        _getusername();
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.bg_color_1,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      // child: Column(
                      //   children: [
                      //     Row(
                      //       children: [
                      //         Text(
                      //           "Already a App User?",
                      //           style: TextStyle(
                      //               color: AppColor.white_color,
                      //               fontWeight: FontWeight.bold),
                      //         ),
                      //       ],
                      //     ),
                      //     Text(
                      //       "Log in or Create an account to access your web Projects across different devices",
                      //       style: TextStyle(color: AppColor.white_color70),
                      //     ),
                      //     SizedBox(
                      //       height: 10,
                      //     ),
                      //     // Padding(
                      //     //   padding: const EdgeInsets.symmetric(
                      //     //       horizontal: 3, vertical: 10),
                      //     //   child: Row(
                      //     //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     //     children: [
                      //     //       Expanded(
                      //     //         child: ElevatedButton(
                      //     //             style: ElevatedButton.styleFrom(
                      //     //                 backgroundColor: AppColor.signup_color),
                      //     //             onPressed: () {
                      //     //               Navigator.pushReplacement(
                      //     //                   context,
                      //     //                   MaterialPageRoute(
                      //     //                     builder: (context) => SignUpScreen(),
                      //     //                   ));
                      //     //             },
                      //     //             child: Padding(
                      //     //               padding: const EdgeInsets.symmetric(
                      //     //                   vertical: 12),
                      //     //               child: Text(
                      //     //                 "Sign Up",
                      //     //                 style: TextStyle(
                      //     //                     color: AppColor.white_color,
                      //     //                     fontWeight: FontWeight.bold,
                      //     //                     fontSize: 16),
                      //     //               ),
                      //     //             )),
                      //     //       ),
                      //     //       SizedBox(
                      //     //         width: 15,
                      //     //       ),
                      //     //       Expanded(
                      //     //         child: ElevatedButton(
                      //     //             style: ElevatedButton.styleFrom(
                      //     //                 backgroundColor: AppColor.login_color),
                      //     //             onPressed: () {
                      //     //               Navigator.pushReplacement(
                      //     //                   context,
                      //     //                   MaterialPageRoute(
                      //     //                     builder: (context) => LoginScreen(),
                      //     //                   ));
                      //     //             },
                      //     //             child: Padding(
                      //     //               padding: const EdgeInsets.symmetric(
                      //     //                   vertical: 12),
                      //     //               child: Text(
                      //     //                 "Log in",
                      //     //                 style: TextStyle(
                      //     //                     color: AppColor.white_color,
                      //     //                     fontWeight: FontWeight.bold,
                      //     //                     fontSize: 16),
                      //     //               ),
                      //     //             )),
                      //     //       ),
                      //     //     ],
                      //     //   ),
                      //     // )
                      //   ],
                      // ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.grey_color),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: ImageIcon(
                                AssetImage(AppImages.user),
                                color: const Color.fromARGB(255, 21, 21, 21),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                    color: AppColor.white_color, fontSize: 20),
                              ),
                              Text(
                                email,
                                style: TextStyle(
                                    color: AppColor.white_color, fontSize: 16),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ProfileContainer(
                icon: Icon(
                  Icons.message,
                  color: AppColor.white_color,
                ),
                text: "Send Your Feedback",
                ontap: () {
                  _feedback();
                },
              ),
              ProfileContainer(
                icon: Icon(
                  Icons.share,
                  color: AppColor.white_color,
                ),
                text: "Share App with a friend",
                ontap: () {},
              ),
              // SizedBox(
              //   height: 5,
              // ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Divider(
                  color: const Color.fromARGB(42, 255, 255, 255),
                  height: 3,
                ),
              ),
              // SizedBox(
              //   height: 15,
              // ),
              ProfileContainer(
                icon: Icon(
                  Icons.file_copy,
                  color: AppColor.white_color,
                ),
                text: "Terms of Use",
                ontap: () {},
              ),
              ProfileContainer(
                icon: Icon(
                  Icons.lock,
                  color: AppColor.white_color,
                ),
                text: "Privacy Policy",
                ontap: () {},
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Divider(
                  color: const Color.fromARGB(42, 255, 255, 255),
                  height: 3,
                ),
              ),
              ProfileContainer(
                icon: Icon(
                  Icons.password,
                  color: AppColor.white_color,
                ),
                text: "Change Password",
                ontap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasswordChangeScreen(),
                      ));
                },
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Divider(
                  color: const Color.fromARGB(42, 255, 255, 255),
                  height: 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  highlightColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 174, 66, 58),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color.fromARGB(42, 255, 255, 255),
                          width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: AppColor.white_color,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Log Out",
                            style: TextStyle(
                                color: AppColor.white_color,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    logout();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  highlightColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 174, 66, 58),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color.fromARGB(42, 255, 255, 255),
                          width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: AppColor.white_color,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Delete Accout",
                            style: TextStyle(
                                color: AppColor.white_color,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    logout();
                  },
                ),
              ),
            ])));
  }
}
