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
  final _userIdController = TextEditingController();
  String? callUnits;

  @override
  void initState() {
    super.initState();
    loadData(Keys.roboUsername.name).then((value) {
      _roboUsernameController.text = value ?? '';
    });
    loadData(Keys.z_token.name).then((value) {
      _roboKeyController.text = value ?? '';
    });
    loadData(Keys.caller_id.name).then((value) {
      _callerIdController.text = value ?? '';
    });
    loadData(Keys.teUsername.toLocalizedString()).then((value) {
      _teUsernameController.text = value ?? '';
    });
    loadData(Keys.tePassword.toLocalizedString()).then((value) {
      _tePwordController.text = value ?? '';
    });
    loadData(Keys.userID.toLocalizedString()).then((value) {
      _userIdController.text = value ?? '';
    });
  }

  _save() {
    saveData(Keys.roboUsername.name, _roboUsernameController.text);
    saveData(Keys.z_token.name, _roboKeyController.text);
    saveData(Keys.caller_id.name, _callerIdController.text);
    saveData(Keys.teUsername.toLocalizedString(), _teUsernameController.text);
    saveData(Keys.tePassword.toLocalizedString(), _tePwordController.text);
    saveData(Keys.userID.toLocalizedString(), _userIdController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Robo Talker',
                    style: TextStyle(
                      fontSize: 28.10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _roboUsernameController,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _roboKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'API Key',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _callerIdController,
                    decoration: const InputDecoration(
                      hintText: 'Caller ID',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      hintText: 'User ID',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Text(
                        'Call Units:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        callUnits ?? '0',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: const Text('Buy more units'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      child: const Text('Change your voice message'),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Third Eye',
                    style: TextStyle(
                      fontSize: 28.10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _teUsernameController,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _tePwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    child: const Text('Change memo'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: _save,
                child: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(15),
        //decoration: BoxDecoration(
        //color: Colors.grey[200], // Background color for the container
        //borderRadius: BorderRadius.circular(10), // Rounded corners
        //),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Robo Talker',
                    style: TextStyle(
                      fontSize: 28.10,
                      fontWeight: FontWeight.bold, // Make the text bold
                      //color: Colors.blue, // Add color to the text
                    ),
                  ),
                  const SizedBox(height: 20), // Add space between elements
                  TextField(
                    controller: _roboUsernameController,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      filled: true,
                      fillColor:
                          Colors.white, // Background color for the TextField
                      border:
                          OutlineInputBorder(), // Add a border to the TextField
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _roboKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'API Key',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _callerIdController,
                    decoration: const InputDecoration(
                      hintText: 'Caller ID',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Call Units:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        callUnits ?? '0', // Display the dynamic value
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red, // Color for the call units text
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        /*
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button color
                        ),*/
                        child: const Text('Buy more units'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    /*
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color
                    ),*/
                    child: const Text('Change your voice message'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Third Eye',
                    style: TextStyle(
                      fontSize: 28.10,
                      fontWeight: FontWeight.bold,
                      //color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _teUsernameController,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _tePwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      //fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    /*
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Button color
                    ),*/
                    child: const Text('Change memo'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            FloatingActionButton(
              /*backgroundColor: Colors.red, */ // Floating button color
              onPressed: _save,
              child: const Icon(Icons.save), // Change text to save icon
            ),
          ],
        ),
      ),
    );
  } */
}
