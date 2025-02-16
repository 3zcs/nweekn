import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:io';


class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController postTitleController = TextEditingController();
  final TextEditingController postSummaryController = TextEditingController();
  List<Map<String, dynamic>> sections = [];
  String? postImageUrl;
  bool _isLoading = false;

  /// ✅ Pick & Upload Image
  Future<String?> pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    ParseFile parseImage = ParseFile(File(image.path));
    final ParseResponse response = await parseImage.save();

    return response.success ? parseImage.url : null;
  }

  /// ✅ Opens a Dialog to Add a Stop
  Future<Map<String, dynamic>?> showAddSectionDialog() async {
    final TextEditingController sectionTitleController = TextEditingController();
    final TextEditingController minuteController = TextEditingController();
    final TextEditingController sectionContentController = TextEditingController();
    String? sectionImageUrl;

    return await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("New Stop"),
              content: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9, // ✅ 90% width
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ Image Preview
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

                      // ✅ Upload Image Button
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

                      // ✅ Section Title
                      TextField(
                        controller: sectionTitleController,
                        decoration: InputDecoration(
                          labelText: "Stop Title",
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
                          labelText: "Stop Details",
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
                  onPressed: () => Navigator.pop(context, null), // ✅ Close dialog without saving
                  child: Text("Cancel", style: TextStyle(fontSize: 16, color: Color(0xff132137))),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (sectionTitleController.text.isNotEmpty && sectionContentController.text.isNotEmpty) {
                      Navigator.pop(context, {
                        'time': '${minuteController.text} min',
                        'title': sectionTitleController.text,
                        'content': sectionContentController.text,
                        'imageUrl': sectionImageUrl ?? '',
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Title and Content cannot be empty!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff132137),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text("Add", style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> savePost() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final String postTitle = postTitleController.text.trim();
    final String postSummary = postSummaryController.text.trim();

    if (postTitle.isEmpty || postSummary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post title and summary cannot be empty!')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated!')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final cloudFunction = ParseCloudFunction('createPost');
    final response = await cloudFunction.execute(parameters: {
      "postTitle": postTitle,
      "postSummary": postSummary,
      "postImageUrl": postImageUrl ?? '',
      "sections": sections,
    });

    setState(() => _isLoading = false);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post created successfully!')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: ${response.error?.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // ✅ Removes default shadow for a clean look
        backgroundColor: Colors.transparent, // ✅ Transparent background for custom styling
        centerTitle: true, // ✅ Centers the title text
        flexibleSpace: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), // ✅ Rounded bottom corners
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber, // ✅ Matches Home & Post Details
            ),
          ),
        ),
        title: Text(
          "Create Post",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black, // ✅ Keeps text black for contrast
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // ✅ Back button to exit page
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ✅ Matching Background Theme
      backgroundColor: Colors.grey.shade100, // ✅ Soft background like other screens


      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ **Post Image Picker**
            GestureDetector(
              onTap: () async {
                String? uploadedImageUrl = await pickAndUploadImage();
                if (uploadedImageUrl != null) {
                  setState(() => postImageUrl = uploadedImageUrl);
                }
              },
              child: Container(
                height: 200,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                  image: postImageUrl != null
                      ? DecorationImage(image: NetworkImage(postImageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: postImageUrl == null ? Icon(Icons.camera_alt, size: 50, color: Colors.grey[700]) : null,
              ),
            ),

            /// ✅ **Post Title Input**
            TextField(
              controller: postTitleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              ),
            ),
            SizedBox(height: 16),

            /// ✅ **Post Summary Input**
            TextField(
              controller: postSummaryController,
              decoration: InputDecoration(
                labelText: 'Summary',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            Divider(),

            /// ✅ **Add Stop Button (Now Working)**
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final newSection = await showAddSectionDialog();
                    if (newSection != null) {
                      setState(() {
                        sections.add(newSection);
                      });
                    }
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text('Add Stop', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff132137),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            /// ✅ **Section List**
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: sections.isEmpty
                  ? Center(child: Text('No stops added yet.'))
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
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              section['imageUrl']!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        Padding(
                          padding: EdgeInsets.all(12),
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

          ]
        ),
      ),
      // ✅ Floating Save Button
      floatingActionButton: FloatingActionButton(
        onPressed: savePost,
        backgroundColor: Color(0xff132137),
        child: Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}
