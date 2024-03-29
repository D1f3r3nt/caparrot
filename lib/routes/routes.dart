import 'package:caparrot/pages/caparrot_head_page.dart';
import 'package:caparrot/pages/pages.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> getRoutes = {
  '/': (context) => Gateway(),
  'home': (context) => HomePage(),
  'library': (context) => LibraryPage(),
  'heads': (context) => HeadPage(),
  'login': (context) => LoginPage(),
  'profile': (context) => ProfileScreen(),
  'register': (context) => RegisterPage(),
  'new_password': (context) => NewPassword(),
  'settings': (context) => SettingsPage(),
  'location_permission': (context) => RequestPermissionPage(),
  'tutorial': (context) => TutorialScreens(),
  'tresD': (context) => CapaHeadPage(),
};
