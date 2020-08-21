import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reach_me/models/Post.dart';
import 'package:reach_me/screens/home.dart';
import 'package:reach_me/services/database.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final Function callBack;
  PostCard({this.post,this.callBack});
  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int len = 0;
  bool like = false;
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
  bool LikedOrNot(String uid,List likes){
    bool isLiked = likes.contains(uid);
    return isLiked;
  }

  bool firstTime = true;

  @override
  Widget build(BuildContext context) {

    var user = Provider.of<FirebaseUser>(context);
    List likes = [];

    if(firstTime){
      print("FT: "+widget.post.likes.toString());
      setState(() {
        len = widget.post.likes.length;
        like = widget.post.likes.contains(user.uid);
      });
      firstTime = false;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.only(
          bottomLeft: const Radius.circular(12.0),
          bottomRight: const Radius.circular(12.0),
        ),
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
                  padding: const EdgeInsets.fromLTRB(8.0,0,0,0),
                  child: Text(
                    widget.post.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0,0,8.0,8.0),
              child: GestureDetector(
                child: Image.network(widget.post.photoUrl,fit: BoxFit.cover,
                  loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null ?
                        loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                            : null,
                      ),
                    );
                  },
                ),
                onDoubleTap: () async{
                  likes = await db.likeAPost(user.uid, widget.post.uid, widget.post.id);
                  widget.post.likes = likes;
                  setState(() {
                    like = LikedOrNot(user.uid,likes);
                    len = likes.length;
                    print("LIKE: "+like.toString());
                    likes.forEach((element) {
                      print("ELEMENT: "+element);
                    });
                  });
                },
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.post.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.post.text,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,4.0,8.0,8.0),
                  child: IconButton(
                    icon: like?Icon(
                      Icons.favorite,
                      size: 30,
                      color: Color(0xfffb3958),
                    ):Icon(
                      Icons.favorite_border,
                      size: 30,
                    ),
                    onPressed: () async{
//                          print(widget.post.likes);
//                          db.likeAndUnlikePost(user.uid, widget.post.uid, widget.post.id).then((value) => setState((){
//                            i++;
//                            print(value);
//                            isLiked = value;
//                          }));
                      likes = await db.likeAndUnlikePost(user.uid, widget.post.uid, widget.post.id);
                      widget.post.likes = likes;
                      setState(() {
                        like = LikedOrNot(user.uid,likes);
                        len = likes.length;
                        likes.forEach((element) {
                          print("ELEMENT: "+element);
                        });
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,8.0),
                  child: Icon(
                    Icons.comment,
                    size: 30,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0,4.0,8.0,8.0),
                  child: Icon(
                    Icons.share,
                    size: 30,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0,0,0,8.0),
                  child: Text(
                      len==1?len.toString()+" like":len.toString()+" likes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0,8.0,0,8.0),
              child: Text(
                convertTime(widget.post.postTime),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
