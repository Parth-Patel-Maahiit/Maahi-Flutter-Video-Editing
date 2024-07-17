import 'package:flutter/material.dart';
import '../util/app_color.dart';

class ProfileField extends StatefulWidget {
  final String initialValue;
  final IconData? icon;
  final TextInputType? type;
  final TextEditingController controller;

  ProfileField({
    super.key,
    required this.controller,
    this.icon,
    required this.initialValue,
    this.type,
    required String label,
  });

  @override
  State<ProfileField> createState() => _ProfileFieldState();
}

class _ProfileFieldState extends State<ProfileField> {
  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.initialValue; // Set the initial value here
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          fillColor: AppColor.white_color,
          // labelText: widget.,
          labelStyle: TextStyle(color: AppColor.white_color),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: widget.type,
        style: TextStyle(color: AppColor.white_color),
        cursorColor: Colors.blue,
      ),
    );
  }
}
