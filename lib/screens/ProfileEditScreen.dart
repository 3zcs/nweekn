import 'package:flutter/material.dart';
import 'package:nweekn/constants.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
    final ParseUser? user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      setState(() {
        nameController.text = user.get<String>('name') ?? '';
        emailController.text = user.get<String>('email') ?? '';
        bioController.text = user.get<String>('bio') ?? '';

        final dynamic profileImageData = user.get('profileImage'); // Get stored profile image
        // ✅ Check if `profileImageData` is a `ParseFile`
        if (profileImageData is ParseFile) {
          profileImageUrl = profileImageData.url; // ✅ Extract the URL from ParseFile
        } else {
          profileImageUrl = user.get('profileImage'); // ✅ Handle cases where no image exists
        }
        print("profile $profileImageUrl");
        //profileImageUrl = profileImage!.url;
      });
    }
  }

  Future<void> updateUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final ParseUser? user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      //user.set('name', nameController.text.trim());
      user.set('bio', bioController.text.trim());


      if (_imageFile != null) {
        print("📤 Uploading image...");

        // ✅ Ensure a `File` is passed to ParseFile
        ParseFile parseImage = ParseFile(File(_imageFile!.path));
        final ParseResponse imageResponse = await parseImage.save();

        if (imageResponse.success && parseImage.url != null) {
          print("✅ Image uploaded successfully: ${parseImage.url}");
          user.set('profileImage', parseImage); // ✅ Store the file in Parse
        } else {
          print("❌ Image upload failed: ${imageResponse.error?.message}");
        }
      }

      final response = await user.save();
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile Updated Successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update Failed: ${response.error?.message}')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
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
      appBar: AppBar(title: Text("Edit Profile")),
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
                backgroundImage:  profileImageUrl != null
                    ? NetworkImage(AppConfig.imgUrl + profileImageUrl!)
                    : null,
                child: _imageFile == null
                    ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: nameController,
              enabled: false,
              decoration: InputDecoration(labelText: "Name", border: OutlineInputBorder()),
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
              onPressed: updateUserProfile,
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
