import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twich_clone/model/my_stream.dart';
import 'package:twich_clone/resource/firestore_meth.dart';

import 'chat_widget.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen(
      {required this.isBroadcaster,
      required this.channelName,
      required this.channelTitle,
      super.key});
  final bool isBroadcaster;
  final String channelName;
  final String channelTitle;

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine;
  bool _localUserJoined = false;
  List<int> users = [];
  bool isMuted = false;
  late String id;

  @override
  void initState() {
    super.initState();
    id = widget.channelTitle.toString();
    _initEngin();
  }

  void _initEngin() async {
    await [Permission.microphone, Permission.camera].request();

    if (!widget.isBroadcaster) {
      await FireStoreMeth().updateViewCount(widget.channelName, true);
    }
    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
        appId: MyStream.appID,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            users.add(remoteUid);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('$remoteUid \n $users')));
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            users.removeWhere((element) => element == remoteUid);
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint("leave Channel");
          setState(() {
            users.clear();
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(
        role: widget.isBroadcaster
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience);
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);

    await _engine.joinChannel(
      token: MyStream.token,
      channelId: id,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  _disposeEngine() async {
    if (widget.isBroadcaster) {
      FireStoreMeth().endLiveStream();
    } else {
      FireStoreMeth().updateViewCount(widget.channelName, false);
    }

    await _engine.leaveChannel();
    await _engine.release();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {});
    }).catchError((_) {
      debugPrint('camera Error');
    });
  }

  _muteUnMute() {
    setState(() {
      isMuted = !isMuted;
    });
    _engine.muteLocalAudioStream(isMuted);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _disposeEngine();

        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                !widget.isBroadcaster
                    ? SizedBox(
                        height: MediaQuery.sizeOf(context).height / 3,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            children: [
                              Center(
                                child: _remoteVideo(),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: _localUserJoined
                                    ? SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                3,
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: AgoraVideoView(
                                            controller: VideoViewController(
                                              rtcEngine: _engine,
                                              canvas: VideoCanvas(uid: 0),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: CircularProgressIndicator()),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.sizeOf(context).height / 3,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            children: [
                              _localUserJoined
                                  ? AgoraVideoView(
                                      controller: VideoViewController(
                                        rtcEngine: _engine,
                                        canvas: VideoCanvas(uid: 0),
                                      ),
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator()),
                            ],
                          ),
                        ),
                      ),
                if (widget.isBroadcaster)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: _switchCamera,
                            child: const Text('Switch Camera.')),
                        ElevatedButton(
                            onPressed: _muteUnMute,
                            child: isMuted
                                ? const Text('unMute')
                                : const Text('Mute')),
                      ],
                    ),
                  ),
                Expanded(child: ChatWidget(channelName: widget.channelName)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (users.isNotEmpty) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: users[0]),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
