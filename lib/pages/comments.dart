import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:icilome_mobile/common/screen_arguments.dart';
import 'package:icilome_mobile/models/Comment.dart';
import 'package:icilome_mobile/widgets/commentBox.dart';
import 'package:loading/indicator/ball_beat_indicator.dart';
import 'package:loading/loading.dart';

import 'add_comment.dart';

Future<List<dynamic>> fetchComments(int id) async {
  try {
    var response = await http.get(
        "https://demo.icilome.net/wp-json/wp/v2/comments?post=" +
            id.toString());

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map((m) => Comment.fromJson(m))
          .toList();
    } else {
      throw "Error loading posts";
    }
  } on SocketException {
    throw 'No Internet connection';
  }
}

class Comments extends StatefulWidget {
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    final CommentScreenArguments args =
        ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Commentaires',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Poppins')),
        elevation: 5,
        backgroundColor: Colors.white,
      ),
      body: Container(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
              children: <Widget>[commentSection(fetchComments(args.id))]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddComment(),
                  fullscreenDialog: true,
                  settings: RouteSettings(
                    arguments: CommentScreenArguments(args.id),
                  )));
        },
        child: Icon(Icons.add_comment),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

Widget commentSection(Future<List<dynamic>> comments) {
  return FutureBuilder<List<dynamic>>(
    future: comments,
    builder: (context, commentSnapshot) {
      if (commentSnapshot.hasData) {
        if (commentSnapshot.data.length == 0) return Container();
        return Column(
            children: commentSnapshot.data.map((item) {
          return InkWell(
            onTap: () {},
            child: commentBox(context, item.author, item.avatar, item.content),
          );
        }).toList());
      } else if (commentSnapshot.hasError) {
        return Container(
            height: 500,
            alignment: Alignment.center,
            child: Text("${commentSnapshot.error}"));
      }
      return Container(
        alignment: Alignment.center,
        height: 400,
        child: Loading(
            indicator: BallBeatIndicator(),
            size: 60.0,
            color: Colors.redAccent),
      );
    },
  );
}
