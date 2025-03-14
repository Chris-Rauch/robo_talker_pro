import 'package:flutter/material.dart';
import 'package:robo_talker_pro/views/account_views/account_view.dart';
import 'package:robo_talker_pro/views/no_call_agreement/no_call_agreement_view.dart';
import 'package:robo_talker_pro/views/project_views/project_view.dart';
import 'package:robo_talker_pro/views/settings/settings_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  MainViewState createState() => MainViewState();
}

class MainViewState extends State<MainView> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.blue,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_open),
            label: 'NCA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const ProjectView();
      case 1:
        return const AccountView();
      case 2:
        return const NoCallAgreementView();
      case 3:
        return const SettingsView();
      default:
        return Container(); // Placeholder, replace with appropriate view
    }
  }
}


// Define other view classes similarly
