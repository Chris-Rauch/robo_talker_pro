import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<StatefulWidget> createState() => _AccountView();
}

class _AccountView extends State<AccountView> {
  final _roboUsernameController = TextEditingController();
  final _roboKeyController = TextEditingController();
  final _callerID = TextEditingController();
  final _teUsername = TextEditingController();
  final _tePword = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData('roboUsername').then((value) {
      _roboUsernameController.text = value ?? '';
    });
    loadData('roboKey').then((value) {
      _roboKeyController.text = value ?? '';
    });
    loadData('caller_id').then((value) {
      _callerID.text = value ?? '';
    });
    loadData('Third Eye Username').then((value) {
      _teUsername.text = value ?? '';
    });
    loadData('Third Eye Password').then((value) {
      _tePword.text = value ?? '';
    });
  }

  _save() {
    saveData('roboUsername', _roboUsernameController.text);
    saveData('roboKey', _roboKeyController.text);
    saveData('caller_id', _callerID.text);
    saveData('Third Eye Username', _teUsername.text);
    saveData('Third Eye Password', _tePword.text);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        //height: 100,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const Text(
              'Robo Talker',
              style: TextStyle(
                fontSize: 28.10,
              ),
            ),
            TextField(
              controller: _roboUsernameController,
              decoration: const InputDecoration(
                hintText: 'Username',
              ),
            ),
            TextField(
              controller: _roboKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Z Key',
              ),
            ),
            TextField(
              controller: _callerID,
              decoration: const InputDecoration(
                hintText: 'Caller ID',
              ),
            ),
            const Text(
              'Third Eye',
              style: TextStyle(
                fontSize: 28.10,
              ),
            ),
            TextField(
              controller: _teUsername,
              decoration: const InputDecoration(
                hintText: 'Username',
              ),
            ),
            TextField(
              controller: _tePword,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
            ),
            FloatingActionButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
