import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';

class AccountView extends StatefulWidget {
  AccountView({super.key});

  @override
  State<StatefulWidget> createState() => _AccountView();
}

class _AccountView extends State<AccountView> {

  String? roboUsername;
  String? roboKey;
  String? teUsername;
  String? tePword;

  @override 
  void initState() {
    super.initState();
    /*
    roboUsername = loadData('roboUsername');
    roboKey = loadData('roboKey');
    teUsername = loadData('Third Eye Username');
    tePword = loadData('Third Eye Password');
    */
  }

  _save() {
    if (roboUsername != null) {
      saveData('roboUsername', roboUsername!);
    }
    if (roboKey != null) {
      saveData('roboKey', roboKey!);
    }
    if (teUsername != null) {
      saveData('Third Eye Username', teUsername!);
    }
    if (tePword != null) {
      saveData('Third Eye Password', tePword!);
    }
    
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
              onChanged: (value) {
                setState(() {
                  roboUsername = value;
                  print('set state');
                });
              },
              decoration: InputDecoration(
                hintText: roboUsername ?? 'Username',
                //labelText: roboUsername ?? 'Username',
              ),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  roboKey = value;
                });
              },
              obscureText: true,
              decoration: InputDecoration(
                hintText: roboKey ?? 'Z Key',
                //labelText: roboKey,
              ),
            ),
            const Text(
              'Third Eye',
              style: TextStyle(
                fontSize: 28.10,
              ),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  teUsername = value;
                });
              },
              decoration: InputDecoration(
                hintText: teUsername ?? 'Username',
                //labelText: teUsername,
              ),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  tePword = value;
                });
              },
              obscureText: true,
              decoration: InputDecoration(
                hintText: tePword ?? 'Password',
                //labelText: tePword,
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
