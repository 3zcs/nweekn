import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'UserProfilePage.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late Future<ParseObject?> postFuture;

  @override
  void initState() {
    super.initState();
    postFuture = fetchPost(widget.postId);
  }

  Future<ParseObject?> fetchPost(String postId) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Posts'))
      ..whereEqualTo('objectId', postId)
      ..includeObject(['user']); // Include the user object

    final response = await query.query();

    if (response.success && response.results != null && response.results!.isNotEmpty) {
      return response.results!.first as ParseObject;
    } else {
      return null; // Post not found or fetch failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: FutureBuilder<ParseObject?>(
        future: postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Post not found.'));
          }

          final post = snapshot.data!;
          final title = post.get<String>('postTitle') ?? 'No Title';
          final sections = post.get<List<dynamic>>('sections') ?? [];
          final user = post.get<ParseUser>('user');
          final username = user?.get<String>('username') ?? 'Unknown User';
          final userId = user?.objectId ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
            GestureDetector(
              onTap: () {
                if (userId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(userId: userId),
                    ),
                  );
                }
              },
               child: Text(
                  'By: $username',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                  ),
                ),
            ),
                SizedBox(height: 16.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index] as Map<String, dynamic>;
                      final sectionTime = section['time'] ?? 'No Time';
                      final sectionTitle = section['title'] ?? 'No Title';
                      final sectionContent = section['content'] ?? 'No Content';

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 2.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time: $sectionTime',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                sectionTitle,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                sectionContent,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
