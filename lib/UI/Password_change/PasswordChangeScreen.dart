import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_editing_app/API/commonapicall.dart';
import 'package:video_editing_app/CommonMettods/common_sharedPreferences.dart';
import 'package:video_editing_app/UI/components/common.dart';
import '../../Model/login_model.dart' as LoginModel;
import 'package:video_editing_app/widget/textform_widget.dart';
import '../../util/app_color.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({Key? key}) : super(key: key);

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  LoginModel.LoginModel? _login;
  bool isLoading = false;

  String id = "";
  String password = "";
  String email = "";

  List<String> selectedVideos = [];
  List<String> selectedPlatforms = [];
  List<String> heardAbout = [];

  String select_video = "";
  String select_plat = "";
  String about = "";

  @override
  void initState() {
    super.initState();
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    _getUserIdPassword();
    _loadPreferences();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> getLoginData(String email, String password) async {
    var response = await CommonApiCall.getApiData(
        action:
            "action=userlogin&email_id=$email&password=$password&video_about_category=$select_video&video_share_category=$select_plat&video_hear_category=$about");
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      _login = LoginModel.LoginModel.fromJson(responseData);
      _hideLoadingDialog();
      if (_login != null && _login!.status == true) {
        await setStoreApidata("loginData", _login);
        //Navigator.pop(context); // Navigate back or to the desired screen
      }
    } else {
      print('error ==>  ${response.message}');
    }
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedVideos = prefs.getStringList('video_about_category') ?? [];
      selectedPlatforms = prefs.getStringList('video_share_category') ?? [];
      heardAbout = prefs.getStringList('video_hear_category') ?? [];

      print("selectedVideos == >> $selectedVideos");
      print("selectedPlatforms == >> $selectedPlatforms");
      print("heardAbout == >> $heardAbout");

      select_video = selectedVideos.join(",");
      select_plat = selectedPlatforms.join(",");
      about = heardAbout.join(",");

      print("selected ===> $select_video");
    });
  }

  Future<void> _getUserIdPassword() async {
    var loginDataDynamic = await getStoreApidata("loginData");

    if (loginDataDynamic != null && loginDataDynamic is Map<String, dynamic>) {
      LoginModel.LoginModel loginData =
          LoginModel.LoginModel.fromJson(loginDataDynamic);

      setState(() {
        id = loginData.data!.id!;
        password = loginData.data!.passwordTxt!;
        email = loginData.data!.emailId!;
        print("Password: $password");
      });
    }
  }

  Future<void> _hideLoadingDialog() async {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> updatePassword(
    String userId,
    String oldPass,
    String newPass,
    String confirmPass,
  ) async {
    setState(() {
      isLoading = true;
    });

    // Check if the old password matches the stored password
    if (oldPass != password) {
      setState(() {
        isLoading = false;
      });
      scaffoldMessengerMessage(
        message: "Old password is incorrect!",
        context: context,
      );
      return;
    }

    // Check if the new password and confirm password match
    if (newPass != confirmPass) {
      setState(() {
        isLoading = false;
      });
      scaffoldMessengerMessage(
        message: "New password and confirm password do not match!",
        context: context,
      );
      return;
    }

    // Make API call to update the password
    var response = await CommonApiCall.getApiData(
      action:
          "action=update_profile_password&login_user_id=$userId&new_password=$confirmPass",
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData != null && responseData['status'] == "success") {
        scaffoldMessengerMessage(
          message: "Password updated successfully!",
          context: context,
        );
        // Assuming you have the email and password stored in _login
        getLoginData(email, confirmPass);
      } else {
        scaffoldMessengerMessage(
          message: responseData['message'] ??
              "Something went wrong, please try again!",
          context: context,
        );
      }
    } else {
      scaffoldMessengerMessage(
        message: "Something went wrong, please try again!",
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Field(
              Controller: oldPasswordController,
              lable: "Old Password",
            ),
            SizedBox(height: 30),
            Field(Controller: newPasswordController, lable: "New Password"),
            SizedBox(height: 30),
            Field(
                Controller: confirmPasswordController,
                lable: "Confirm Password"),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            String oldPassword =
                                oldPasswordController.text.trim();
                            String newPassword =
                                newPasswordController.text.trim();
                            String confirmPassword =
                                confirmPasswordController.text.trim();

                            if (newPassword != confirmPassword) {
                              scaffoldMessengerMessage(
                                message:
                                    "New Password and Confirm Password do not match!",
                                context: context,
                              );
                              return;
                            }

                            if (newPassword.isEmpty ||
                                confirmPassword.isEmpty ||
                                oldPassword.isEmpty) {
                              scaffoldMessengerMessage(
                                message: "Please fill in all fields!",
                                context: context,
                              );
                              return;
                            }

                            updatePassword(
                                id, oldPassword, newPassword, confirmPassword);
                          },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: isLoading
                          ? Center(
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                    color: AppColor.home_plus_color),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                "Change Password",
                                style: TextStyle(
                                  color: AppColor.black_color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.white_color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
