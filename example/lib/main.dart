import 'package:cloud_firestore/cloud_firestore.dart';
import 'failure_screen.dart';
import 'home_screen.dart';
import 'loading_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firestore_flutter/firestore_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location tracker',
      home: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
            if (snapshot.hasError) {
              return FailureScreen(
                title: 'Can not initialize database',
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return HomeScreen(
                firestore:
                    FirestoreImpl.fromInstance(FirebaseFirestore.instance),
              );
            }
            return LoadingScreen(wrapScaffold: true);
          }),
    );
  }
}
