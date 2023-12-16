import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ink_tale_version1/Screens/home/home_page.dart';

import '../navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    navigateToScreen();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_1.jpg',height: 400,width: 400,),
            const SizedBox(height: 5,),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void navigateToScreen() async {
    await Future.delayed(Duration(seconds: 6));

    User? user = FirebaseAuth.instance.currentUser;

    // Here, always navigate to Navigation (home screen)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Navigation(user: user)),
    );
  }
}
