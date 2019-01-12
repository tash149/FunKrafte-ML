import 'dart:io';

import 'package:flutter/material.dart';
import 'package:funkrafte/data/app_data.dart';
import 'package:funkrafte/data/firebase.dart';
import 'package:funkrafte/data/post.dart';

import 'buttons.dart';

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(Icons.edit),
          ),
          Text("New Post")
        ]),
        centerTitle: true,
      ),
      body: PostForm(),
    );
  }
}

class PostForm extends StatefulWidget {
  @override
  PostFormState createState() {
    return PostFormState();
  }
}

class PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();
  String imageUrl;
  File file;
  String caption;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppData().scaleFactorA * 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: file == null
                    ? Text("No image selected.")
                    : Image.file(
                        file,
                        height: 300.0,
                      ),
              ),
              Center(
                child: UploadImageButton(
                    onPressed: () => getImage().then((value) {
                          file = value;
                          setState(() {});
                        })),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Caption"),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Caption cannot be empty!';
                  } else {
                    caption = value;
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      if (file == null)
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text('Please select an image!')));
                      else {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text('Uploading content')));
                        uploadImage(file).then((value) {
                          Post(
                              imageUrl: value,
                              caption: caption,
                              uid: UserData().user.uid);
                        });
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
