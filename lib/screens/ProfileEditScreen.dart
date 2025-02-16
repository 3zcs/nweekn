import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  String? profileImageUrl;
  File? _imageFile;
  bool _isLoading = false;
  ParseFile? profileImage;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final cloudFunction = ParseCloudFunction('getUserInfo');
    final ParseResponse response = await cloudFunction.execute();

    if (response.success && response.result != null) {
      setState(() {
        nameController.text = response.result['username'] ?? '';
        emailController.text = response.result['email'] ?? '';
        bioController.text = response.result['bio'] ?? '';

        print("✅ Updated bio: ${bioController.text}");

        profileImageUrl = response.result['profileImage']; // ✅ Get profile image URL
        print("✅ Updated profile image URL: $profileImageUrl");
      });
    } else {
      print("❌ Failed to fetch updated user info: ${response.error?.message}");
    }
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');  // Retrieve userId
  }

  void updateUserProfile(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final String? userId = await getCurrentUserId();
    final String name = nameController.text.trim();
    final String bio = bioController.text.trim();
    print("✅ User id: ${userId}");

    // ✅ Handle Image Upload (if changed)
    ParseFile? profileImageFile;
    if (_imageFile != null) {
      profileImageFile = ParseFile(File(_imageFile!.path));
      final ParseResponse imageResponse = await profileImageFile.save();

      if (!imageResponse.success) {
        print("❌ Image upload failed: ${imageResponse.error?.message}");
        profileImageFile = null; // Ensure null is passed if upload fails
      }
    }

    // ✅ Call Cloud Function to update user profile
    final cloudFunction = ParseCloudFunction('updateUserProfile');
    final response = await cloudFunction.execute(parameters: {
      "userId": userId,
      "name": name,
      "bio": bio,
      "profileImage": profileImageFile, // ✅ Send ParseFile instead of String
    });

    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      //await loadUserInfo();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context); // ✅ Go back to profile screen
      Future.delayed(Duration(milliseconds: 300), () {
        loadUserInfo(); // ✅ Reload updated user info
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update Failed: ${response.error?.message}')),
      );
    }
  }



  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // ✅ Removes shadow for a clean look
        backgroundColor: Colors.transparent, // ✅ Transparent background for custom styling
        centerTitle: true, // ✅ Centers the title
        flexibleSpace: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), // ✅ Rounded bottom corners
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber, // ✅ Matches Home & Other Pages
            ),
          ),
        ),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black, // ✅ Keeps text black for contrast
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // ✅ Consistent back button style
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/chatting.png', // Replace with your logo
                height: 250,
              ),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xffebc642),
                backgroundImage: _imageFile != null
                    ? FileImage(File(_imageFile!.path)) // ✅ Show selected image
                    : (profileImageUrl != null
                    //? NetworkImage(AppConfig.imgUrl + profileImageUrl!)
                    ? NetworkImage(profileImageUrl!)
                    : null),
                child: _imageFile == null
                    ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: nameController,
              enabled: false,
              decoration: InputDecoration(labelText: "Username", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              enabled: false, // Prevent editing email
              decoration: InputDecoration(labelText: "Email (can't be changed)", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: InputDecoration(labelText: "Bio", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: (){
            updateUserProfile(context); // ✅ Call the function inside the lambda
            },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Color(0xff132137),
                ),
              child:Center(
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                "Save Changes",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
