import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Routes extends StatelessWidget {
  const Routes({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _signOut();
              },
              child: Container(
                height: 50.0,
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.lightGreen[500],
                ),
                child: const Center(
                  child: Text('Logout'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();
}
