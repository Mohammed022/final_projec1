import 'package:final_project1/account.dart';
import 'package:final_project1/admin.dart';
import 'package:final_project1/home.dart';
import 'package:final_project1/login.dart';
import 'package:final_project1/main.dart';
import 'package:final_project1/register.dart';
import 'package:flutter/material.dart';
import 'about_us.dart';


class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  String _uid = '';
  List<Widget> _children = [];

  NavigationProvider() {
    _updateChildren();
  }

  int get currentIndex => _currentIndex;
  List<Widget> get children => _children;

  void _updateChildren() {
    // Define pages based on the authentication state
    List<Widget> unauthenticatedPages = [
      //HomePage(),
      HomePage2(),
      LoginPage(),
      RegisterPage(),
      AboutUsPage(),

    ];
    List<Widget> authenticatedPages = [
      HomePage2(),
      AccountPage(),
      AboutUsPage(),
    ];
    List<Widget> adminPages = [
      HomePage2(),
      AdminPage(),

    ];

    // Update children based on the current user's role
    if (_uid.isNotEmpty && _uid == "VTqRiWImivXp0f2hFst9Jr8VhOk1") { // Replace with actual admin UID check
      _children = adminPages;
    } else if (_uid.isNotEmpty) {
      _children = authenticatedPages;
    } else {
      _children = unauthenticatedPages;
    }

    // Ensure the currentIndex is within the bounds of the new children list
    if (_currentIndex >= _children.length) {
      _currentIndex = 0; // Reset to the first page, typically the home page
    }
    notifyListeners();
  }
  // Check if the user is logged in by checking if the UID is not empty
  bool isUserLoggedIn() {
    return _uid.isNotEmpty;
  }

  // Check if the logged-in user is an admin
  // This is a simple check. Replace with your actual admin verification logic
  bool isUserAdmin() {
    return _uid == "VTqRiWImivXp0f2hFst9Jr8VhOk1";
  }

  void changePage(int index) {
    // Ensure the index is within the bounds of the children list
    if (index >= 0 && index < _children.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void setUid(String uid) {
    _uid = uid;
    _updateChildren(); // This method already calls notifyListeners
  }
}


