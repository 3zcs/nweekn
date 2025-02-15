import 'package:flutter/material.dart';
import 'package:nweekn/screens/LoginScreen.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:io';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void doUserRegistration(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final username = nameController.text.trim();
      final password = passwordController.text.trim();
      final email = emailController.text.trim();
      final bio = bioController.text.trim();

      print('Registration start ');
      // ✅ Call Cloud Function for Secure Registration
      final cloudFunction = ParseCloudFunction('Register');
      final response = await cloudFunction.execute(parameters: {
        "username": username,
        "password": password,
        "email": email,
        "bio": bio,
      });

      // you can't upload before auth
      // if (_imageFile != null) {
      //   print("📤 Uploading image...");
      //
      //   ParseFile parseImage = ParseFile(File(_imageFile!.path));
      //
      //   final ParseResponse imageResponse = await parseImage.save();
      //
      //   if (imageResponse.success && parseImage.url != null) {
      //     print("✅ Image uploaded successfully: ${parseImage.url}");
      //     user.set('profileImage', parseImage.url); // ✅ Store URL in Parse
      //   } else {
      //     print("❌ Image upload failed: ${imageResponse.error?.message}");
      //   }
      // }

      print('Registration done ');
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful!')),
        );
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()), // Change to HomePage() if needed
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed: ${response.error?.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> _pickImage() async {
  //   final ImagePicker _picker = ImagePicker();
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //
  //   if (image != null) {
  //     setState(() {
  //       _imageFile = File(image.path);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f1ec),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: Offset(0, -150),
              child: Center(
                child: Image.asset(
                  'assets/communication.png',
                  height: 300,
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -150),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Sign up to get started!",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    // Center(
                    //   child: GestureDetector(
                    //     onTap: _pickImage,
                    //     child: Container(
                    //       width: 120,
                    //       height: 120,
                    //       decoration: BoxDecoration(
                    //         color: Colors.grey[200],
                    //         shape: BoxShape.circle,
                    //         image: _imageFile != null
                    //             ? DecorationImage(
                    //                 image: FileImage(_imageFile!),
                    //                 fit: BoxFit.cover,
                    //               )
                    //             : null,
                    //       ),
                    //       child: _imageFile == null
                    //           ? Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Icon(Icons.camera_alt, size: 40, color: Colors.grey[800]),
                    //                 SizedBox(height: 8),
                    //                 Text(
                    //                   'Add Photo',
                    //                   style: TextStyle(
                    //                     color: Colors.grey[800],
                    //                     fontSize: 12,
                    //                   ),
                    //                 ),
                    //               ],
                    //             )
                    //           : null,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible 
                              ? Icons.visibility 
                              : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible 
                              ? Icons.visibility 
                              : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: bioController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Bio",
                        hintText: "Tell us about yourself...",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _isLoading 
                        ? null 
                        : () => doUserRegistration(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Color(0xff132137),
                      ),
                      child: Center(
                        child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "Sign Up",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(), // ✅ Pass username
                              ),
                            ); // Navigate back to login screen
                          },
                          child: Text("Log In"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
