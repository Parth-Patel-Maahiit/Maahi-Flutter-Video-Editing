import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:video_editing_app/UI/components/common_save_button.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/widget/update_profile_form.dart';

import '../../API/commonapicall.dart';
import '../../CommonMettods/common_sharedPreferences.dart';
import '../../Model/login_model.dart' as LoginModel;
import '../../util/app_images.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  // LoginModel.LoginModel? _login = LoginModel.LoginModel();
  String name = '';
  String email = '';
  String mobile = '';
  String id = '';
  String password = '';
  late TextEditingController nameController;
  late TextEditingController mobileController;
  //late TextEditingController emailController
  //
  List<String> selectedVideos = [];
  List<String> selectedPlatforms = [];
  List<String> heardAbout = [];

  String select_video = "";
  String select_plat = "";
  String about = "";
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    mobileController = TextEditingController();
    _getusername();
    // _loadPreferences();
  }

  // Future<void> _loadPreferences() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     selectedVideos = prefs.getStringList('video_about_category') ?? [];
  //     selectedPlatforms = prefs.getStringList('video_share_category') ?? [];
  //     heardAbout = prefs.getStringList('video_hear_category') ?? [];

  //     print("selectedVideos == >> $selectedVideos");
  //     print("selectedPlatforms == >> $selectedPlatforms");
  //     print("heardAbout == >> $heardAbout");

  //     select_video = selectedVideos.join(",");
  //     select_plat = selectedPlatforms.join(",");
  //     about = heardAbout.join(",");

  //     print("selected ===> $select_video");
  //   });
  // }

  // Future<void> getLoginData(email, password) async {
  //   var response = await CommonApiCall.getApiData(
  //       action:
  //           "action=userlogin&email_id=$email&password=$password&video_about_category=$select_video&video_share_category=$select_plat&video_hear_category=$about");
  //   if (response.statusCode == 200) {
  //     final responseData = json.decode(response.body);
  //     _login = LoginModel.LoginModel.fromJson(responseData);

  //     if (_login != null && _login!.status == true) {
  //       setStoreApidata("loginData", _login);
  //       scaffoldMessengerMessage(
  //           message: "${_login!.message}", context: context);
  //     } else {
  //       scaffoldMessengerMessage(
  //           message: "${_login!.message}", context: context);
  //     }
  //   } else {
  //     print('error ==>  ${response.message}');
  //   }
  // }

  Future<void> updateData(
      String i, String n, String m, String e, String pass) async {
    var response = await CommonApiCall.getApiData(
        action: "action=update_profile&login_user_id=$i&name=$n&mobile=$m");

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData != null) {
        Navigator.pop(context);
      }
      // getLoginData(e, pass);
    } else {}
  }

  Future<void> _getusername() async {
    var loginDataDynamic = await getStoreApidata("loginData");

    if (loginDataDynamic != null && loginDataDynamic is Map<String, dynamic>) {
      LoginModel.LoginModel loginData =
          LoginModel.LoginModel.fromJson(loginDataDynamic);

      setState(() {
        name = loginData.data?.name ?? 'Guest';
        email = loginData.data!.emailId!;
        mobile = loginData.data!.mobile!;
        id = loginData.data!.id!;
        password = loginData.data!.password!;
        print("Name ====>   $name");

        nameController.text = name;
        mobileController.text = mobile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          CommonSaveButton(
            onTap: () {
              updateData(id, nameController.text, mobileController.text, email,
                  password);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: AppColor.grey_color),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ImageIcon(
                      AssetImage(AppImages.user),
                      color: const Color.fromARGB(255, 21, 21, 21),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          TextStyle(color: AppColor.white_color, fontSize: 20),
                    ),
                    Text(
                      email,
                      style:
                          TextStyle(color: AppColor.white_color, fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            ProfileField(
              controller: nameController,
              label: "name",
              initialValue: name,
            ),
            ProfileField(
              controller: mobileController,
              label: "mobile",
              initialValue: mobile,
            ),
          ],
        ),
      ),
    );
  }
}
