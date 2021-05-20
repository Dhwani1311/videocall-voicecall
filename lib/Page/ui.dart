import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voice/Page/Audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Video.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();
  final _nameController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole _role = ClientRole.Broadcaster;

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Video/Audio')),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                        controller: _channelController,
                        decoration: InputDecoration(
                          errorText:
                          _validateError ? 'Channel name can not empty' : null,
                          // border: UnderlineInputBorder(
                          //   borderSide: BorderSide(width: 1),
                          // ),
                          hintText: 'Channel name',
                        ),
                      ))

                ],
              ),

              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onJoinVideo,
                        child: Text(
                          'Join Videocall',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),

                        //color: Colors.blueAccent,
                        //textColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onJoinAudio,
                        child: Text(
                          'Join VoiceCall',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),

                        //color: Colors.blueAccent,
                        //textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoinVideo() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _permission(Permission.camera);
      await _permission(Permission.microphone);

      await Navigator
          .of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) =>
          CallPage(channelName: _channelController.text,role: _role,)));
    }
  }

  Future<void> onJoinAudio() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      //await _permission(Permission.camera);
      await _permission(Permission.microphone);
      // push video page with given channel name

      await Navigator
          .of(context)
          .pushReplacement(MaterialPageRoute(builder: (BuildContext context) => AudioPage(channelName: _channelController.text,role: _role,)));

    }
  }

  Future<void> _permission(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
