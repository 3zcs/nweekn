import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nweekn/screens/UserProfilePage.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailPage({required this.post, Key? key}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  String? creatorProfileImageUrl;
  String? currentUserId;
  bool isCreator = false;

  @override
  void initState() {
    super.initState();
    fetchCreatorProfile();
    getCurrentUser();
  }

  // ✅ Fetch creator profile from Cloud Function
  Future<void> fetchCreatorProfile() async {
    final String username = widget.post['createdBy']?['username'] ?? 'Unknown User';

    final ParseCloudFunction function = ParseCloudFunction('getCreatorProfile');
    final ParseResponse response = await function.execute(parameters: {"username": username});

    if (response.success && response.result != null) {
      final data = response.result as Map<String, dynamic>;
      setState(() {
        // creatorFullName = data['fullName'] ?? "No Name";
        // creatorBio = data['bio'] ?? "No Bio Available";
        creatorProfileImageUrl = data['profileImage'];
      });
    } else {
      print("❌ Error fetching creator profile: ${response.error?.message}");
    }
  }

  Future<void> getCurrentUser() async {
    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser != null) {
      setState(() {
        currentUserId = currentUser.objectId;
        isCreator = (currentUserId == widget.post['createdBy']?['objectId']);
      });
    }
  }

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
    final String title = widget.post['postTitle'] ?? 'No Title';
    final String postSummary = widget.post['postSummary'] ?? 'No Summary';
    final String? postImageUrl = widget.post['postImage'];
    final String username = widget.post['createdBy']?['username'] ?? 'Unknown User';
    // ✅ Extract Sections Data
    final List<dynamic> sectionsData = widget.post['sections'] ?? [];
    List<Map<String, dynamic>> sections = [];
    sections = List<Map<String, dynamic>>.from(sectionsData);




    return Scaffold(
      backgroundColor: Colors.grey[100], // ✅ Soft background color
      extendBodyBehindAppBar: true, // ✅ Makes the AppBar overlay the background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ✅ Transparent to apply custom background
        centerTitle: true,
        flexibleSpace: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), // ✅ Rounded bottom corners
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber, // ✅ Consistent with Home
            ),
          ),
        ),
        title: Text(
          "Post Details",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black, // ✅ Make title black for contrast
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      floatingActionButton: isCreator
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ SafeArea prevents stops section from being pushed too far down
            SafeArea(
              bottom: false, // ✅ Prevents extra padding at the bottom
              child: Column(
                children: [
                  // ✅ Post Image with Overlay (Remains the same)
                  if (postImageUrl != null && postImageUrl.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showFullImageDialog(context, postImageUrl),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                            child: Image.network(
                              postImageUrl,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                              gradient: LinearGradient(
                                colors: [Color.fromRGBO(0, 0, 0, 0.4), Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Color.fromRGBO(0, 0, 0, 0.8),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 16), // ✅ Ensure proper spacing before "Created by"

                  // ✅ Creator Section with Avatar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                            child: creatorProfileImageUrl != null
                                ? Image.network(creatorProfileImageUrl!, fit: BoxFit.cover)
                                : Icon(Icons.person, color: Colors.white, size: 30),
                          ),
                        ),

                        SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Created by",
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
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
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12), // ✅ Reduce extra space before summary

                  // ✅ Post Summary - Adjusted for Proper Positioning
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Trip Summary",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            postSummary,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SizedBox(height: 10), // ✅ Ensures proper spacing before the divider
                        Divider(
                          color: Colors.grey.shade500, // ✅ Make it slightly darker for contrast
                          thickness: 1.5, // ✅ Slightly thicker to stand out
                          height: 20, // ✅ Ensure proper spacing after the divider
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10), // ✅ Reduce extra space before stops

                  // ✅ Stops Section - Adjusted Top Padding
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stops',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        // ✅ FIX: Ensure first stop card is not pushed too far down
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: sections.length,
                          itemBuilder: (context, index) {
                            final section = sections[index];
                            final String sectionTitle = section['title'] ?? 'No Title';
                            final String sectionContent = section['content'] ?? 'No Content';
                            final String sectionTime = section['time'] ?? 'No Time';
                            final String sectionImageUrl = section['imageUrl'] ?? '';

                            return Padding(
                              padding: EdgeInsets.only(top: index == 0 ? 8 : 16), // ✅ First card starts closer to "Stops"
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (sectionImageUrl.isNotEmpty)
                                      GestureDetector(
                                        onTap: () => _showFullImageDialog(context, sectionImageUrl),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                          child: Image.network(
                                            sectionImageUrl,
                                            width: double.infinity,
                                            height: 180,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                    Padding(
                                      padding: EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.location_on, color: Colors.brown, size: 24),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  sectionTitle,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 6),

                                          Row(
                                            children: [
                                              Icon(Icons.timer, color: Colors.brown, size: 24),
                                              SizedBox(width: 8),
                                              Text(
                                                sectionTime,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 8),

                                          Text(
                                            sectionContent,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
          ],
        ),
      ),



    );
  }

  // ✅ Full Screen Image View
  void _showFullImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
