import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nweekn/screens/CreatePostPage.dart';
import 'package:nweekn/screens/OWeekNIdeaPage.dart';
import 'package:nweekn/screens/PostDetailPage.dart';
import 'package:nweekn/screens/ProfileEditScreen.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>>  postsFuture = Future.value([]);
  late Future<Map<String, dynamic>?> userFuture;

  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    print("Initializing Page Controller");
    _pageController = PageController(viewportFraction: 0.6);
    userFuture = _getCurrentUser(); // ✅ Load user data initially

  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      userFuture = _getCurrentUser(); // ✅ Reload user data when returning
    });
  }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final ParseCloudFunction function = ParseCloudFunction('getPosts');
    final ParseResponse response = await function.execute();


    if (response.success && response.result != null) {
      print("Posts Fetched: ${response.result!.length}");
      print("Posts Fetched: ${response.result}");
      return List<Map<String, dynamic>>.from(response.result);
    } else {
      print("Failed to fetch posts: ${response.error?.message}");
      return []; // Return empty list to avoid null errors
    }
  }



  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('sessionToken');

    if (sessionToken == null || sessionToken.isEmpty) {
      print("❌ No session token found.");
      return false; // No session token → user is not logged in.
    }

    try {
      // ✅ Fetch user using session token
      final ParseResponse? response = await ParseUser.getCurrentUserFromServer(sessionToken);

      if (response!.success && response.result != null) {
        final ParseUser user = response.result;
        print("✅ User is logged in: ${user.username}");
        return true;
      } else {
        print("❌ Session token is invalid or expired.");
        await prefs.remove('sessionToken'); // Clear invalid session
        return false;
      }
    } catch (e) {
      print("❌ Error checking login status: $e");
      return false;
    }
  }

  void checkLoginStatus() async {
    bool loggedIn = await isUserLoggedIn();
    if (!loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      print("🔄 Refreshing posts after login...");
      setState(() {
        postsFuture = fetchPosts(); // ✅ Updates UI with new posts
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      // ✅ Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (!confirm) return; // ✅ Cancel logout if user selects "Cancel"

      // ✅ Logout from Parse (or Firebase, etc.)
      final ParseUser? user = await ParseUser.currentUser() as ParseUser?;
      if (user != null) {
        var response = await user.logout();
        if (!response.success) {
          throw Exception("Logout failed: ${response.error?.message}");
        }
      }

      // ✅ Clear locally stored session (SharedPreferences)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // ✅ Removes all locally stored data

      // ✅ Navigate to Login Screen & Prevent Back Navigation
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()), // ✅ Creates a new login screen
            (Route<dynamic> route) => false, // ✅ Removes all previous routes from the stack
      );
    } catch (e) {
      print("❌ Error during logout: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Logout failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> _getCurrentUser() async {
    final cloudFunction = ParseCloudFunction("getUserProfile");
    final response = await cloudFunction.execute();

    if (response.success && response.result != null) {
      return response.result;  // Return user details
    } else {
      print("❌ Failed to fetch user profile: ${response.error?.message}");
      return null;
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16), // ✅ Balanced padding
          decoration: BoxDecoration(
            color: Color(0xFFe3e3e3), // ✅ Matches the Post Card & Stops Card
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.amber, size: 24), // ✅ Matches theme icons
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:

    AppBar(
      elevation: 0, // ✅ Remove default shadow for a clean look
      backgroundColor: Colors.transparent, // ✅ Transparent to apply custom background
      centerTitle: true, // ✅ Center the title text
      flexibleSpace: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), // ✅ Rounded bottom corners
        child: Container(
          decoration: BoxDecoration(
            color: Colors.amber, // ✅ Custom Background Color (Light Grey)
          ),
        ),
      ),
      title: Text(
        "Home",
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black, // ✅ Make title black for contrast
        ),
      ),
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu, color: Colors.black), // ✅ Black menu icon for visibility
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
    ),


    drawer:
    Drawer(
      child: Column(
      children: [
      // ✅ Modern Drawer Header
      Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50, bottom: 20),
      // decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: [Color(0xFFFFC107), Color(0xFFFFA000)], // ✅ Amber shades
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ),
      // ),
        color: Color(0xFFFFC107), // ✅ Single Amber Color

        child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: userFuture, // ✅ Fetch user details from cloud function
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(color: Colors.white);
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Text("No User Info", style: TextStyle(color: Colors.white));
              }

              final userData = snapshot.data!;
              final String username = userData['username'] ?? "User";
              final dynamic profileImageData = userData['profileImage'];

              // ✅ Extract profile image URL correctly
              String? profileImageUrl;
              if (profileImageData is String) {
                profileImageUrl = profileImageData;
              } else if (profileImageData is Map<String, dynamic>) {
                profileImageUrl = profileImageData['url'];
              }

              return Column(
                children: [
                  // ✅ Profile Image with Black Border
                  Container(
                    padding: EdgeInsets.all(4), // ✅ Creates black border effect
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white70, // ✅ Black circle around avatar
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Color.fromRGBO(255, 255, 255, 0.3), // ✅ Fix using RGBO
                      backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : AssetImage("assets/people.png") as ImageProvider,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    username,
                    style: TextStyle(
                      color: Colors.black, // ✅ Black text for username
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),

    // ✅ Modern List Items
    Expanded(
    child: ListView(
    padding: EdgeInsets.symmetric(vertical: 10),
    children: [
    _buildDrawerItem(Icons.edit, "Edit Profile", () async {
    await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProfileEditScreen()),
    );
    setState(() {
    userFuture = _getCurrentUser();
    });
    }),

    _buildDrawerItem(Icons.lightbulb_outline, "The OWeekN Idea", () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => OWeekNIdeaPage()));
    }),

      _buildDrawerItem(Icons.logout, "Logout", () => logout(context)),
    ],
    ),
    ),
    ],
    ),
    ),



    body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Color(0xFFF5F5F5), // ✅ Choose from Light Grey, Beige, or Blue-Grey
          ),

          // ✅ Foreground Content (Cards start from the top)
          Column(
            children: [
              SizedBox(height: 40), // ✅ Add spacing from the top

              // ✅ Title (Inside Foreground Content)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16), // ✅ Add padding for better spacing
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // ✅ Align left
                  children: [
                    Text(
                      "Recent OWeekN Ideas",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8), // ✅ Add spacing between text and icon
                    Icon(Icons.lightbulb, color: Colors.amber, size: 28), // ✅ Lamp icon
                  ],
                ),
              ),

              SizedBox(height: 10), // ✅ Add spacing between title and posts
              // ✅ REMOVE extra spacing here!
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: postsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No posts available.'));
                    }

                    final posts = snapshot.data!;

                    return ListView.builder(
                      padding: EdgeInsets.only(top: 10, left: 10, right: 10), // ✅ Keep padding
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final title = post['postTitle'] as String? ?? 'No Title';

                        // ✅ Correctly fetch username from the included 'createdBy' user map
                        final username = post['createdBy']?['username'] as String? ?? 'Unknown User';

                        final summary = post['postSummary'] as String? ?? 'No Summary Available'; // ✅ Get summary
                        final postImageUrl = post['postImage'] as String? ?? '';
                        print("image $postImageUrl");
                        // ✅ Get Image URL
                        // if (postImageUrl is Map<String, dynamic> && postImageUrl.containsKey('url')) {
                        //   postImageUrl = postImageData['url'] as String; // ✅ Extract URL from Map
                        // } else {
                        //   postImageUrl = post['postImage'] as String? ?? ''; // ✅ Directly access as a string
                        // }

                        return GestureDetector(
                          onTap: () async {
                            final bool? deleted = await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => PostDetailPage(post: post),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );

                            if (deleted == true) {
                              // ✅ Refresh Home Screen after post deletion
                              setState(() {
                                postsFuture = fetchPosts(); // ✅ Re-fetch posts
                              });
                            }
                          },
                          child: PostCard(
                            title: title,
                            username: username, // ✅ Correctly pass the username
                            imageUrl: postImageUrl,
                            summary: summary, // ✅ Pass summary
                          ),
                        );
                      },
                    );

                  },
                ),
              ),
            ],
          ),
        ],
      ),

      // Floating Action Button (FAB) to Create a New Post
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostPage()),
          );

          if (result == true) {
            refreshData(); // ✅ Refresh the posts when returning
          }
        },
        backgroundColor: Color(0xff132137),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void refreshData() {
    setState(() {
      postsFuture = fetchPosts();
    });
  }
}

/// Post Card UI
class PostCard extends StatelessWidget {
  final String title;
  final String username;
  final String imageUrl;
  final String summary;

  const PostCard({
    required this.title,
    required this.username,
    required this.imageUrl,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: 16, right: 16), // ✅ Keep consistent spacing
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFf0f0f0), // ✅ Flat, soft background like the Stops Card
          borderRadius: BorderRadius.circular(16), // ✅ Rounded corners for a modern look
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Post Image (Rounded Top Corners)
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Title with Icon
                  Row(
                    children: [
                      Icon(Icons.article, color: Colors.brown, size: 22),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

                  // ✅ Created By Section
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.brown, size: 22),
                      SizedBox(width: 8),
                      Text(
                        username,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  SizedBox(height: 6),

                  // ✅ Summary Section
                  Row(
                    children: [
                      Icon(Icons.short_text, color: Colors.brown, size: 22),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                      ),
                    ],
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

