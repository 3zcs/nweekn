import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<ParseUser?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = fetchUser(widget.userId);
  }

  Future<ParseUser?> fetchUser(String userId) async {
    final query = QueryBuilder<ParseUser>(ParseUser.forQuery())
      ..whereEqualTo('objectId', userId);

    final response = await query.query();

    if (response.success && response.results != null && response.results!.isNotEmpty) {
      return response.results!.first as ParseUser;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: FutureBuilder<ParseUser?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('User not found.'));
          }

          final user = snapshot.data!;
          final username = user.get<String>('username') ?? 'Unknown User';
          final email = user.get<String>('email') ?? 'No Email';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Email: $email',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                  ),
                ),
                // Add additional user details here
              ],
            ),
          );
        },
      ),
    );
  }
}
