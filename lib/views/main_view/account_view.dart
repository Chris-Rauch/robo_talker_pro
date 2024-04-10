import 'package:flutter/material.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        //height: 100,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(15),
        child: const Column(
          children: [
            Text(
              'Robo Talker',
              style: TextStyle(
                fontSize: 28.10,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Username",
                labelText: "Username",
              ),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Key",
                labelText: "Key",
              ),
            ),
            Text(
              'Third Eye',
              style: TextStyle(
                fontSize: 28.10,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter Username Here",
                labelText: "Username",
              ),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter Password Here",
                labelText: "Password",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
