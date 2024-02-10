import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);


  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Define a global key for the form
  final _formKey = GlobalKey<FormState>();



  Future<void> _register() async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,

      );
      // Properly formatted Map for f_type
      Map<String, bool> foodPreferences = {
        'grilled_food': false,
        'salad': false,
        'animals_product': false,
        'sea_food': false,
        'honey': false,
        'meat_and_rice': false,
        'sandwich': false,
        'traditional_food': false,
        'dates': false,
        'steamed_food': false,
        'oils': false,
      };

      // إضافة بيانات المستخدم إلى Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'phone': '',
        'region': 'Riyadh',
        'avatar': '',
        'social': '',
        'description': '',
        'f_type' : foodPreferences,

        // يمكن إضافة معلومات إضافية هنا إذا لزم الأمر
      });

      // Once the user is registered, you can store additional information, like the name, in Firebase
      await userCredential.user?.updateDisplayName(nameController.text);

      print('User registered: ${userCredential.user!.uid}');
    } catch (e) {
      print('Error registering user: $e');
      // Handle registration errors here and provide feedback to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    return Scaffold(
      body:
          Padding(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  // ... (other widgets)

                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  // Name TextField
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                      validator: validateName, // Add validator here
                    ),
                  ),

                  // Email TextField
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                      validator: validateEmail, // Add validator here
                    ),
                  ),

                  // Password TextField
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                      validator: validatePassword, // Add validator here
                    ),
                  ),

                  // Confirm Password TextField
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextFormField(
                      obscureText: true,
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirm Password',
                      ),
                      validator: (value) => validateConfirmPassword(passwordController.text, value!),
                    ),
                  ),

                  // Register button
                  Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Register'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) { // Check if the form is valid
                          _register();
                          navigationProvider.changePage(1);
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Already have an account?'),
                      TextButton(
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {

                          Provider.of<NavigationProvider>(context,
                              listen: false).changePage(0);
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// Define a function to validate the name
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your name';
  }
  return null;
}

// Define a function to validate the email
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter a valid email address';
  }
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern.toString());
  if (!regex.hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

// Define a function to validate the password
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password cannot be empty';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
    return 'Password must have at least one number';
  }
  // Add more conditions for symbols or uppercase letters if needed
  return null;
}

// Define a function to validate the confirm password
String? validateConfirmPassword(String password, String confirmPassword) {
  if (password != confirmPassword) {
    return 'Passwords do not match';
  }
  return null;
}