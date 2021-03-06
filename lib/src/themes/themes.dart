import 'package:flutter/material.dart';
import 'package:dvx_flutter/src/google_fonts/google_font_library.dart';

import 'package:dvx_flutter/src/themes/color_params.dart';
import 'package:dvx_flutter/src/themes/editor/theme_set.dart';
import 'package:dvx_flutter/src/themes/editor/theme_set_manager.dart';
import 'package:dvx_flutter/src/utils/utils.dart';

class AppTheme {
  AppTheme({
    this.darkMode,
    this.integratedAppBar,
    this.transparentAppBar,
    this.googleFont,
  });

  bool? integratedAppBar;
  bool? darkMode;
  bool? transparentAppBar;
  String? googleFont;

  ThemeData get theme {
    ColorParams params;

    params = ColorParams(
        integratedAppBar: integratedAppBar,
        transparentAppBar: transparentAppBar);

    final Color? appColor = params.appColor;

    final sliderTheme = SliderThemeData(
      activeTrackColor: appColor,
      disabledActiveTrackColor: appColor,
      disabledInactiveTrackColor: appColor,
      disabledThumbColor: appColor,
      inactiveTrackColor: appColor,
      thumbColor: appColor,
    );

    const floatingActionButtonTheme = FloatingActionButtonThemeData(
      // white on floatingAction button
      foregroundColor: Colors.white,
    );

    final iconTheme =
        IconThemeData(color: ThemeSetManager().currentTheme!.textColor);

    final popupMenuTheme = PopupMenuThemeData(
      color: ThemeSetManager().currentTheme!.backgroundColor,
    );

    final baseTheme = ThemeData(
      visualDensity: Utils.isWeb
          ? const VisualDensity(horizontal: 3, vertical: 3)
          : VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: ThemeSetManager().currentTheme!.backgroundColor,
      popupMenuTheme: popupMenuTheme,
      primaryColorBrightness: Brightness.dark,
      bottomAppBarTheme: _bottomBarTheme(darkMode!),
      bottomNavigationBarTheme: _bottomNavBarTheme(appColor),
      textTheme: _textTheme(darkMode!),
      iconTheme: iconTheme,

      accentColor: params.accentColor,
      dividerColor: darkMode!
          ? Colors.white12
          : const Color.fromRGBO(
              0, 0, 0, .05), // params.accentColor.withOpacity(.5),
      primaryColor: appColor,
      primaryColorLight: appColor, // circle avatar uses these light/dark
      primaryColorDark: appColor,
      toggleableActiveColor: appColor,
      dialogBackgroundColor: ThemeSetManager().currentTheme!.backgroundColor,
      sliderTheme: sliderTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      colorScheme: _colorScheme(
        darkMode: darkMode!,
        primary: appColor,
        secondary: params.accentColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: ThemeSetManager().currentTheme!.textAccentColor!),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
              color: ThemeSetManager().currentTheme!.textAccentColor!),
        ),
        hintStyle:
            TextStyle(color: ThemeSetManager().currentTheme!.textAccentColor),
        labelStyle:
            TextStyle(color: ThemeSetManager().currentTheme!.textAccentColor),
        helperStyle:
            TextStyle(color: ThemeSetManager().currentTheme!.textAccentColor),
      ),
    );

    if (darkMode!) {
      return baseTheme.copyWith(
        brightness: Brightness.dark,
        accentColorBrightness: Brightness.dark,
        appBarTheme: _appBarTheme(true, params),
        buttonTheme: _buttonTheme(true),
        textButtonTheme: _textButtonTheme(true),
        elevatedButtonTheme: _elevatedButtonTheme(true),
        cardTheme: const CardTheme(
          color: Color.fromRGBO(255, 255, 255, .05),
          elevation: 0,
        ),
      );
    }
    return baseTheme.copyWith(
      brightness: Brightness.light,
      accentColorBrightness: Brightness.light,
      appBarTheme: _appBarTheme(params.darkModeAppBarText, params),
      buttonTheme: _buttonTheme(params.darkModeForButtonText),
      textButtonTheme: _textButtonTheme(params.darkModeForButtonText),
      elevatedButtonTheme: _elevatedButtonTheme(params.darkModeForButtonText),
      cardTheme: const CardTheme(
        color: Color.fromRGBO(0, 0, 0, .05),
        elevation: 0,
      ),
    );
  }

  // change the global font here
  TextTheme _fontChange(TextTheme theme) {
    // don't do it if Roboto or blank
    if (Utils.isEmpty(googleFont) ||
        googleFont == ThemeSetManager.defaultFont) {
      return theme;
    }

    return themeWithGoogleFont(googleFont, theme);
  }

  TextTheme _textTheme(bool darkMode) {
    Color? textColor = Colors.black;

    if (darkMode) {
      textColor = Colors.white;
    }

    Color? subtitleColor = Utils.darken(textColor);
    Color? headerTextColor = Colors.grey;
    Color? buttonContentColor = Colors.white;

    final ThemeSet? themeSet = ThemeSetManager().currentTheme;

    if (themeSet != null) {
      textColor = themeSet.textColor;
      subtitleColor = themeSet.textAccentColor;
      headerTextColor = themeSet.headerTextColor;
      buttonContentColor = themeSet.buttonContentColor;
    }

    TextTheme startTheme = ThemeData.light().textTheme;

    if (darkMode) {
      startTheme = ThemeData.dark().textTheme;
    }

    final result = startTheme.copyWith(
      button: TextStyle(
        color: buttonContentColor,
      ),

      // used for ListTile title in drawer
      bodyText1: startTheme.bodyText1!.copyWith(
        fontSize: 17.0,
        color: textColor,
      ),

      // used for ListTile subtitle in non-drawer list
      bodyText2: startTheme.bodyText2!.copyWith(
        color: textColor,
        fontSize: 16.0,
      ),

      // used for control text
      subtitle1: startTheme.bodyText1!.copyWith(
        fontSize: 16.0,
        color: textColor,
      ),

      // used for header title
      headline4: TextStyle(
        color: headerTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 17.0,
      ),

      // Google fonts list and others
      headline6: startTheme.headline6!.copyWith(
        color: textColor,
      ),

      // used for listTile subtitle
      caption: startTheme.bodyText1!.copyWith(
        fontSize: 15.0,
        color: subtitleColor,
      ),
    );

    return _fontChange(result);
  }

  TextTheme _appBarTextTheme(bool darkMode, ColorParams params) {
    final result = _textTheme(darkMode).copyWith(
      headline6: TextStyle(
        color: params.getBarTextColor(darkMode: darkMode),
        fontSize: 18,
        // fontWeight: FontWeight.bold,
      ),
    );

    return _fontChange(result);
  }

  ButtonThemeData _buttonTheme(bool darkMode) {
    ButtonThemeData startTheme = ThemeData.light().buttonTheme;
    if (darkMode) {
      startTheme = ThemeData.dark().buttonTheme;
    }

    final result = startTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return result;
  }

  ColorScheme _colorScheme(
      {required bool darkMode, Color? primary, Color? secondary}) {
    ColorScheme scheme = ThemeData.light().colorScheme;
    if (darkMode) {
      scheme = ThemeData.dark().colorScheme;
    }

    Color? buttonContentColor;
    final ThemeSet? themeSet = ThemeSetManager().currentTheme;
    if (themeSet != null) {
      buttonContentColor = themeSet.buttonContentColor;
    }

    final result = scheme.copyWith(
      primary: primary,
      secondary: secondary,
      onPrimary: buttonContentColor,
      brightness: darkMode ? Brightness.dark : Brightness.light,
    );

    return result;
  }

  ElevatedButtonThemeData _elevatedButtonTheme(bool darkMode) {
    ElevatedButtonThemeData startTheme = ThemeData.light().elevatedButtonTheme;
    if (darkMode) {
      startTheme = ThemeData.dark().elevatedButtonTheme;
    }

    return ElevatedButtonThemeData(style: startTheme.style);
  }

  TextButtonThemeData _textButtonTheme(bool darkMode) {
    TextButtonThemeData startTheme = ThemeData.light().textButtonTheme;
    if (darkMode) {
      startTheme = ThemeData.dark().textButtonTheme;
    }

    return TextButtonThemeData(style: startTheme.style);
  }

  AppBarTheme _appBarTheme(bool darkMode, ColorParams params) {
    return AppBarTheme(
      color: darkMode ? params.barColorDark : params.barColor,
      elevation: params.barElevation,
      iconTheme:
          IconThemeData(color: params.getBarTextColor(darkMode: darkMode)),
      actionsIconTheme: IconThemeData(
        color: params.getBarTextColor(darkMode: darkMode),
      ),
      textTheme: _appBarTextTheme(darkMode, params),
      brightness: darkMode ? Brightness.dark : Brightness.light,
    );
  }

  BottomAppBarTheme _bottomBarTheme(bool darkMode) {
    return BottomAppBarTheme(
      color: darkMode ? Colors.white : Colors.black,
    );
  }

  BottomNavigationBarThemeData _bottomNavBarTheme(Color? itemColor) {
    return BottomNavigationBarThemeData(
      selectedItemColor: itemColor,
      unselectedItemColor: itemColor,
      elevation: 8,
      backgroundColor: ThemeSetManager().currentTheme!.backgroundColor,
    );
  }
}
