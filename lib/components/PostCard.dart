import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reach_me/models/Post.dart';
import 'package:reach_me/services/database.dart';

class PostCard extends StatefulWidget {
  final Post post;
  PostCard({this.post});
  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Database db = Database();
  String convertTime(Timestamp timestamp) {
    Timestamp currentTimestamp = Timestamp.now();
    int diff = currentTimestamp.millisecondsSinceEpoch -
        timestamp.millisecondsSinceEpoch;
    double diff1;
    String time;
    if (diff > 60000 * 60 * 24 * 365) {
      diff1 = diff / (60000 * 60 * 24 * 365);
      if (diff1.toStringAsFixed(0) == "1") {
        time = diff1.toStringAsFixed(0) + " year ago";
      } else
        time = diff1.toStringAsFixed(0) + " years ago";
    } else if (diff > 60000 * 60 * 24) {
      diff1 = diff / (60000 * 60 * 24);
      if (diff1.toStringAsFixed(0) == "1") {
        time = diff1.toStringAsFixed(0) + " day ago";
      } else
        time = diff1.toStringAsFixed(0) + " days ago";
    } else if (diff >= 60000 * 60) {
      diff1 = diff / (60000 * 60);
      if (diff1.toStringAsFixed(0) == "1") {
        time = diff1.toStringAsFixed(0) + " hour ago";
      } else
        time = diff1.toStringAsFixed(0) + " hours ago";
    } else if (diff >= 60000) {
      diff1 = diff / 60000;
      if (diff1.toStringAsFixed(0) == "1") {
        time = diff1.toStringAsFixed(0) + " minute ago";
      } else
        time = diff1.toStringAsFixed(0) + " minutes ago";
    } else {
      diff1 = diff / 1000;
      if (diff1.toStringAsFixed(0) == "1") {
        time = diff1.toStringAsFixed(0) + " second ago";
      } else
        time = diff1.toStringAsFixed(0) + " seconds ago";
    }
    return (time);
  }

  void Like(){

  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    bool isLiked = widget.post.likes.contains(user.uid);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
      child: Material(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 20,
                    child: ClipOval(
                      child: Image.network(
                        widget.post.userphoto,
                      ),
                    ),
                    // backgroundImage: NetworkImage(user.photoUrl),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.post.username,
                  ),
                ),
              ],
            ),
            Image.network(widget.post.photoUrl),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.post.text,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.comment,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Icon(
                          isLiked == true?Icons.favorite:Icons.favorite_border,
                        ),
                        onPressed: (){
                            db.likeAndUnlikePost(user.uid, widget.post.uid, widget.post.id).then((value) => setState((){
                              print(value);
                              isLiked = value;
                            }));
                        },
                      ),
                    ),
                    Text(
                      widget.post.likes.length.toString()
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.share,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    convertTime(widget.post.postTime),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}