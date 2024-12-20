import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hedieaty/widgets/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:firebase_messaging/firebase_messaging.dart';

import '../services/firestoreListener.dart';




class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLogin = false;
  bool isSignup = false;

  Future<void> saveFCMToken(String userId) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }




  //login with firebase
  Future<void> _logIn() async {
    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter email and password.")),
        );
        return;
      }

      // Firebase Authentication
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;

          await saveFCMToken(data['uid']);
          FirestoreListener.listenForPledges(data['uid']);

          Navigator.pushReplacementNamed(context, "/home", arguments: data);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User data not found in Firestore.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to authenticate user.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password. Please try again.';
      } else {
        message = 'An error occurred: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }


  //signup with firebase auth
  Future<void> _signUp() async {
    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty || usernameController.text.isEmpty || phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields.")),
        );
        return;
      }

      // Firebase Authentication
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);

        final Map<String ,dynamic> userData = {
          'uid': firebaseUser.uid,
          'username': usernameController.text.trim(),
          'email': firebaseUser.email,
          'phone': phoneController.text.trim(),
          // 'photoURL': profileImage != null ? firebaseUser.photoURL : null,
          'photoURL':null,
          'eventIds': [],
          'friendIds': [],
        };

        await userDoc.set(userData);
        emailController.clear();
        passwordController.clear();
        usernameController.clear();
        phoneController.clear();

        await saveFCMToken(firebaseUser.uid);
        FirestoreListener.listenForPledges(firebaseUser.uid);
        Navigator.pushReplacementNamed(context, "/home", arguments: userData);


      }

    } on FirebaseAuthException catch (e) {
      String message = e.code == 'email-already-in-use'
          ? 'Email already in use. Please use a different email.'
          : 'An error occurred: ${e.message}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('asset/login-background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                color: myAppColors.darkBlack.withOpacity(0.6),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: isSignup
                    ? _buildSignupForm(context) // Signup Form
                    : isLogin
                    ? _buildLoginForm(context) // Login Form
                    : _buildWelcomeMessage(context), // Welcome Message
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Column(
      key: const ValueKey("WelcomeMessage"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Welcome to Hedieaty",
          style: TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.w600,
            color: myAppColors.lightWhite,
          ),
        ),
        const SizedBox(height: 16.0),
        InkWell(
          onTap: () {
            setState(() {
              isLogin = true;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                colors: [myAppColors.primColor, myAppColors.secondaryColor],
              ),
            ),
            child: const Text(
              "Get started",
              style: TextStyle(fontSize: 18.0, color: myAppColors.darkBlack),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      key: const ValueKey("LoginForm"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Log in',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: myAppColors.lightWhite,
          ),
        ),
        const SizedBox(height: 16.0),
        // Email and Password Fields
        ..._buildLoginFields(),
        const SizedBox(height: 24.0),
        // Login Button
        InkWell(
          onTap: _logIn,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                colors: [myAppColors.primColor, myAppColors.secondaryColor],
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        // Signup Option
        GestureDetector(
          onTap: () {
            setState(() {
              isSignup = true;
            });
          },
          child: const Text(
            'Don\'t have an account? Sign up',
            style: TextStyle(
              color: myAppColors.primColor,
              decoration: TextDecoration.underline,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        key: const ValueKey("SignupForm"),
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: myAppColors.lightWhite,
            ),
          ),
          const SizedBox(height: 16.0),
          // Signup Fields
          ..._buildSignupFields(),
          const SizedBox(height: 24.0),
          // Signup Button
          InkWell(
            onTap: _signUp,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(
                  colors: [myAppColors.primColor, myAppColors.secondaryColor],
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          // Back to Login
          GestureDetector(
            onTap: () {
              setState(() {
                isSignup = false;
                isLogin = true;
              });
            },
            child: const Text(
              'Already have an account? Log in',
              style: TextStyle(
                color: myAppColors.primColor,
                decoration: TextDecoration.underline,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSignupFields() {
    return [
      TextField(
        controller: emailController,
        style: const TextStyle(color: myAppColors.lightWhite),
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: const TextStyle(color: myAppColors.lightWhite),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.email, color: myAppColors.lightWhite),
        ),
      ),
      const SizedBox(height: 16.0),
      TextField(
        controller: passwordController,
        style: const TextStyle(color: myAppColors.lightWhite),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: const TextStyle(color: myAppColors.lightWhite),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.lock, color: myAppColors.lightWhite),
        ),
        obscureText: true,
      ),
      const SizedBox(height: 16.0),
      TextField(
        controller: usernameController,
        style: const TextStyle(color: myAppColors.lightWhite),
        decoration: InputDecoration(
          labelText: 'User Name',
          labelStyle: const TextStyle(color: myAppColors.lightWhite),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.person, color: myAppColors.lightWhite),
        ),
      ),
      const SizedBox(height: 16.0),
      TextField(
        controller: phoneController,
        style: const TextStyle(color: myAppColors.lightWhite),
        decoration: InputDecoration(
          labelText: 'Phone number',
          labelStyle: const TextStyle(color: myAppColors.lightWhite),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.phone, color: myAppColors.lightWhite),
        ),
      ),
    ];
  }

  List<Widget> _buildLoginFields() {
    return [
      TextField(
        controller: emailController,
        style: const TextStyle(color: myAppColors.lightWhite),
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: const TextStyle(color: myAppColors.lightWhite),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.email, color: myAppColors.lightWhite),
        ),
      ),
      const SizedBox(height: 16.0),
      TextField(
        controller: passwordController,
        style: const TextStyle(color: myAppColors.lightWhite),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: const TextStyle(color: myAppColors.lightWhite),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.lock, color: myAppColors.lightWhite),
        ),
        obscureText: true,
      ),
    ];
  }



}
