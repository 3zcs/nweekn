import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendPasswordResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your email.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final ParseUser user = ParseUser(null, null, email);
    final response = await user.requestPasswordReset();

    setState(() {
      isLoading = false;
    });

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent! Check your inbox.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${response.error?.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f1ec),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/file.png', // Use the same logo as login
                height: 300,
              ),
            ),
            SizedBox(height: 40),
            Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Enter your email to reset your password",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 30),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Color(0xff132137),
              ),
              child: Center(
                child: Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Back to Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
