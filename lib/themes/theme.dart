import 'package:flutter/material.dart';
import 'package:video_editing_app/util/app_color.dart';

ThemeData def = ThemeData(
    useMaterial3: true,
    fontFamily: "Nunito",
    elevatedButtonTheme: ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(backgroundColor: AppColor.elevated_bg_color),
    ),
    colorScheme: ColorScheme.dark(background: AppColor.bg_color),
    appBarTheme: AppBarTheme(backgroundColor: AppColor.bg_color),
    
    
    );

