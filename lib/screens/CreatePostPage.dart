import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';


extension FileSizeExtension on File {
  /// ✅ Get file size in KB
  double get sizeInKB => lengthSync() / 1024;

  /// ✅ Get file size in MB
  double get sizeInMB => lengthSync() / (1024 * 1024);
}

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController postTitleController = TextEditingController();
  final TextEditingController postSummaryController  = TextEditingController();

  List<Map<String, dynamic>> sections = [];
  String? postImageUrl;

  Future<String?> pickAndUploadImage() async {
    // ✅ Ensure permission before accessing storage
    await requestStoragePermission();

    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print("❌ No image selected.");
      return null; // ✅ User canceled picking an image
    }

    print("📤 Compressing image...");

    // ✅ Compress the image before uploading
    File compressedImage = await compressImage(File(image.path));

    print("📤 Uploading image to Back4App...");

    // ✅ Convert image to ParseFile and upload
    ParseFile parseImage = ParseFile(compressedImage);
    final ParseResponse response = await parseImage.save();

    if (response.success && parseImage.url != null) {
      print("✅ Image uploaded successfully: ${parseImage.url}");
      return parseImage.url; // ✅ Return uploaded image URL
    } else {
      print("❌ Image upload failed: ${response.error?.message}");
      return null;
    }
  }

  Future<File> compressImage(File imageFile) async {
    final directory = await getTemporaryDirectory();
    final targetPath = '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path, // ✅ Original Image Path
      targetPath, // ✅ New Compressed Image Path
      quality: 85, // ✅ Adjust quality (80-85 recommended)
      minWidth: 800, // ✅ Resize width
      minHeight: 800, // ✅ Resize height
    );

    if (result == null) {
      print("❌ Image compression failed.");
      return imageFile; // Return original if compression fails
    }

    File compressedFile = File(result.path);
    print("✅ Image compressed successfully: ${compressedFile.path}");
    print("✅ New file size: ${compressedFile.lengthSync() / 1024} KB");

    return compressedFile;
  }



  /// Opens a dialog for adding a section
  void showAddSectionDialog() {
    final TextEditingController sectionTitleController = TextEditingController();
    final TextEditingController minuteController = TextEditingController();
    final TextEditingController sectionContentController = TextEditingController();
    String? sectionImageUrl;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add New Section"),
              content: SingleChildScrollView( // ✅ Fixes overflow
                child: Container(
                  width: 400, // ✅ Fixed width
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // ✅ Prevents unnecessary expansion
                    children: [
                      // ✅ Image Preview at the Top
                      if (sectionImageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            sectionImageUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      SizedBox(height: 10),

                      // ✅ Button to Upload Image
                      ElevatedButton.icon(
                        onPressed: () async {
                          String? uploadedImageUrl = await pickAndUploadImage();
                          if (uploadedImageUrl != null) {
                            setState(() {
                              sectionImageUrl = uploadedImageUrl;
                            });
                          }
                        },
                        icon: Icon(Icons.image, color: Colors.white),
                        label: Text("Add Image", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xff132137)),
                      ),

                      SizedBox(height: 16),

                      // ✅ Section Title Field
                      TextField(
                        controller: sectionTitleController,
                        decoration: InputDecoration(
                          labelText: "Section Title",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 10),

                      // ✅ Minute Field (Only MM now)
                      TextField(
                        controller: minuteController,
                        decoration: InputDecoration(
                          labelText: "Time in minutes",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      SizedBox(height: 10),

                      // ✅ Section Content Field
                      TextField(
                        controller: sectionContentController,
                        decoration: InputDecoration(
                          labelText: "Section Content",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Color(0xff132137), // ✅ Button background color
                     foregroundColor: Color(0xff132137), // ✅ Text (label) color
                    // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // ✅ Adds padding for better appearance
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(8), // ✅ Rounded corners
                    // ),
                  ),
                  child: Text(
                    "cancel",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal), // ✅ Text styling
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (sectionTitleController.text.isNotEmpty && sectionContentController.text.isNotEmpty) {
                      setState(() {
                        sections.add({
                          'time': '${minuteController.text} min',
                          'title': sectionTitleController.text,
                          'content': sectionContentController.text,
                          'imageUrl': sectionImageUrl ?? '',
                        });
                      });
                      Navigator.pop(context);
                      this.setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Title and Content cannot be empty!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff132137), // ✅ Button background color
                    foregroundColor: Colors.white, // ✅ Text (label) color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // ✅ Adds padding for better appearance
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // ✅ Rounded corners
                    ),
                  ),
                  child: Text(
                    "Add",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal), // ✅ Text styling
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Save post to Parse Server
  Future<void> savePost() async {
    final String postTitle = postTitleController.text.trim();
    final String postSummary = postSummaryController.text.trim();


    if (postTitle.isEmpty || postSummary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post title cannot be empty!')),
      );
      return;
    }

    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    final String username = currentUser?.get<String>('name') ??
        currentUser?.get<String>('username') ??
        'Unknown User';

    final post = ParseObject('Posts')
      ..set('postTitle', postTitle)
      ..set('postImage', postImageUrl ?? '')
      ..set('postSummary', postSummary) // ✅ Store Summary
      ..set('sections', sections)
      ..set('createdBy', username);

    final response = await post.save();

    if (response.success) {
      print("✅ Post saved successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post saved successfully!')),
      );
      Navigator.pop(context);
    } else {
      print("❌ Failed to save post: ${response.error?.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save post: ${response.error?.message}')),
      );
    }
  }

  /// Request Storage Permission
  Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // ✅ Adds spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Image at the top with margin
            GestureDetector(
              onTap: () async {
                String? uploadedImageUrl = await pickAndUploadImage();
                if (uploadedImageUrl != null) {
                  setState(() {
                    postImageUrl = uploadedImageUrl;
                  });
                }
              },
              child: Container(
                height: 200,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 16), // ✅ Adds spacing below the image
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12), // ✅ Adds rounded corners
                  image: postImageUrl != null
                      ? DecorationImage(image: NetworkImage(postImageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: postImageUrl == null
                    ? Icon(Icons.camera_alt, size: 50, color: Colors.grey[700])
                    : null,
              ),
            ),

            // ✅ Title Field with More Spacing
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5), // ✅ Extra padding
              // child: Text(
              //   'Post Title',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
            ),
            SizedBox(height: 8), // ✅ Adds spacing between elements
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5), // ✅ Ensures all content is aligned
              child: TextField(
                controller: postTitleController,
                decoration: InputDecoration(
                  labelText: 'Enter post title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // ✅ Rounded corners
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // ✅ Spacing inside input
                ),
              ),
            ),
            SizedBox(height: 20), // ✅ Space before Divider
            // Text(
            //   'Post Summary',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 5), // ✅ Ensures all content is aligned
        child: TextField(
              controller: postSummaryController,
              decoration: InputDecoration(
                labelText: 'Enter post summary',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // ✅ Rounded corners
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // ✅ Spacing inside input
              ),
              maxLines: 3, // ✅ Allow multiline input
            ),
      ),

            SizedBox(height: 16),

            Divider(), // ✅ Page Divider

            // ✅ Add Section Button with Padding
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10), // ✅ Space around button
                child: ElevatedButton.icon(
                  onPressed: showAddSectionDialog,
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text('Add Section',
                    style: TextStyle(color: Colors.white)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff132137),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // ✅ Button padding
                  ),
                ),
              ),
            ),

            // ✅ Adds Space Before Section List
            SizedBox(height: 16),

            // ✅ Section List with Padding
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: sections.isEmpty
                  ? Center(child: Text('No sections added yet.'))
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Image at the Top (No Padding)
                        if (section['imageUrl'] != null && section['imageUrl'].isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)), // ✅ Rounds top corners
                            child: Image.network(
                              section['imageUrl']!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover, // ✅ Ensures image fills the space
                            ),
                          ),

                        Padding(
                          padding: EdgeInsets.all(12), // ✅ Padding only for text & content
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section['title'] ?? 'No Title',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              if (section['time']?.isNotEmpty == true)
                                Text('Time: ${section['time']}'),
                              SizedBox(height: 8),
                              Text(section['content'] ?? ''),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: savePost,
        backgroundColor: Color(0xff132137),
        child: Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}
