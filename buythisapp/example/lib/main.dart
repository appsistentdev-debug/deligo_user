// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, deprecated_member_use

import 'package:buy_this_app/buy_this_app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy this app example'),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ///will open the page
          BuyThisApp.button('app name', 'code canyon url'),

          SizedBox(height: 20),

          ///will directly launch code canyon
          BuyThisApp.button(
            'app name',
            'code canyon url',
            color: Colors.green,
            target: Target.CodeCanyon,
          ),

          SizedBox(height: 20),

          ///will directly launch whatsapp
          BuyThisApp.button(
            'app name',
            'code canyon url',
            color: Colors.pinkAccent,
            target: Target.WhatsApp,
          ),

          SizedBox(height: 20),

          ///will show subscribe dialog
          TextButton(
            onPressed: () => BuyThisApp.showSubscribeDialog(context),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            child: Text(
              'Show Dialog',
              style: TextStyle(color: Colors.white),
            ),
          ),

          SizedBox(height: 20),

          ///will show the developer row
          BuyThisApp.developerRow(Colors.white, Colors.black),
        ],
      ),
    );
  }
}
