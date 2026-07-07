import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart'; // ✅ ADD THIS

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool isPasswordVisible = false;
  bool loading = false;
  String message = "";

  void loginUser() async {

    if (username.text.trim().isEmpty || password.text.trim().isEmpty) {
      setState(() {
        message = "Please enter username & password";
      });
      return;
    }

    setState(() {
      loading = true;
      message = "";
    });

    try {
      var response = await ApiService.login(
        username.text.trim(),
        password.text.trim(),
      );

      setState(() {
        loading = false;
      });

      if (response != null &&
          response['success'] == "Login successful") {

        final prefs = await SharedPreferences.getInstance();

        var user = response['user'];

        print("USER OBJECT = $user");
        print("USER LOG ID = ${user['log_id']}");
        print("USER LOG_ID = ${user['LOG_ID']}");

        String name = user['NAME'] ?? "";
        String email = user['EMAIL'] ?? "";
        String empId = user['EMP_ID']?.toString() ?? "";
        String logId = user['log_id']?.toString() ?? "";
        
        print("SAVED LOG ID = ${prefs.getString('log_id')}");
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', name);
        await prefs.setString('email', email);
        await prefs.setString('emp_id', empId);
        await prefs.setString('log_id', logId);
        print("SAVED LOG ID: $logId");
        await prefs.setString('role', user['ROLE'] ?? "");
        await prefs.setString('group', user['GROUP_NAME'] ?? "");
        
        print("ROLE FROM API : ${user['ROLE']}");

        print("ROLE SAVED : ${prefs.getString('role')}");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(name: name),
          ),
        );

      } else {
        setState(() {
          message = "Invalid Username or Password ❌";
        });
      }

    } catch (e) {
      setState(() {
        loading = false;
        message = "Server Error / No Internet ⚠️";
      });
      print("LOGIN ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Image.asset("assets/logo.png", height: 80),

                const SizedBox(height: 10),

                Text(
                  "Tour & Allowance\nLogin",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),

                const SizedBox(height: 20),

                // USERNAME
                TextField(
                  controller: username,
                  decoration: InputDecoration(
                    hintText: "Username",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // PASSWORD
                TextField(
                  controller: password,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E2F5B),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
                  ),
                ),

                const SizedBox(height: 10),

                // SIGNUP BUTTON ✅ NEW
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignupScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Don't have an account? Signup",
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ),

                const SizedBox(height: 10),

                // MESSAGE
                Text(
                  message,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}