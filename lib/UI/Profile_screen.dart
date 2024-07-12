// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_editing_app/CommonMettods/common_sharedPreferences.dart';
import 'package:video_editing_app/Model/login_model.dart';
import 'package:video_editing_app/UI/on_boarding_screens/OnBoardingScreen.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/util/app_images.dart';
import 'package:video_editing_app/widget/profile_container.dart';

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
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.bg_color_1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
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
              SizedBox(
                height: 10,
              ),
              ProfileContainer(
                  icon: Icon(
                    Icons.message,
                    color: AppColor.white_color,
                  ),
                  text: "Send Your Feedback"),
              ProfileContainer(
                  icon: Icon(
                    Icons.share,
                    color: AppColor.white_color,
                  ),
                  text: "Share App with a friend"),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Divider(
                  color: const Color.fromARGB(42, 255, 255, 255),
                  height: 3,
                ),
              ),
              ProfileContainer(
                  icon: Icon(
                    Icons.file_copy,
                    color: AppColor.white_color,
                  ),
                  text: "Terms of Use"),
              ProfileContainer(
                  icon: Icon(
                    Icons.lock,
                    color: AppColor.white_color,
                  ),
                  text: "Privacy Policy"),
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
