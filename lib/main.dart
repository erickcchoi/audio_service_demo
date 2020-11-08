import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'as.dart';
import 'dart:math';

void main() {
  debugPrint('[MyApp] Create ======');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint('[MyApp] Build ======');
    return MaterialApp(
      title: 'Audio Service Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AudioServiceWidget(child: MainScreen()),
    );
  }
}

List<MediaItem> mItem = [
  MediaItem(
    id: "http://aod.cos.tx.xmcdn.com/storages/58b6-audiofreehighqps/04/7B/CMCoOR8DeN7DAAKvZwBjywsO.m4a",
    album: "BBBB",
    title: "Media Item 0",
    artist: "AAAaaa",
    artUri: "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
  ),
  MediaItem(
    id: "http://aod.cos.tx.xmcdn.com/storages/9647-audiofreehighqps/C0/97/CMCoOSMDeircAAGWRQBkHzof.m4a",
    album: "CCCC",
    title: "Media Item 1",
    artist: "DDDDDD",
    artUri: "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
  ),
];

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final BehaviorSubject<double> _dragPositionSubject = BehaviorSubject.seeded(null);

  @override
  Widget build(BuildContext context) {
    debugPrint('[MainScreen] Build ======');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Service Demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          playMediaButtonInit(),
          playMediaButton0(),
          playMediaButton1(),
          pauseButton(),
          StreamBuilder<ScreenState>(
            stream: screenStateStream,
            builder: (context, snapshot) {
              final screenState = snapshot.data;
              final mediaItem = screenState?.mediaItem;
              final state = screenState?.playbackState;
              return positionIndicator(mediaItem, state);
            },
          ),
        ],
      ),
    );
  }

  FlatButton playMediaButton0() => FlatButton(
        color: Colors.lightGreen,
        onPressed: () {
          AudioService.playMediaItem(mItem[0]);
        },
        child: Text("Media Item 0", style: TextStyle(fontSize: 20.0)),
      );

  FlatButton playMediaButton1() => FlatButton(
        color: Colors.lightGreen,
        onPressed: () {
          AudioService.playMediaItem(mItem[1]);
        },
        child: Text("Media Item 1", style: TextStyle(fontSize: 20.0)),
      );

  FlatButton playMediaButtonInit() => FlatButton(
        color: Colors.amberAccent,
        onPressed: () {
          AudioService.start(
            backgroundTaskEntrypoint: audioPlayerTaskEntrypoint,
            androidNotificationChannelName: 'Audio Service',
            androidNotificationOngoing: true,
            androidStopForegroundOnPause: false,
            androidNotificationColor: 0xFF2196f3,
            androidNotificationIcon: 'mipmap/ic_launcher',
            androidEnableQueue: false,
          );
        },
        child: Text("Init Audio Service", style: TextStyle(fontSize: 20.0)),
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: (){
          AudioService.pause();
        },
      );

  Widget positionIndicator(MediaItem mediaItem, PlaybackState state) {
    double seekPos;
    return StreamBuilder(
        stream: Rx.combineLatest2<double, double, double>(_dragPositionSubject.stream, Stream.periodic(Duration(milliseconds: 200)), (dragPosition, _) => dragPosition),
        builder: (context, snapshot) {
          double position = state?.currentPosition?.inSeconds?.toDouble() ?? 0.0;
          double duration = mediaItem?.duration?.inSeconds?.toDouble() ?? 0.0;
          return Column(
            children: [
              if (duration != null)
                Slider(
                  min: 0.0,
                  max: duration,
                  value: seekPos ?? max(0.0, min(position, duration)),
                  onChanged: (value) {
                    _dragPositionSubject.add(value);
                  },
                  onChangeEnd: (value) {
                    AudioService.seekTo(Duration(seconds: value.toInt()));
                    seekPos = value;
                    _dragPositionSubject.add(null);
                  },
                ),
              Text("${state?.currentPosition ?? 0}"),
              Text("${duration.toString()}"),
            ],
          );
        });
  }
}
