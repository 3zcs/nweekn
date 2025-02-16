import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/HomePage.dart';
import 'screens/LoginScreen.dart';
import 'package:nweekn/intro/introduction_animation_screen.dart';
import 'package:nweekn/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(
    AppConfig.appId,
    AppConfig.serverUrl,
    clientKey: AppConfig.clientKey, // Optional
    autoSendSessionId: true, // Enable sessions
  );




  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> hasSeenIntro() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenIntro') ?? false;
  }

  Future<ParseUser?> _getCurrentUser() async {
    final user = await ParseUser.currentUser();
    return user as ParseUser?;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OWeekN',
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
      home: FutureBuilder<bool>(
        future: hasSeenIntro(),
        builder: (context, introSnapshot) {
    if (introSnapshot.connectionState == ConnectionState.waiting) {
    return Scaffold(body: Center(child: CircularProgressIndicator())); // ✅ Loading state
    }
    if (introSnapshot.hasError) {
    return Scaffold(body: Center(child: Text("Error loading data!"))); // ✅ Handle errors
    }

    // ✅ Show Intro Screen if it hasn't been seen
    if (introSnapshot.data == false) {
    return IntroductionAnimationScreen();
    }

    // ✅ After intro, check if user is authenticated
    return FutureBuilder<ParseUser?>(
    future: _getCurrentUser(),
    builder: (context, authSnapshot) {
    if (authSnapshot.connectionState == ConnectionState.waiting) {
    return Scaffold(body: Center(child: CircularProgressIndicator())); // ✅ Loading state
    }
    if (authSnapshot.hasData && authSnapshot.data != null) {
    return HomePage(); // ✅ User is authenticated
    } else {
    return LoginScreen(); // ✅ User is not authenticated
    }
    },
    );
    //title: 'Flutter Demo Home Page'
    },
      ),
    );
  }
}





