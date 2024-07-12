import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:video_editing_app/API/commonapicall.dart';
import 'package:video_editing_app/Model/login_model.dart' as LoginModel;
import 'package:video_editing_app/UI/Projects.dart';
import 'package:video_editing_app/UI/components/common.dart';
import 'package:video_editing_app/UI/on_boarding_screens/signup.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/widget/textform_widget.dart';

import '../../CommonMettods/common_sharedPreferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginModel.LoginModel? _login = LoginModel.LoginModel();

  late TextEditingController emailController;
  late TextEditingController passwordController;

  bool isloading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  Future<void> getLoginData(email, password) async {
    setState(() {
      isloading = true;
    });
    var response = await CommonApiCall.getApiData(
        action: "action=userlogin&email_id=$email&password=$password");
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      _login = LoginModel.LoginModel.fromJson(responseData);

      if (_login != null && _login!.status == true) {
        setStoreApidata("loginData", _login);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectsScreen(),
            ),
            (route) => false);
        scaffoldMessengerMessage(
            message: "${_login!.message}", context: context);
      } else {
        scaffoldMessengerMessage(
            message: "${_login!.message}", context: context);
        setState(() {
          isloading = false;
        });
      }
    } else {
      print('error ==>  ${response.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                Field(Controller: emailController, lable: "Email"),
                SizedBox(height: 20),
                Field(
                  Controller: passwordController,
                  lable: 'Password',
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isloading
                            ? () {}
                            : () {
                                String email = emailController.text.trim();
                                String password =
                                    passwordController.text.trim();

                                if (email.isNotEmpty && password.isNotEmpty) {
                                  getLoginData(email, password);
                                } else {
                                  scaffoldMessengerMessage(
                                      message: "Enter valid email and password",
                                      context: context);
                                }
                              },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: isloading
                              ? Center(
                                  child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(color: AppColor.home_plus_color)),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(vertical: 3),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                        color: AppColor.black_color,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
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
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: () {}, icon: Icon(Icons.face)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.ac_unit)),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New to app? ",
                      style:
                          TextStyle(color: AppColor.white_color, fontSize: 20),
                    ),
                    InkWell(
                       splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
                      child: Text(
                        "Create an account",
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ));
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
