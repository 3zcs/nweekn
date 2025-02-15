import 'package:flutter/material.dart';
import 'package:nweekn/screens/UserProfilePage.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailPage({required this.post, Key? key}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  // late Future<ParseObject?> postFuture;
  late Map<String, dynamic> postData;
  late String? currentUserId;

  @override
  void initState() {
    super.initState();
    print("📝 Post Data: ${widget.post}"); // ✅ Print post in initState
    postData = widget.post;
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser != null) {
      setState(() {
        currentUserId = currentUser.objectId;
      });
    }
  }

  Future<ParseObject?> fetchPost(String postId) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Posts'))
      ..whereEqualTo('objectId', postId);

    final response = await query.query();

    if (response.success && response.results != null && response.results!.isNotEmpty) {
      return response.results!.first as ParseObject;
    } else {
      return null; // Post not found
    }
  }

  void _showFullImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain, // ✅ Ensures full image visibility
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Call Cloud Function to delete post
  Future<void> deletePost() async {
    final String postId = widget.post['objectId'];

    final ParseCloudFunction function = ParseCloudFunction('deletePost');
    final ParseResponse response = await function.execute(parameters: {"postId": postId});

    if (response.success) {
      print("✅ Post deleted successfully!");
      Navigator.pop(context, true); // Return to previous screen after delete
    } else {
      print("❌ Error deleting post: ${response.error?.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${response.error?.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.post['postTitle'] as String? ?? 'No Title';
    final postSummary = widget.post['postSummary'] as String? ?? 'No Summary Available';
    final postImageUrl = widget.post['postImage'] as String? ?? '';
    print("image p $postImageUrl");
    // ✅ Extract `createdBy` data safely
    final createdBy = widget.post['createdBy'] as Map<String, dynamic>?;
    final username = createdBy?['username'] as String? ?? 'Unknown User';
    final String createdById = createdBy?['objectId'] ?? '';

    final List<dynamic> sections = widget.post['sections'] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(
          title.length > 15 ? '${title.substring(0, 15)}...' : title, // ✅ Shorten if too long
          style: TextStyle(fontWeight: FontWeight.bold), // ✅ Keep it clear
        ),),
      floatingActionButton: (currentUserId == createdById)
          ? FloatingActionButton(
        backgroundColor: Color(0xff132137),
        onPressed: () async {
          bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Delete Post"),
              content: Text("Are you sure you want to delete this post?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Delete", style: TextStyle(color: Color(0xff132137))),
                ),
              ],
            ),
          );

          if (confirm) {
            deletePost();
          }
        },
        child: Icon(Icons.delete, color: Colors.white),
      )
          : null,
      body:
      //FutureBuilder<ParseObject?>(
        // future: postFuture,
        // builder: (context, snapshot) {
        //   if (snapshot.connectionState == ConnectionState.waiting) {
        //     return Center(child: CircularProgressIndicator());
        //   } else if (snapshot.hasError) {
        //     return Center(child: Text('Error: ${snapshot.error}'));
        //   } else if (!snapshot.hasData || snapshot.data == null) {
        //     return Center(child: Text('Post not found.'));
        //   }
        //
        //   final post = snapshot.data!;
        //   final title = post.get<String>('postTitle') ?? 'No Title';
        //   final createdBy = post.get<String>('createdBy') ?? 'Unknown User';
        //   final postSummary = post.get<String>('postSummary') ?? 'No Summary';
        //
        //
        //   final dynamic postImageData = post.get('postImage');
        //   String? postImageUrl;
        //   if (postImageData is ParseFile) {
        //     postImageUrl = postImageData.url;
        //   } else {
        //     postImageUrl = post.get('postImage');
        //   }
        //
        //   // ✅ Get Sections from Post
        //   final dynamic sectionsData = post.get<List<dynamic>>('sections') ?? [];
        //   List<Map<String, dynamic>> sections = [];
        //
        //   if (sectionsData is List) {
        //     sections = List<Map<String, dynamic>>.from(sectionsData);
        //   }
      SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Clickable Full-Width Main Post Image
                if (postImageUrl != null && postImageUrl.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showFullImageDialog(context, postImageUrl!),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Image.network(
                            postImageUrl,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 16),

                // ✅ Post Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(height: 8),

                // ✅ Username
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'Created by: ',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfilePage(username: username),
                            ),
                          );
                        },
                        child: Text(
                                username,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.brown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // ✅ Trip Summary
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Trip Summary:\n',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        TextSpan(
                          text: postSummary,
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // ✅ Page Divider
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    color: Colors.grey.shade400,
                    thickness: 1.2,
                    height: 20,
                  ),
                ),

                SizedBox(height: 20),

                // ✅ Display Sections (Stops)
                if (sections.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stops',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: sections.length,
                          itemBuilder: (context, index) {
                            final section = sections[index];
                            final sectionTitle = section['title'] ?? 'No Title';
                            final sectionContent = section['content'] ?? 'No Content';
                            final sectionTime = section['time'] ?? 'No Time';
                            final sectionImageUrl = section['imageUrl'] ?? '';
                            print("sss $sectionImageUrl");
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ✅ Clickable Section Image
                                  if (sectionImageUrl.isNotEmpty)
                                    GestureDetector(
                                      onTap: () => _showFullImageDialog(context, sectionImageUrl),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.network(
                                          sectionImageUrl,
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ✅ Section Title
                                        Text(
                                          sectionTitle,
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 6),

                                        // ✅ Section Time
                                        if (sectionTime.isNotEmpty)
                                          Text(
                                            'Time: $sectionTime',
                                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                          ),

                                        SizedBox(height: 8),

                                        // ✅ Section Content
                                        Text(
                                          sectionContent,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
    );
  }


}
