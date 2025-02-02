import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController postTitleController = TextEditingController();
  // List<Map<String, String>> sections = [];
  List<Map<String, dynamic>> sections = [];

  /// Opens a dialog for adding a section
  // void showAddSectionDialog() {
  //   final TextEditingController sectionTitleController = TextEditingController();
  //   final TextEditingController hourController = TextEditingController();
  //   final TextEditingController minuteController = TextEditingController();
  //   final TextEditingController sectionContentController = TextEditingController();
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Add New Section"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: sectionTitleController,
  //               decoration: InputDecoration(labelText: "Section Title"),
  //             ),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: TextField(
  //                     controller: hourController,
  //                     decoration: InputDecoration(labelText: "HH"),
  //                     keyboardType: TextInputType.number,
  //                   ),
  //                 ),
  //                 SizedBox(width: 10),
  //                 Expanded(
  //                   child: TextField(
  //                     controller: minuteController,
  //                     decoration: InputDecoration(labelText: "MM"),
  //                     keyboardType: TextInputType.number,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             TextField(
  //               controller: sectionContentController,
  //               decoration: InputDecoration(labelText: "Section Content"),
  //               maxLines: 3,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context), // Close dialog
  //             child: Text("Cancel"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (sectionTitleController.text.isNotEmpty && sectionContentController.text.isNotEmpty) {
  //                 setState(() {
  //                   sections.add({
  //                     'time': '${hourController.text}:${minuteController.text}',
  //                     'title': sectionTitleController.text,
  //                     'content': sectionContentController.text,
  //                   });
  //                 });
  //                 Navigator.pop(context); // Close dialog
  //               } else {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text('Title and Content cannot be empty!')),
  //                 );
  //               }
  //             },
  //             child: Text("Add"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  void showAddSectionDialog() {
    final TextEditingController sectionTitleController = TextEditingController();
    final TextEditingController hourController = TextEditingController();
    final TextEditingController minuteController = TextEditingController();
    final TextEditingController sectionContentController = TextEditingController();

    String? imageUrl;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add New Section"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: sectionTitleController,
                    decoration: InputDecoration(labelText: "Section Title"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hourController,
                          decoration: InputDecoration(labelText: "HH"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: minuteController,
                          decoration: InputDecoration(labelText: "MM"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: sectionContentController,
                    decoration: InputDecoration(labelText: "Section Content"),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),

                  // ✅ Show Uploaded Image Preview
                  if (imageUrl != null)
                    Image.network(imageUrl!, height: 100, width: 100, fit: BoxFit.cover),

                  // ✅ Button to Upload Image
                  ElevatedButton.icon(
                    onPressed: () async {
                      String? uploadedImageUrl = await pickAndUploadImage();
                      if (uploadedImageUrl != null) {
                        setState(() {
                          imageUrl = uploadedImageUrl; // ✅ Save image URL
                        });
                      }
                    },
                    icon: Icon(Icons.image),
                    label: Text("Add Image"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Close dialog
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (sectionTitleController.text.isNotEmpty && sectionContentController.text.isNotEmpty) {
                      setState(() {
                        sections.add({
                          'time': '${hourController.text}:${minuteController.text}',
                          'title': sectionTitleController.text,
                          'content': sectionContentController.text,
                          'imageUrl': imageUrl ?? '', // ✅ Store image URL
                        });
                      });
                      Navigator.pop(context); // Close dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Title and Content cannot be empty!')),
                      );
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Saves the post with all sections to Parse Server
  Future<void> savePost1() async {
    print("hi from save poist");
    final String postTitle = postTitleController.text.trim();

    if (postTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post title cannot be empty!')),
      );
      return;
    }

    final post = await ParseCloudFunction("createPost").execute(
      parameters: {
        "postTitle": postTitle,
        "sections": sections,
      },
    );

    if (post.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post saved successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save post: ${post.error?.message}')),
      );
    }
  }

  Future<void> savePost() async {
    final String postTitle = postTitleController.text.trim();

    if (postTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post title cannot be empty!')),
      );
      return;
    }

    List<Map<String, dynamic>> formattedSections = sections.map((section) {
      return {
        'time': section['time'] ?? '00:00',
        'title': section['title'] ?? 'No Title',
        'content': section['content'] ?? 'No Content',
        'imageUrl': section['imageUrl'] ?? '', // ✅ Save image URLs
      };
    }).toList();

    final post = ParseObject('Posts')
      ..set('postTitle', postTitle)
      ..set('sections', formattedSections);

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

  Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      print("✅ Permission granted.");
    } else if (status.isDenied) {
      print("❌ Permission denied. Requesting again...");
      await Permission.storage.request(); // Try requesting again
    } else if (status.isPermanentlyDenied) {
      print("❌ Permission permanently denied. Opening settings...");
      openAppSettings(); // Open device settings so user can enable it manually
    }
  }

  Future<String?> pickAndUploadImage() async {
    requestStoragePermission();

    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return null; // User canceled
    }

    print("✅ Image picked: ${image.path}");
    return image.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Title
            Text(
              'Post Title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: postTitleController,
              decoration: InputDecoration(
                labelText: 'Enter post title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            Divider(), // Page Divider

            // Add Section Button
            Center(
              child: ElevatedButton.icon(
                onPressed: showAddSectionDialog,
                icon: Icon(Icons.add),
                label: Text('Add Section'),
              ),
            ),
            SizedBox(height: 16),

            // Sections List
            // Expanded(
            //   child: sections.isEmpty
            //       ? Center(child: Text('No sections added yet.'))
            //       : ListView.builder(
            //     itemCount: sections.length,
            //     itemBuilder: (context, index) {
            //       final section = sections[index];
            //       return Card(
            //         margin: EdgeInsets.symmetric(vertical: 8),
            //         elevation: 2.0,
            //         child: ListTile(
            //           title: Text(section['title'] ?? 'No Title'),
            //           subtitle: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               if (section['time']?.isNotEmpty == true)
            //                 Text('Time: ${section['time']}'),
            //               SizedBox(height: 4),
            //               Text(section['content'] ?? ''),
            //             ],
            //           ),
            //           trailing: IconButton(
            //             icon: Icon(Icons.delete, color: Colors.red),
            //             onPressed: () {
            //               setState(() {
            //                 sections.removeAt(index);
            //               });
            //             },
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            Expanded(
              child: sections.isEmpty
                  ? Center(child: Text('No sections added yet.'))
                  : ListView.builder(
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 2.0,
                    child: ListTile(
                      title: Text(section['title'] ?? 'No Title'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (section['time']?.isNotEmpty == true)
                            Text('Time: ${section['time']}'),
                          SizedBox(height: 4),
                          Text(section['content'] ?? ''),
                          SizedBox(height: 8),
                          if (section['imageUrl'] != null && section['imageUrl'].isNotEmpty)
                            Image.network(section['imageUrl']!, height: 100, width: 100, fit: BoxFit.cover),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            sections.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),

      // Floating Action Button (FAB) for Saving
      floatingActionButton: FloatingActionButton(
        onPressed: savePost,
        backgroundColor: Colors.blue,
        child: Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Positioned at bottom-right
    );
  }
}
