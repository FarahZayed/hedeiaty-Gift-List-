import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/models/userModel.dart';



class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final dbService = DatabaseService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool isLogin = false;
  File? profileImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }


//login with local DB
  // Future<void> _login() async {
  //   String email = emailController.text.trim();
  //   String password = passwordController.text.trim();
  //
  //   if (email.isEmpty || password.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please enter both email and password")),
  //     );
  //     return;
  //   }
  //
  //   final users = await dbService.getUsers();
  //   User? user;
  //
  //   try {
  //     user = users.firstWhere(
  //           (user) => user.email == email && user.password == password,
  //     );
  //   } catch (e) {
  //     user = null; // No user matches the criteria
  //   }
  //
  //   if (user != null) {
  //     Navigator.pushReplacementNamed(context, "/home",arguments: user);
  //   } else {
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Invalid email or password")),
  //     );
  //   }
  // }

  //signup with local DB
  // Future<void> _signUp() async {
  //   String email = emailController.text.trim();
  //   String password = passwordController.text.trim();
  //   String username = usernameController.text.trim();
  //
  //   if (email.isEmpty || password.isEmpty || username.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please fill in all the fields")),
  //     );
  //     return;
  //   }
  //
  //   final newUser = User(
  //     id: 0,
  //     name: username,
  //     email: email,
  //     password: password,
  //     preferences: "None",
  //   );
  //
  //   await dbService.insertUser(newUser);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Signup successful! Please log in.")),
  //   );
  //
  //
  //   usernameController.clear();
  //   emailController.clear();
  //   passwordController.clear();
  //   setState(() {
  //     isLogin = true;
  //   });
  // }

  //login with firebase
  Future<void> _logIn() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser?.email != null) {
        log(1);
        final dbUser = await dbService.getUserByEmail(firebaseUser!.email!);
        Navigator.pushReplacementNamed(context, "/home", arguments: dbUser);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to retrieve user email.')),
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
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final dbUser = UserlocalDB(
          id: firebaseUser.uid!,
          name: usernameController.text.trim(),
          email: firebaseUser.email!,
          preferences: "None",
        );
        Navigator.pushReplacementNamed(context, "/home", arguments: dbUser);

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Signup successful!.")),      );
      }

      Navigator.pop(context); // Close the signup modal
      emailController.clear();
      passwordController.clear();
    } on FirebaseAuthException catch (e) {
      String message = e.code == 'email-already-in-use'
          ? 'Email already in use. Please use a different email.'
          : 'An error occurred: ${e.message}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }




  void _showSignUpModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w600,
                  color: myAppColors.darkBlack,
                ),
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                     : const AssetImage("asset/profile.png")
                  as ImageProvider,
                  child: profileImage == null
                      ? const Icon(Icons.add_a_photo, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 16.0),
              // Username Field
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: myAppColors.darkBlack),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: myAppColors.darkBlack),
                ),
              ),
              const SizedBox(height: 16.0),
              // Email Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: myAppColors.darkBlack),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email, color: myAppColors.darkBlack),
                ),
              ),
              const SizedBox(height: 16.0),
              // Password Field
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: myAppColors.darkBlack),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock, color: myAppColors.darkBlack),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  await _signUp();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  backgroundColor: myAppColors.primColor,
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Blur Effect
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('asset/login-background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY:2),
              child: Container(
                color: myAppColors.darkBlack.withOpacity(0.3),
              ),
            ),
          ),
          // Login Form Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isLogin) ...[
                      const Text(
                        "Welcome to Hedieaty",
                        style: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.w600,
                          color: myAppColors.darkBlack,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLogin = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          elevation: 5.0,
                          backgroundColor: myAppColors.primColor,
                        ),
                        child: const Text(
                          "Get started",
                          style: TextStyle(fontSize: 18.0, color: myAppColors.darkBlack),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                    ],
                    if (isLogin) ...[
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: myAppColors.darkBlack,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Email Field
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: myAppColors.darkBlack),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.email, color: myAppColors.darkBlack),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Password Field
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: myAppColors.darkBlack),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.lock, color: myAppColors.darkBlack),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24.0),
                      // Login Button with Gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [myAppColors.primColor, myAppColors.secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: ElevatedButton(
                          onPressed: _logIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            elevation: 5.0,
                            backgroundColor: myAppColors.primColor,
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
                          _showSignUpModal();
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
