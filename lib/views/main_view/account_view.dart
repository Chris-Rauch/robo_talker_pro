import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  AccountViewState createState() => AccountViewState();
}

class AccountViewState extends State<AccountView> {
  final _roboUsernameController = TextEditingController();
  final _roboKeyController = TextEditingController();
  final _callerIdController = TextEditingController();
  final _teUsernameController = TextEditingController();
  final _tePwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData(Keys.roboUsername.toLocalizedString()).then((value) {
      _roboUsernameController.text = value ?? '';
    });
    loadData(Keys.zKey.toLocalizedString()).then((value) {
      _roboKeyController.text = value ?? '';
    });
    loadData(Keys.callerId.toLocalizedString()).then((value) {
      _callerIdController.text = value ?? '';
    });
    loadData(Keys.teUsername.toLocalizedString()).then((value) {
      _teUsernameController.text = value ?? '';
    });
    loadData(Keys.tePassword.toLocalizedString()).then((value) {
      _tePwordController.text = value ?? '';
    });
  }

  _save() {
    saveData(
        Keys.roboUsername.toLocalizedString(), _roboUsernameController.text);
    saveData(Keys.zKey.toLocalizedString(), _roboKeyController.text);
    saveData(Keys.callerId.toLocalizedString(), _callerIdController.text);
    saveData(Keys.teUsername.toLocalizedString(), _teUsernameController.text);
    saveData(Keys.tePassword.toLocalizedString(), _tePwordController.text);
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
              controller: _callerIdController,
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
              controller: _teUsernameController,
              decoration: const InputDecoration(
                hintText: 'Username',
              ),
            ),
            TextField(
              controller: _tePwordController,
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
