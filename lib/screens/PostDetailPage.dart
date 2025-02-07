import 'package:flutter/material.dart';
import 'package:nweekn/screens/UserProfilePage.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

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
      ..whereEqualTo('objectId', postId);

    final response = await query.query();

    if (response.success && response.results != null && response.results!.isNotEmpty) {
      return response.results!.first as ParseObject;
    } else {
      return null; // Post not found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post Details')),
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
          final createdBy = post.get<String>('createdBy') ?? 'Unknown User';
          final postSummary = post.get<String>('postSummary') ?? 'No Summary';


          final dynamic postImageData = post.get('postImage');
          String? postImageUrl;
          if (postImageData is ParseFile) {
            postImageUrl = postImageData.url;
          } else {
            postImageUrl = post.get('postImage');
          }

          // ✅ Get Sections from Post
          final dynamic sectionsData = post.get<List<dynamic>>('sections') ?? [];
          List<Map<String, dynamic>> sections = [];

          if (sectionsData is List) {
            sections = List<Map<String, dynamic>>.from(sectionsData);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Post Image
                if (postImageUrl != null && postImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              postImageUrl,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Color.fromARGB(102, 0, 0, 0),  // ✅ ARGB alternative (102 = 40% opacity)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 16),

                // ✅ Post Title
                Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 8),

                // ✅ Username
                Row(
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
                            builder: (context) => UserProfilePage(username: createdBy), // ✅ Pass username
                          ),
                        );
                      },
                      child: Text(
                        createdBy,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue, // ✅ Make it look clickable
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),


                Text(
                  postSummary,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                ),
                SizedBox(height: 16),

                SizedBox(height: 20),

                // ✅ Display Sections
                if (sections.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sections',
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

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ Section Image
                                if (sectionImageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      sectionImageUrl,
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
              ],
            ),
          );
        },
      ),
    );
  }


}
