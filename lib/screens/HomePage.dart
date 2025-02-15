import 'package:flutter/material.dart';
import 'package:nweekn/constants.dart';
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

  Future<void> logout() async {
    final ParseUser? user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      await user.logout();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        elevation: 4.0, // ✅ Adds a drop shadow
        shadowColor: Colors.black.withAlpha(128), // ✅ Set shadow color with opacity
        backgroundColor: Colors.white, // ✅ Set background color for better visibility
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black), // ✅ Ensure contrast
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xffc8c3c0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<Map<String, dynamic>?>(
                    future: userFuture, // ✅ Fetch user details from cloud function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Center(child: Text("No User Info"));
                      }

                      final userData = snapshot.data!;
                      final String username = userData['username'] ?? "User";
                      final dynamic profileImageData = userData['profileImage']; // Could be a Map

                      // ✅ Extract profile image URL correctly
                      String? profileImageUrl;
                      if (profileImageData is String) {
                        profileImageUrl = profileImageData; // Direct string URL
                      } else if (profileImageData is Map<String, dynamic>) {
                        profileImageUrl = profileImageData['url']; // Extract 'url' from ParseFile object
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(0xffebc642),
                            backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl) // ✅ Use the extracted profile image URL
                                : AssetImage("assets/people.png") as ImageProvider,
                          ),
                          SizedBox(height: 10),
                          Text(
                            username,
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ],
                      );
                    },
                  ),


                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.amber),
              title: Text("Edit Profile"),
              onTap: () async {
                // ✅ Wait for the user to return from the edit profile page
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                );

                // ✅ Refresh user data when returning
                setState(() {
                  userFuture = _getCurrentUser();
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.lightbulb_outline, color: Colors.amber), // ✅ Lamp Icon
              title: Text("The OWeekN Idea"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OWeekNIdeaPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.amber),
              title: Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // ✅ Background Image with Transparency
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     height: MediaQuery.of(context).size.height * 0.50,
          //     child: Stack(
          //       children: [
          //         Positioned.fill(
          //           child: Image.asset(
          //             'assets/placeholder.png',
          //             fit: BoxFit.cover,
          //           ),
          //         ),
          //         Positioned.fill(
          //           child: Container(
          //             color: Color.fromARGB(128, 255, 255, 255),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // ✅ Foreground Content (Cards start from the top)
          Column(
            children: [
              SizedBox(height: 40), // ✅ Add spacing from the top

              // ✅ Title (Inside Foreground Content)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Recent OWeekN Ideas",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
                        final postId = post['objectId'] as String; // ✅ Correctly access objectId from Map
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
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => PostDetailPage(post: post),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                          child: PostCard(
                            title: title,
                            username: username, // ✅ Correctly pass the username
                            imageUrl: postImageUrl ?? '',
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
  final String summary; // ✅ New summary field

  const PostCard({
    required this.title,
    required this.username,
    required this.imageUrl,
    required this.summary, // ✅ Accept summary
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Post Image at the Top
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.fitWidth, // ✅ Ensures the image fits properly
            )
                : Image.asset(
              'assets/photo-camera.png',
              width: double.infinity,
              height: 180,
              fit: BoxFit.fitWidth,
            ),
          ),

          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Post Title
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),

                // ✅ Username
                Text(
                  'Created by: $username',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 6),

                // ✅ Post Summary
                Text(
                  summary,
                  maxLines: 2, // ✅ Limit to 2 lines to keep layout clean
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


