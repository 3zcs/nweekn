import 'package:flutter/material.dart';
import 'package:nweekn/constants.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UserProfilePage extends StatefulWidget {
  final String username; // ✅ Accept username as parameter

  const UserProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<ParseUser?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = fetchUserByUsername(widget.username); // ✅ Fetch user by username
  }

  Future<ParseUser?> fetchUserByUsername(String username) async {
    final query = QueryBuilder<ParseUser>(ParseUser.forQuery())
      ..whereEqualTo('username', username);

    final response = await query.query();

    if (response.success && response.results != null && response.results!.isNotEmpty) {
      return response.results!.first as ParseUser; // ✅ Return user object
    } else {
      return null; // No user found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ParseUser?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('User not found.'));
          }

          final user = snapshot.data!;
          final name = user.get<String>('name') ?? 'Unknown Name';
          final bio = user.get<String>('bio') ?? 'No Bio';

          final dynamic profileImageData = user.get('profileImage');
          String? profileImageUrl;
          if (profileImageData is ParseFile) {
            profileImageUrl = profileImageData.url;
          } else {
            profileImageUrl = AppConfig.imgUrl + user.get('profileImage');
          }

          return Stack(
            children: [
              // ✅ Background Image
              Container(
                height: MediaQuery.of(context).size.height * 0.53,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/location.png'), // ✅ Same background as Edit Profile
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ✅ Floating Back Button
              // ✅ Floating Back Button with Circular Background
              Positioned(
                top: 40, // ✅ Adjusted to fit under the status bar
                left: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(125, 0, 0, 0),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    onPressed: () {
                      Navigator.pop(context); // ✅ Go back to previous screen
                    },
                  ),
                ),
              ),

              // ✅ Profile Content
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.43), // ✅ Moved image lower

                  // ✅ Profile Image (Lowered for Better Fit)
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 65, // Slightly larger
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 60, // ✅ Ensures most of the image is visible
                        backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : AssetImage("assets/people.png") as ImageProvider,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // ✅ User Name
                  Text(
                    name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 16),

                  // ✅ Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      bio,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
