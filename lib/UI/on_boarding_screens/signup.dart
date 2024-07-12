import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:video_editing_app/API/commonapicall.dart';
import 'package:video_editing_app/Model/signup_model.dart' as SignupModel;
import 'package:video_editing_app/UI/components/common.dart';
import 'package:video_editing_app/UI/on_boarding_screens/OnBoardingScreen.dart';
import 'package:video_editing_app/UI/on_boarding_screens/login.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/widget/textform_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignupModel.SignupModel? _signup = SignupModel.SignupModel();

  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController mobileController;

  bool isloading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    mobileController = TextEditingController();
  }

  Future<void> register(name, email, password, mobile) async {
    setState(() {
      isloading = true;
    });
    var response = await CommonApiCall.getApiData(
        action:
            "action=userRegister&name=$name&email_id=$email&password=$password&mobile=$mobile");
    if (response != null) {
      final responseData = json.decode(response.body);
      _signup = SignupModel.SignupModel.fromJson(responseData);

      if (_signup != null && _signup!.status == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
        scaffoldMessengerMessage(
          message: "${_signup!.message}",
          context: context,
        );
      } else {
        scaffoldMessengerMessage(
          message: _signup?.message ?? "Registration failed",
          context: context,
        );
      }
    } else {
      setState(() {
        isloading = false;
      });
      scaffoldMessengerMessage(
        message: "Failed to register. Please try again.",
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return OnBoardingScreen();
                },
              ), (route) => false);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            Field(
              Controller: nameController,
              lable: "Name",
              type: TextInputType.name,
            ),
            SizedBox(height: 20),
            Field(
              Controller: emailController,
              lable: "Email",
              type: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            Field(
              Controller: passwordController,
              lable: "Password",
              type: TextInputType.visiblePassword,
            ),
            SizedBox(height: 20),
            Field(
              Controller: mobileController,
              lable: "mobile",
              type: TextInputType.number,
            ),

            SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isloading
                        ? () {}
                        : () {
                            String email = emailController.text.trim();
                            String password = passwordController.text.trim();
                            String name = nameController.text;

                            if (email.isNotEmpty && password.isNotEmpty) {
                              register(name, email, password, password);
                            } else {
                              scaffoldMessengerMessage(
                                  message: "Enter valid email and password",
                                  context: context);
                            }
                          },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: isloading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Text(
                              "Create Account",
                              style: TextStyle(
                                  color: AppColor.black_color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.white_color,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}
