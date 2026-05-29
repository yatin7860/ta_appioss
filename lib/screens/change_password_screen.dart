import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool loading = false;

  void changePassword() async {
    if (oldPassword.text.isEmpty || newPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);


    await Future.delayed(Duration(seconds: 2));

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Password Changed Successfully ✅")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        backgroundColor: Color(0xFF1E2F5B),
        title: Text("Change Password"),
        centerTitle: true,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20),

                // OLD PASSWORD
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Old Password"),
                ),
                SizedBox(height: 5),

                TextField(
                  controller: oldPassword,
                  obscureText: !showOld,
                  decoration: InputDecoration(
                    hintText: "Old Password",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showOld ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => showOld = !showOld);
                      },
                    ),
                  ),
                ),

                SizedBox(height: 15),

                // NEW PASSWORD
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("New Password"),
                ),
                SizedBox(height: 5),

                TextField(
                  controller: newPassword,
                  obscureText: !showNew,
                  decoration: InputDecoration(
                    hintText: "New Password",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNew ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => showNew = !showNew);
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E2F5B),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("CHANGE PASSWORD"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}