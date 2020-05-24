// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'tabs_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'test',
    options: const FirebaseOptions(
      googleAppID: '1:997323646333:android:7798d0da4ac8ea164cd814',
      // gcmSenderID: '79601577497',
      apiKey: 'AIzaSyAmNZ2kcLG27xbRYkEq4EHeSst_V2VNXrc',
      projectID: 'cartelera-tvc',
    ),
  );
  final Firestore firestore = Firestore(app: app);

  // runApp(MyApp());
  runApp(MaterialApp(
      title: 'Firestore Example', home: MyHomePage(firestore: firestore)));
}

class MessageList extends StatelessWidget {
  MessageList({this.firestore});

  final Firestore firestore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection("messages")
          .orderBy("created_at", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final int messageCount = snapshot.data.documents.length;
        return ListView.builder(
          itemCount: messageCount,
          itemBuilder: (_, int index) {
            final DocumentSnapshot document = snapshot.data.documents[index];
            final dynamic message = document['message'];
            return ListTile(
              trailing: IconButton(
                onPressed: () => document.reference.delete(),
                icon: Icon(Icons.delete),
              ),
              title: Text(
                message != null ? message.toString() : '<No message retrieved>',
              ),
              subtitle: Text('Message ${index + 1} of $messageCount'),
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({this.firestore});

  final Firestore firestore;

  CollectionReference get messages => firestore.collection('messages');

  Future<void> _addMessage() async {
    await messages.add(<String, dynamic>{
      'message': 'Hello world!',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _runTransaction() async {
    firestore.runTransaction((Transaction transaction) async {
      final allDocs = await firestore.collection("messages").getDocuments();
      final toBeRetrieved =
          allDocs.documents.sublist(allDocs.documents.length ~/ 2);
      final toBeDeleted =
          allDocs.documents.sublist(0, allDocs.documents.length ~/ 2);
      await Future.forEach(toBeDeleted, (DocumentSnapshot snapshot) async {
        await transaction.delete(snapshot.reference);
      });

      await Future.forEach(toBeRetrieved, (DocumentSnapshot snapshot) async {
        await transaction.update(snapshot.reference, {
          "message": "Updated from Transaction",
          "created_at": FieldValue.serverTimestamp()
        });
      });
    });

    await Future.forEach(List.generate(2, (index) => index), (item) async {
      await firestore.runTransaction((Transaction transaction) async {
        await Future.forEach(List.generate(10, (index) => index), (item) async {
          await transaction.set(firestore.collection("messages").document(), {
            "message": "Created from Transaction $item",
            "created_at": FieldValue.serverTimestamp()
          });
        });
      });
    });
  }

  Future<void> _runBatchWrite() async {
    final batchWrite = firestore.batch();
    final querySnapshot = await firestore
        .collection("messages")
        .orderBy("created_at")
        .limit(12)
        .getDocuments();
    querySnapshot.documents
        .sublist(0, querySnapshot.documents.length - 3)
        .forEach((DocumentSnapshot doc) {
      batchWrite.updateData(doc.reference, {
        "message": "Batched message",
        "created_at": FieldValue.serverTimestamp()
      });
    });
    batchWrite.setData(firestore.collection("messages").document(), {
      "message": "Batched message created",
      "created_at": FieldValue.serverTimestamp()
    });
    batchWrite.delete(
        querySnapshot.documents[querySnapshot.documents.length - 2].reference);
    batchWrite.delete(querySnapshot.documents.last.reference);
    await batchWrite.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Example'),
        actions: <Widget>[
          FlatButton(
            onPressed: _runTransaction,
            child: Text("Run Transaction"),
          ),
          FlatButton(
            onPressed: _runBatchWrite,
            child: Text("Batch Write"),
          )
        ],
      ),
      body: MessageList(firestore: firestore),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMessage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}


// class MyApp extends StatelessWidget {
//   static FirebaseAnalytics analytics = FirebaseAnalytics();
//   static FirebaseAnalyticsObserver observer =
//       FirebaseAnalyticsObserver(analytics: analytics);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Firebase Analytics Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       navigatorObservers: <NavigatorObserver>[observer],
//       home: MyHomePage(
//         title: 'Firebase Analytics Demo',
//         analytics: analytics,
//         observer: observer,
//       ),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title, this.analytics, this.observer})
//       : super(key: key);

//   final String title;
//   final FirebaseAnalytics analytics;
//   final FirebaseAnalyticsObserver observer;

//   @override
//   _MyHomePageState createState() => _MyHomePageState(analytics, observer);
// }

// class _MyHomePageState extends State<MyHomePage> {
//   _MyHomePageState(this.analytics, this.observer);

//   final FirebaseAnalyticsObserver observer;
//   final FirebaseAnalytics analytics;
//   String _message = '';

//   void setMessage(String message) {
//     setState(() {
//       _message = message;
//     });
//   }

//   Future<void> _sendAnalyticsEvent() async {
//     await analytics.logEvent(
//       name: 'test_event',
//       parameters: <String, dynamic>{
//         'string': 'string',
//         'int': 42,
//         'long': 12345678910,
//         'double': 42.0,
//         'bool': true,
//       },
//     );
//     setMessage('logEvent succeeded');
//   }

//   Future<void> _testSetUserId() async {
//     await analytics.setUserId('some-user');
//     setMessage('setUserId succeeded');
//   }

//   Future<void> _testSetCurrentScreen() async {
//     await analytics.setCurrentScreen(
//       screenName: 'Analytics Demo',
//       screenClassOverride: 'AnalyticsDemo',
//     );
//     setMessage('setCurrentScreen succeeded');
//   }

//   Future<void> _testSetAnalyticsCollectionEnabled() async {
//     await analytics.setAnalyticsCollectionEnabled(false);
//     await analytics.setAnalyticsCollectionEnabled(true);
//     setMessage('setAnalyticsCollectionEnabled succeeded');
//   }

//   Future<void> _testSetSessionTimeoutDuration() async {
//     await analytics.android?.setSessionTimeoutDuration(2000000);
//     setMessage('setSessionTimeoutDuration succeeded');
//   }

//   Future<void> _testSetUserProperty() async {
//     await analytics.setUserProperty(name: 'regular', value: 'indeed');
//     setMessage('setUserProperty succeeded');
//   }

//   Future<void> _testAllEventTypes() async {
//     await analytics.logAddPaymentInfo();
//     await analytics.logAddToCart(
//       currency: 'USD',
//       value: 123.0,
//       itemId: 'test item id',
//       itemName: 'test item name',
//       itemCategory: 'test item category',
//       quantity: 5,
//       price: 24.0,
//       origin: 'test origin',
//       itemLocationId: 'test location id',
//       destination: 'test destination',
//       startDate: '2015-09-14',
//       endDate: '2015-09-17',
//     );
//     await analytics.logAddToWishlist(
//       itemId: 'test item id',
//       itemName: 'test item name',
//       itemCategory: 'test item category',
//       quantity: 5,
//       price: 24.0,
//       value: 123.0,
//       currency: 'USD',
//       itemLocationId: 'test location id',
//     );
//     await analytics.logAppOpen();
//     await analytics.logBeginCheckout(
//       value: 123.0,
//       currency: 'USD',
//       transactionId: 'test tx id',
//       numberOfNights: 2,
//       numberOfRooms: 3,
//       numberOfPassengers: 4,
//       origin: 'test origin',
//       destination: 'test destination',
//       startDate: '2015-09-14',
//       endDate: '2015-09-17',
//       travelClass: 'test travel class',
//     );
//     await analytics.logCampaignDetails(
//       source: 'test source',
//       medium: 'test medium',
//       campaign: 'test campaign',
//       term: 'test term',
//       content: 'test content',
//       aclid: 'test aclid',
//       cp1: 'test cp1',
//     );
//     await analytics.logEarnVirtualCurrency(
//       virtualCurrencyName: 'bitcoin',
//       value: 345.66,
//     );
//     await analytics.logEcommercePurchase(
//       currency: 'USD',
//       value: 432.45,
//       transactionId: 'test tx id',
//       tax: 3.45,
//       shipping: 5.67,
//       coupon: 'test coupon',
//       location: 'test location',
//       numberOfNights: 3,
//       numberOfRooms: 4,
//       numberOfPassengers: 5,
//       origin: 'test origin',
//       destination: 'test destination',
//       startDate: '2015-09-13',
//       endDate: '2015-09-14',
//       travelClass: 'test travel class',
//     );
//     await analytics.logGenerateLead(
//       currency: 'USD',
//       value: 123.45,
//     );
//     await analytics.logJoinGroup(
//       groupId: 'test group id',
//     );
//     await analytics.logLevelUp(
//       level: 5,
//       character: 'witch doctor',
//     );
//     await analytics.logLogin();
//     await analytics.logPostScore(
//       score: 1000000,
//       level: 70,
//       character: 'tiefling cleric',
//     );
//     await analytics.logPresentOffer(
//       itemId: 'test item id',
//       itemName: 'test item name',
//       itemCategory: 'test item category',
//       quantity: 6,
//       price: 3.45,
//       value: 67.8,
//       currency: 'USD',
//       itemLocationId: 'test item location id',
//     );
//     await analytics.logPurchaseRefund(
//       currency: 'USD',
//       value: 45.67,
//       transactionId: 'test tx id',
//     );
//     await analytics.logSearch(
//       searchTerm: 'hotel',
//       numberOfNights: 2,
//       numberOfRooms: 1,
//       numberOfPassengers: 3,
//       origin: 'test origin',
//       destination: 'test destination',
//       startDate: '2015-09-14',
//       endDate: '2015-09-16',
//       travelClass: 'test travel class',
//     );
//     await analytics.logSelectContent(
//       contentType: 'test content type',
//       itemId: 'test item id',
//     );
//     await analytics.logShare(
//         contentType: 'test content type',
//         itemId: 'test item id',
//         method: 'facebook');
//     await analytics.logSignUp(
//       signUpMethod: 'test sign up method',
//     );
//     await analytics.logSpendVirtualCurrency(
//       itemName: 'test item name',
//       virtualCurrencyName: 'bitcoin',
//       value: 34,
//     );
//     await analytics.logTutorialBegin();
//     await analytics.logTutorialComplete();
//     await analytics.logUnlockAchievement(id: 'all Firebase API covered');
//     await analytics.logViewItem(
//       itemId: 'test item id',
//       itemName: 'test item name',
//       itemCategory: 'test item category',
//       itemLocationId: 'test item location id',
//       price: 3.45,
//       quantity: 6,
//       currency: 'USD',
//       value: 67.8,
//       flightNumber: 'test flight number',
//       numberOfPassengers: 3,
//       numberOfRooms: 1,
//       numberOfNights: 2,
//       origin: 'test origin',
//       destination: 'test destination',
//       startDate: '2015-09-14',
//       endDate: '2015-09-15',
//       searchTerm: 'test search term',
//       travelClass: 'test travel class',
//     );
//     await analytics.logViewItemList(
//       itemCategory: 'test item category',
//     );
//     await analytics.logViewSearchResults(
//       searchTerm: 'test search term',
//     );
//     setMessage('All standard events logged successfully');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Column(
//         children: <Widget>[
//           MaterialButton(
//             child: const Text('Test logEvent'),
//             onPressed: _sendAnalyticsEvent,
//           ),
//           MaterialButton(
//             child: const Text('Test standard event types'),
//             onPressed: _testAllEventTypes,
//           ),
//           MaterialButton(
//             child: const Text('Test setUserId'),
//             onPressed: _testSetUserId,
//           ),
//           MaterialButton(
//             child: const Text('Test setCurrentScreen'),
//             onPressed: _testSetCurrentScreen,
//           ),
//           MaterialButton(
//             child: const Text('Test setAnalyticsCollectionEnabled'),
//             onPressed: _testSetAnalyticsCollectionEnabled,
//           ),
//           MaterialButton(
//             child: const Text('Test setSessionTimeoutDuration'),
//             onPressed: _testSetSessionTimeoutDuration,
//           ),
//           MaterialButton(
//             child: const Text('Test setUserProperty'),
//             onPressed: _testSetUserProperty,
//           ),
//           Text(_message,
//               style: const TextStyle(color: Color.fromARGB(255, 0, 155, 0))),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//           child: const Icon(Icons.tab),
//           onPressed: () {
//             Navigator.of(context).push(MaterialPageRoute<TabsPage>(
//                 settings: const RouteSettings(name: TabsPage.routeName),
//                 builder: (BuildContext context) {
//                   return TabsPage(observer);
//                 }));
//           }),
//     );
//   }
// }