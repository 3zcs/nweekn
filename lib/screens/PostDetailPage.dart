import 'package:flutter/material.dart';
import 'package:nweekn/screens/UserProfilePage.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  final String title;

  const PostDetailPage({required this.postId, required this.title, Key? key}) : super(key: key);

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title.length > 15 ? '${widget.title.substring(0, 15)}...' : widget.title, // ✅ Shorten if too long
          style: TextStyle(fontWeight: FontWeight.bold), // ✅ Keep it clear
        ),
        centerTitle: true,
        elevation: 4.0, // ✅ Adds a drop shadow like Home
        shadowColor: Colors.black.withAlpha(128), // ✅ Soft shadow
        backgroundColor: Colors.white, // ✅ Keeps a clean design
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // ✅ Matches Home Style
          onPressed: () {
            Navigator.pop(context); // ✅ Navigates back
          },
        ),
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
                              builder: (context) => UserProfilePage(username: createdBy),
                            ),
                          );
                        },
                        child: Text(
                          createdBy,
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
          );


        },
      ),
    );
  }


}
