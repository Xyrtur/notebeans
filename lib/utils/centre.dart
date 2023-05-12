import 'package:flutter/material.dart';

class Centre {
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double screenWidth;
  static late double screenHeight;

  static Color darkerShadowColor = const Color(0xFF505f5e);
  static Color lighterShadowColor = const Color(0xFF6c8180);
  static Color tileBgColor = const Color(0xFF5E706F);
  // static Color bgColor = const Color.fromARGB(255, 45, 45, 45);
  // static Color lighterTileColor = const Color.fromARGB(255, 185, 141, 166);
  static Color accentColor = const Color(0xFFE3DC95);
  static Color linkColor = const Color(0xFFD0BCD5);
  // static Color textColor = const Color.fromARGB(255, 250, 250, 253);
  static Color textColor = const Color.fromARGB(255, 230, 227, 217);
  static Color toolTextColor = const Color(0xFFE3E7D3);

  static final titleNoteText = TextStyle(
    color: Centre.textColor,
    fontSize: Centre.safeBlockHorizontal * 5.5,
    fontWeight: FontWeight.w400,
    fontFamily: 'RobotoMono',
  );

  static final dialogTitleText = TextStyle(
    color: Centre.textColor,
    fontSize: Centre.safeBlockHorizontal * 4.5,
    fontWeight: FontWeight.w400,
    fontFamily: 'RobotoMono',
  );

  static final titleNoteTileText = TextStyle(
    color: Centre.textColor,
    fontSize: Centre.safeBlockHorizontal * 4,
    fontWeight: FontWeight.w400,
    fontFamily: 'RobotoMono',
  );

  static final noteText = TextStyle(
    color: Centre.textColor,
    fontSize: Centre.safeBlockHorizontal * 3.8,
    fontWeight: FontWeight.w400,
    fontFamily: 'RobotoMono',
  );

  void init(BuildContext buildContext) {
    MediaQueryData mediaQueryData;
    double safeAreaHorizontal;
    double safeAreaVertical;
    mediaQueryData = MediaQuery.of(buildContext);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;

    safeAreaHorizontal =
        mediaQueryData.padding.left + mediaQueryData.padding.right;
    safeAreaVertical =
        mediaQueryData.padding.top + mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }
}
