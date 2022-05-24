import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSignedIn = false;

  void _changeAuthState(isSignedIn) {
    setState(() {
      _isSignedIn = isSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _changeAuthState(false);
      } else {
        _changeAuthState(true);
      }
    });

    if (_isSignedIn) {
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
    } else {
      return const LoginPage();
    }
  }
}
