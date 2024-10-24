import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('asset/login-background.png'),
                fit: BoxFit.cover,  // Cover entire background
              ),
            ),
          ),
          // Login Form
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),  // Add slight opacity to form background
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    if (!isLogin) ...[
                      const Text(
                        "Welcome to Hedieaty",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: myAppColors.darkBlack,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLogin = true;  // Show login form
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: myAppColors.primColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50.0,
                            vertical: 16.0,
                          ),
                        ),
                        child: const Text(
                          "Get started",
                          style: TextStyle(color: myAppColors.darkBlack),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],

                    // Show login form only if "Get started" is clicked (isLogin is true)
                    if (isLogin) ...[
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: myAppColors.darkBlack,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Email Field
                      TextField(
                        controller: emailController,

                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: myAppColors.darkBlack ),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email ,color: myAppColors.darkBlack,),


                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Password Field
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: myAppColors.darkBlack ),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock,color: myAppColors.darkBlack),
                        ),
                        obscureText: true,  // To hide the password
                      ),
                      const SizedBox(height: 24.0),
                      // Login Button
                      ElevatedButton(
                        onPressed: () {
                          // Implement your login logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: myAppColors.primColor,  // Background color for the button
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50.0,
                            vertical: 16.0,
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(color: myAppColors.darkBlack),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Signup Option
                      GestureDetector(
                        onTap: () {
                          // Navigate to Signup Page
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => SignupPage()),
                          // );
                        },
                        child: const Text(
                          'Don\'t have an account? Sign up',
                          style: TextStyle(
                            color: myAppColors.primColor,
                            decoration: TextDecoration.underline,
                            fontSize: 18.0,
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
