import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'CreatePostPage.dart';
import 'LoginScreen.dart';
import 'PostDetailPage.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   late Future<List<ParseObject>> postsFuture;
//
//   Future<void> logout(BuildContext context) async {
//     final ParseUser user = await ParseUser.currentUser() as ParseUser;
//     if (user != null) {
//       await user.logout();
//     }
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => LoginScreen()),
//     );
//   }
//
//   Future<List<ParseObject>> fetchPosts() async {
//     final queryPosts = QueryBuilder<ParseObject>(ParseObject('Posts'))
//       ..includeObject(['user']); // Include the user object in the results
//
//     final response = await queryPosts.query();
//
//     if (response.success && response.results != null) {
//       return response.results as List<ParseObject>;
//     } else {
//       throw Exception('Failed to fetch posts: ${response.error?.message}');
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     postsFuture = fetchPosts();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () => logout(context),
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<ParseObject>>(
//         future: postsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No posts available.'));
//           }
//
//           final posts = snapshot.data!;
//
//           return PageView.builder(
//             itemCount: posts.length,
//             controller: PageController(viewportFraction: 0.8),
//             itemBuilder: (context, index) {
//               final post = posts[index];
//               final postId = post.objectId!;
//               final title = post.get<String>('postTitle') ?? 'No Title';
//               final user = post.get<ParseUser>('user');
//               final username =
//                   user?.get<String>('username') ?? 'Unknown User';
//
//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => PostDetailPage(postId: postId),
//                     ),
//                   );
//                 },
//                 child: AnimatedCard(
//                   title: title,
//                   username: username,
//                   index: index,
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => CreatePostPage()),
//           );
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
//
// class AnimatedCard extends StatelessWidget {
//   final String title;
//   final String username;
//   final int index;
//
//   const AnimatedCard({
//     required this.title,
//     required this.username,
//     required this.index,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final cardWidth = constraints.maxWidth;
//         final cardHeight = constraints.maxHeight * 0.6;
//         final rotationAngle = index == 1 ? 0.0 : (index % 2 == 0 ? -0.1 : 0.1);
//
//
//         return Transform.rotate(
//           angle: rotationAngle,
//           child: Container(
//             margin: EdgeInsets.symmetric(vertical: 20),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 10,
//                   offset: Offset(0, 5),
//                 ),
//               ],
//               color: Colors.white,
//             ),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                     child: Container(
//                       color: Colors.grey[300],
//                       child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 18.0,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 8.0),
//                       Text(
//                         'Created by: $username',
//                         style: TextStyle(
//                           fontSize: 14.0,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
//


import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'Beef', 'image': Icons.food_bank},
      {'title': 'Chicken', 'image': Icons.local_dining},
      {'title': 'Dessert', 'image': Icons.cake},
      {'title': 'Fruits', 'image': Icons.apple},
      {'title': 'Drinks', 'image': Icons.local_drink},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Horizontal Cards'),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Foreground Content
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.45 - 50), // Adjust overlap height
              Container(
                height: 300,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: items.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                        } else {
                          value = _pageController.initialPage - index.toDouble();
                        }
                        value = (1 - (value.abs() * 0.3)).clamp(0.8, 1.0);

                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          print('Card ${items[index]['title']} tapped');
                        },
                        child: Card(
                          elevation: 6.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                items[index]['image'] as IconData,
                                size: 80,
                                color: Colors.grey[700],
                              ),
                              SizedBox(height: 20),
                              Text(
                                items[index]['title'] as String,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              SmoothPageIndicator(
                controller: _pageController,
                count: items.length,
                effect: SwapEffect(
                  activeDotColor: Colors.blue,
                  dotColor: Colors.grey,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'More Content Here',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
