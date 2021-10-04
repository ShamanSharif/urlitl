import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urlitl/model/auth.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset("assets/images/1.png"),
            MaterialButton(
              onPressed: () async {
                bool status = await Provider.of<Auth>(context, listen: false)
                    .signInWithGoogle();
                if (status == true) {
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) {
                    return const HomeScreen();
                  }), (route) => false);
                }
              },
              child: MaterialButton(
                color: const Color(0xFF3F51B5),
                textColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                onPressed: () async {
                  bool status = await Provider.of<Auth>(context, listen: false)
                      .signInWithGoogle();
                  if (status) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                        (route) => false);
                  }
                },
                child: const Text("Sign in with Google"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
