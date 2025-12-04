import 'package:flutter/material.dart';
import 'package:jarpay/constants/colors.dart';


class AppFontWeight {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class AppTextStyles {

  static const TextStyle heading14black = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: AppFontWeight.semiBold, 
  fontSize: 14,
  height: 1.0, 
  letterSpacing: 0.0,
  color: Colors.black,
);

  static const TextStyle label = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: AppFontWeight.medium,
    fontSize: 14,
    color: AppColors.neutralLightGrey,
  );

  static const TextStyle header = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: AppFontWeight.medium,
    fontSize: 16,
    height: 1.0,
    letterSpacing: 0.0,
    color: AppColors.black,
  );

  static const TextStyle heading28 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: AppFontWeight.semiBold,
    fontSize: 28,
    height: 1.0,
    letterSpacing: 0.0,
    color: AppColors.appColor,
  );

  static const TextStyle detail16 = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: AppFontWeight.medium, 
  fontSize: 16,
  height: 1.0, 
  letterSpacing: 0.0,
  color: AppColors.neutralLightGrey,
);

static const TextStyle step1 = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: AppFontWeight.semiBold, 
  fontSize: 14,
  height: 1.2, 
  letterSpacing: 0.0,
  color: AppColors.neutraldarkGrey,
);

static const TextStyle smallText11 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: AppFontWeight.semiBold,
    fontSize: 11, 
    height: 1.0,
    letterSpacing: 0.0,
    color: Colors.black,
  );

  static const TextStyle smallText11Purple = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: AppFontWeight.semiBold,
    fontSize: 11,
    height: 1.0,
    letterSpacing: 0.0,
    color:AppColors.appColor,
  );

  static const TextStyle heading20White = TextStyle(
  fontFamily: 'Poppins',
  fontWeight:AppFontWeight.medium, 
  fontSize: 20,
  height: 1.0,
  letterSpacing: 0.0,
  color: AppColors.white,
);
 static const TextStyle heading20 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: AppFontWeight.semiBold,
    fontSize: 20,
    color: AppColors.appColor,
  );
   static const TextStyle heading14appcolor = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: AppFontWeight.semiBold, 
  fontSize: 14,
  color: AppColors.appColor,
);


  static const TextStyle settingText16 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: AppFontWeight.medium,
    fontSize: 16,
    height: 1.0,
    letterSpacing: 0.0,
    color: AppColors.black,
  );



}
