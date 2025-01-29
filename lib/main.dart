import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'screens/HomePage.dart';
import 'screens/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Parse
  const String appId = "nweeknid"; // Replace with your Parse App ID
  //const String serverUrl = "http://192.168.68.247:1337/parse"; // Replace with your server URL
  const String serverUrl = "http://172.20.10.2:1337/parse"; // Replace with your server URL

  await Parse().initialize(
    appId,
    serverUrl,
    clientKey: null, // Optional
    autoSendSessionId: true, // Enable sessions
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<ParseUser?>(
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            return HomePage(); // User is authenticated, navigate to HomePage
          } else {
            return LoginScreen(); // User is not authenticated, navigate to LoginScreen
          }
        },
      )
          //title: 'Flutter Demo Home Page'

    );
  }

  Future<ParseUser?> _getCurrentUser() async {
    final user = await ParseUser.currentUser();
    return user as ParseUser?;
  }
}





