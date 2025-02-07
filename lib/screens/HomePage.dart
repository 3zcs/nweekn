import 'package:flutter/material.dart';
import 'package:nweekn/constants.dart';
import 'package:nweekn/screens/CreatePostPage.dart';
import 'package:nweekn/screens/PostDetailPage.dart';
import 'package:nweekn/screens/ProfileEditScreen.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'LoginScreen.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<ParseObject>> postsFuture;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    print("Initializing Page Controller");
    _pageController = PageController(viewportFraction: 0.6);
    postsFuture = fetchPosts();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<List<ParseObject>> fetchPosts() async {
    print("Fetching Posts from Backend...");
    final queryPosts = QueryBuilder<ParseObject>(ParseObject('Posts'))
      ..includeObject(['user']);

    final response = await queryPosts.query();

    if (response.success && response.results != null) {
      print("Posts Fetched: ${response.results!.length}");
      return response.results as List<ParseObject>;
    } else {
      print("Failed to fetch posts: ${response.error?.message}");
      return []; // Return empty list to avoid null errors
    }
  }

  Future<bool> isUserLoggedIn() async {
    final dynamic currentUser = await ParseUser.currentUser();
    final ParseUser? user = currentUser is ParseUser ? currentUser : null;

    return user != null;
  }

  void checkLoginStatus() async {
    bool loggedIn = await isUserLoggedIn();
    if (!loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      postsFuture = fetchPosts();
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

  Future<ParseUser?> _getCurrentUser() async {
    final dynamic currentUser = await ParseUser.currentUser();
    return currentUser is ParseUser ? currentUser : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
    leading: Builder( // ✅ Fix: Use Builder to get the correct context
    builder: (context) {
    return IconButton(
    icon: Icon(Icons.menu),
    onPressed: () {
      Scaffold.of(context).openDrawer();
      },
    );// Open Drawer Menu
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
                  FutureBuilder<ParseUser?>(
                    future: _getCurrentUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Center(child: Text("No User Info"));
                      }

                      final user = snapshot.data!;
                      final username = user.get<String>('name') ?? "User";
                      final email = user.get<String>('email') ?? "No Email";

                      final dynamic profileImageData = user.get('profileImage'); // profileImage
                      String? profileImageUrl;

                      if (profileImageData is ParseFile) {
                        profileImageUrl = profileImageData.url; // ✅ Extract URL
                      } else {
                        profileImageUrl = user.get('profileImage');
                      }

                      print("profile $profileImageUrl $user");

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xffebc642),
                            backgroundImage: profileImageUrl != null
                                ? NetworkImage(AppConfig.imgUrl + profileImageUrl)
                                : AssetImage("assets/people.png") as ImageProvider,
                          ),
                          SizedBox(height: 10),
                          Text(username, style: TextStyle(color: Colors.black, fontSize: 18)),
                          Text(email, style: TextStyle(color: Colors.black, fontSize: 14)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Edit Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // ✅ Background Image with Transparency
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.50,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/placeholder.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Color.fromARGB(128, 255, 255, 255),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Foreground Content (Cards start from the top)
          Column(
            children: [
              // ✅ REMOVE extra spacing here!
              Expanded(
                child: FutureBuilder<List<ParseObject>>(
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
                        final postId = post.objectId!;
                        final title = post.get<String>('postTitle') ?? 'No Title';
                        final username = post.get<String>('createdBy') ?? 'Unknown User';
                        final dynamic postImageData = post.get('postImage');

                        // ✅ Get Image URL
                        String? postImageUrl;
                        if (postImageData is ParseFile) {
                          postImageUrl = postImageData.url;
                        } else {
                          postImageUrl = post.get('postImage');
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              // MaterialPageRoute(
                              //   builder: (context) => PostDetailPage(postId: postId),
                              // ),
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => PostDetailPage(postId: postId),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                          child: PostCard(
                            title: title,
                            username: username,
                            imageUrl: postImageUrl ?? '',
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostPage()),
          );
          refreshData(); // ✅ Refresh posts after returning
        },
        backgroundColor: Color(0xff132137),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void refreshData() {
    setState(() {
      postsFuture = fetchPosts(); // ✅ Refresh post list
    });
  }
}

/// Post Card UI
class PostCard extends StatelessWidget {
  final String title;
  final String username;
  final String imageUrl;

  const PostCard({
    required this.title,
    required this.username,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Image.asset(
              'assets/photo-camera.png',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

