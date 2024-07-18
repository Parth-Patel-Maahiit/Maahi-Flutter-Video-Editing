import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:video_editing_app/API/commonapicall.dart';
import 'package:video_editing_app/UI/components/common.dart';
import '../../CommonMettods/common_sharedPreferences.dart';
import '../../Model/login_model.dart' as LoginModel;
import 'package:video_editing_app/widget/textform_widget.dart';

import '../../util/app_color.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  late TextEditingController oldpasswordController;
  late TextEditingController newpasswordController;
  late TextEditingController conformpasswordController;
  bool isloading = false;

  String id = "";
  String name = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    oldpasswordController = TextEditingController();
    newpasswordController = TextEditingController();
    conformpasswordController = TextEditingController();
    _getuserid();
  }

  Future<void> updatePassword(String i, String pass) async {
    var response = await CommonApiCall.getApiData(
        action:
            "action=update_profile_password&login_user_id=$i&new_password=$pass");

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData != null) {
      } else {
        scaffoldMessengerMessage(
            message: "Something went wrong, please try again!",
            context: context);
      }
    } else {}
  }

  Future<void> _getuserid() async {
    var loginDataDynamic = await getStoreApidata("loginData");

    if (loginDataDynamic != null && loginDataDynamic is Map<String, dynamic>) {
      LoginModel.LoginModel loginData =
          LoginModel.LoginModel.fromJson(loginDataDynamic);

      setState(() {
        id = loginData.data!.id!;
        name = loginData.data!.name!;
        print("Id ====>   $id");
        print("Name ====>   $name");
      });
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
            Field(Controller: oldpasswordController, lable: "old Password"),
            SizedBox(
              height: 30,
            ),
            Field(Controller: newpasswordController, lable: "new Password"),
            SizedBox(
              height: 30,
            ),
            Field(Controller: conformpasswordController, lable: "conform Password"),
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isloading
                        ? () {}
                        : () {
                            String password =
                                conformpasswordController.text.trim();

                            if (password.isNotEmpty) {
                              // getLoginData(email, password);
                              updatePassword(id, password);
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
                                  child: CircularProgressIndicator(
                                      color: AppColor.home_plus_color)),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                "Change Password",
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
                                BorderRadius.all(Radius.circular(25)))),
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
