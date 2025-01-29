
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  // Controllers for the main Post Title
  final TextEditingController postTitleController = TextEditingController();

  // Controllers for each Section
  final TextEditingController sectionTitleController = TextEditingController();
  final TextEditingController hourController = TextEditingController();
  final TextEditingController minuteController = TextEditingController();
  final TextEditingController sectionContentController = TextEditingController();

  /// List of sections, each represented by a Map
  List<Map<String, String>> sections = [];

  /// Adds a single section to the local list [sections]
  void addSection() {
    final String sectionTitle = sectionTitleController.text.trim();
    final String hours = hourController.text.trim();
    final String minutes = minuteController.text.trim();
    final String sectionContent = sectionContentController.text.trim();

    if (sectionTitle.isEmpty || sectionContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Section title and content cannot be empty!')),
      );
      return;
    }

    setState(() {
      sections.add({
        'time': '$hours:$minutes',
        'title': sectionTitle,
        'content': sectionContent,
      });
    });

    // Clear the input fields for the next section
    sectionTitleController.clear();
    hourController.clear();
    minuteController.clear();
    sectionContentController.clear();
  }

  /// Saves the post (with all sections) to the Parse server
  Future<void> saveAllSections() async {
    final String postTitle = postTitleController.text.trim();


    // Create a Parse object
    // final post = ParseObject('Posts')
    //   ..set('postTitle', postTitle)
    //   ..set('sections', postTitle);

    final post = await ParseCloudFunction("createPost").execute(
      parameters: {
        "postTitle": postTitle,
        "sections": sections,
      },
    );
    // You can store the list of sections as JSON (array of objects).

    // Attempt to save
    //final response = await post.save();
    if (post.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post saved successfully!')),
      );
      Navigator.pop(context); // Go back or navigate as needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save post: ${post.error?.message}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // AppBar with a "Save" action
      appBar: AppBar(
        title: Text('Create Post'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveAllSections, // Saves everything to Parse
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Post Title
            Text(
              'Post Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: postTitleController,
              decoration: InputDecoration(
                labelText: 'Enter the post title here',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Section Title
            Text(
              'Section Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: sectionTitleController,
              decoration: InputDecoration(
                labelText: 'Enter the section title here',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Time (HH:MM)
            Text(
              'Time (HH:MM)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hourController,
                    decoration: InputDecoration(
                      labelText: 'HH',
                      border: OutlineInputBorder(),
                      hintText: 'Hours',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: minuteController,
                    decoration: InputDecoration(
                      labelText: 'MM',
                      border: OutlineInputBorder(),
                      hintText: 'Minutes',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Section Content
            Text(
              'Section Content',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: sectionContentController,
              decoration: InputDecoration(
                labelText: 'Write your section content here',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),

            // Add Section Button

            Center(
              child: ElevatedButton(
                onPressed: addSection,
                child: Text('Add Section'),
              ),
            ),
            SizedBox(height: 20),

            // Timeline
            Text(
              'Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Display Timeline
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(section['title'] ?? 'No Title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (section['time']?.isNotEmpty == true)
                          Text('Time: ${section['time']}'),
                        SizedBox(height: 4),
                        Text(section['content'] ?? ''),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

