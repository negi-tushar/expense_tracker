import 'package:expense_tracker/constants/constants.dart';
import 'package:expense_tracker/services/shared_prefrence_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      if (SharedPrefService.getData(userNameKey).isNotEmpty) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/userProfile');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/img/appstore.png',
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}
