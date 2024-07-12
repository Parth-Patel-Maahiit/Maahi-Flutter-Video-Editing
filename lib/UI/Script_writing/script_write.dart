import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:video_editing_app/API/commonapicall.dart';
import 'package:video_editing_app/CommonMettods/common_sharedPreferences.dart';
import 'package:video_editing_app/UI/Recording/record_with_script_screen.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/Model/login_model.dart';

class ScriptWrite extends StatefulWidget {
  const ScriptWrite({super.key});

  @override
  State<ScriptWrite> createState() => _ScriptWriteState();
}

class _ScriptWriteState extends State<ScriptWrite> {
  final _titleController = TextEditingController();
  final _scriptController = TextEditingController();
  // LoginModel.LoginModel? _login = LoginModel.LoginModel();
  LoginModel? _login = LoginModel();

  void dispose() {
    _titleController.dispose();
    _scriptController.dispose();
    super.dispose();
  }

  Future<String> AddSript(String title, String script) async {
    var loginData = await getStoreApidata("loginData");
    if (loginData != null) {
      _login = LoginModel.fromJson(loginData);
    }

    print(_login!.data);

    if (_login != null && _login!.data?.id != null) {
      var response = await CommonApiCall.getApiData(
          action:
              "action=add_script&user_id=${_login!.data?.id}&title=$title&script_text=$script");

      if (response != null) {
        final responseData = json.decode(response.body);
        print(_login?.data);
        print("id of the script is === >>>${responseData["data"]}");

        if (responseData['status'] == 'success') {
          print("Script added successfully");
        } else {
          print("Failed to add script: ${responseData['message']}");
        }
        return responseData["data"];
      } else {
        print('Error: Response is null');
        return "";
      }
    } else {
      print('Error: User is not logged in');
      return "";
    }
  }

  void _saveScript() {
    final title = _titleController.text;
    final script = _scriptController.text;

    if (title.isNotEmpty && script.isNotEmpty) {
      //AddSript(title, script);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecordWithScriptScreen(
            title: title,
            script: script,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('script saved'),
        ),
      );
    } else {
      // Show an alert or a snackbar for empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill out all fields'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_outlined)),
        title: Text(
          'New Script',
          style: TextStyle(color: AppColor.white_color),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text("Save", style: TextStyle(color: AppColor.white_color)),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(color: AppColor.white_color),
                controller: _titleController,
                decoration: InputDecoration(
                    hintText: "Your Project title",
                    hintStyle:
                        TextStyle(fontSize: 24, color: AppColor.grey_color)),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                child: Expanded(
                  child: TextField(
                    style: TextStyle(color: AppColor.white_color),
                    controller: _scriptController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                        hintText: "Write your script here...",
                        border: null,
                        hintStyle: TextStyle(color: AppColor.white_color)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.home_plus_color,
                      elevation: 5,
                      shape: CircleBorder()),
                  onPressed: _saveScript,
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Icon(
                      Icons.video_camera_front_sharp,
                      size: 40,
                      color: AppColor.white_color,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
