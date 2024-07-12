import 'package:flutter/material.dart';
import 'package:video_editing_app/util/app_color.dart';

// ignore: must_be_immutable
class Field extends StatefulWidget {
  late String lable;
  late IconData? icon;
  late TextInputType? type;
  final TextEditingController Controller;
  Field({
    super.key,
    required this.Controller,
    required this.lable,
    this.icon,
    this.type,
  });

  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.Controller,
      decoration: InputDecoration(
        fillColor: AppColor.white_color,
        labelText: widget.lable,
        labelStyle: TextStyle(color: AppColor.white_color),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10)),
        suffixIcon: widget.lable.toLowerCase() == 'password'
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColor.white_color,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : (widget.icon != null
                ? Icon(
                    widget.icon,
                    color: AppColor.white_color,
                  )
                : null),
      ),
      keyboardType: widget.type,
      obscureText:
          widget.lable.toLowerCase() == 'password' && !_isPasswordVisible,
      style: TextStyle(color: AppColor.white_color),
      cursorColor: Colors.blue,
    );
  }
}
