import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:flutter_voice/Page/ui.dart';
import '../utils/util.dart';

class AudioPage extends StatefulWidget {

  final String channelName;
  final ClientRole role;
  const AudioPage({Key key, this.channelName,this.role}) : super(key: key);

  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final _users = <int>[];
  final _info = <String>[];
  bool muted = false;
  RtcEngine _engine;

  @override
  void initState() {
    super.initState();

    initialize();
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _info.add(
          'missing App ID',
        );
        _info.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgora();
    _addAgoraEventHandlers();
    await _engine.joinChannel(Token, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgora() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableAudio();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _info.add(info);
      });
    },
        joinChannelSuccess: (channel, uid, elapsed) {
          setState(() {
            final info = 'onJoinChannel: $channel, uid: $uid';
            _info.add(info);
            print(elapsed);
          });
        },
        leaveChannel: (stats) {
          setState(() {
            _info.add('onLeaveChannel');
            _users.clear();
          });
        },
        userJoined: (uid, elapsed) {
          setState(() {
            final info = 'userJoined: $uid';
            _info.add(info);
            _users.add(uid);
            print(uid);
          });
        },
        userOffline: (uid,elapsed) {
          setState(() {
            final info = 'userOffline: $uid';
            _info.add(info);
            _users.remove(uid);
          });
        },
        firstRemoteVideoFrame: (uid, width, height, elapsed) {
          setState(() {
            final info = 'firstRemoteVideo: $uid ${width}x $height';
            _info.add(info);
          });
        }));
  }

  /// Toolbar layout
  Widget _toolbar() {
    //if (widget.role == ClientRole.Audience) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
        ],
      ),
    );

  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
     // padding: const EdgeInsets.symmetric(vertical: 50),
      alignment: Alignment.center,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: ListView.builder(
            reverse: true,
            itemCount: _info.length,
            itemBuilder: (BuildContext context, int index) {
              if (_info.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                //  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _info[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    //Navigator.pop(context);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>IndexPage()));
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Audio')),),
      body: Stack(
             children:<Widget>[
              _panel(),
              _toolbar()
            ],
          ),
    );
  }
}