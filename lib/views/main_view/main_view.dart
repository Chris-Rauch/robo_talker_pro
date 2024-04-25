import 'package:flutter/material.dart';
import 'package:robo_talker_pro/views/main_view/account_view.dart';
import 'package:robo_talker_pro/views/main_view/no_call_agreement_view.dart';
import 'package:robo_talker_pro/views/main_view/project_view.dart';
import 'package:robo_talker_pro/views/main_view/settings_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
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
            label: 'Accounts',
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
        return AccountView();
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
