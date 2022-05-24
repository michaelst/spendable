import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _signInWithApple();
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
                    child: Text('Sign in'),
                  ),
                ),
              )
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _signInWithApple();
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
                  child: Text('Sign in'),
                ),
              ),
            )
          ],
        ),
      ]),
    );
  }
}

Future<UserCredential> _signInWithApple() async {
  final provider = OAuthProvider("apple.com");

  return await FirebaseAuth.instance.signInWithPopup(provider);
}
