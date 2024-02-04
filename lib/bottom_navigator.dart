import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_provider.dart';


class BottomNavigatorBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: provider.children[provider.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: provider.currentIndex,
            onTap: (index) {
              provider.changePage(index);
            },
            type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.login),
                label: 'Login',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.app_registration),
                label: 'Registration',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: 'Admin',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Account',
              ),
            ],
          ),
        );
      },
    );
  }
}
