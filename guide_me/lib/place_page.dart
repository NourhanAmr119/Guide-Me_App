

import 'package:flutter/material.dart';
import 'package:guide_me/review_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'map_page.dart';

class PlacePage extends StatefulWidget {
  final Map<String, dynamic> place;
  final String token;

  PlacePage({required this.place, required this.token});

  @override
  _PlacePageState createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  List<dynamic> mediaList = [];
  late final AudioPlayer player;
  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    fetchMedia();
    initPlayer();
  }

  Future<void> fetchMedia() async {
    final response = await http.get(
      Uri.parse(
          'http://guide-me.somee.com/api/Place/${widget.place['name']}/places/media'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        mediaList = json.decode(response.body);
      });
    } else {
      print('Failed to fetch media: ${response.statusCode}');
    }
  }

  Future<void> initPlayer() async {
    player = AudioPlayer();
    player.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
    });

    player.onPositionChanged.listen((Duration p) {
      setState(() => _position = p);
    });

    player.onPlayerComplete.listen((_) {
      setState(() => _position = _duration);
    });
  }

  void playPause(String url) async {
    if (isPlaying) {
      player.pause();
      isPlaying = false;
    } else {
      await player.play(UrlSource(url));
      isPlaying = true;
    }
    setState(() {});
  }

  Future<void> fetchLocationAndNavigate() async {
    final response = await http.get(
      Uri.parse(
          'http://guide-me.somee.com/api/Place/${widget.place['name']}/places/location'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final location = json.decode(response.body);
      final double latitude = location['latitude'];
      final double longitude = location['longitude'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MapPage(latitude: latitude, longitude: longitude, locationName: '',),
        ),
      );
    } else {
      print('Failed to fetch location: ${response.statusCode}');
    }
  }

  Widget buildMediaWidget(dynamic media) {
    switch (media['mediaType']) {
      case 'image':
        return Column(
          children: [
            Image.network(media['mediaContent']),
            TextButton(
              onPressed: fetchLocationAndNavigate,
              // style: TextButton.styleFrom(
              //   backgroundColor: Colors.blueGrey[700],
              // ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    widget.place['name'],
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        );
      case 'audio':
        return AudioWidget(
          audioUrl: media['mediaContent'],
          playPause: playPause,
          isPlaying: isPlaying,
          duration: _duration,
          position: _position,
          player: player,
        );
      case 'text':
        return TextWidget(textContent: media['mediaContent']);

      case 'video':
        return VideoWidget(videoUrl: media['mediaContent']);
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.place['name']),
            IconButton(
              icon: Icon(Icons.qr_code),
              onPressed: () {
                // Handle your scan action
              },
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewPage(
                        placeName: widget.place['name'], token: widget.token),
                  ),
                );
              },
              icon: Column(
                children: [
                  Icon(Icons.rate_review_rounded,
                      color: Colors.white), // Replace with your reviews icon
                  SizedBox(
                      height: 2), // Adjust the height as needed for spacing
                  Text('Reviews',
                      style:
                          TextStyle(color: Colors.white)), // Title of the icon
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 21, 82, 113),
      ),
      backgroundColor: Color.fromARGB(255, 21, 82, 113),
      body: ListView.builder(
        itemCount: mediaList.length,
        itemBuilder: (context, index) {
          return buildMediaWidget(mediaList[index]);
        },
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  final String textContent;

  TextWidget({required this.textContent});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('About the Place',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
      subtitle: Container(
        height: 100, // Set the height of the text area
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Text(
              textContent,
              style: TextStyle(
                  color: Colors.white, fontSize: 14), // Adjust the font size
            ),
          ),
        ),
      ),
    );
  }
}

class AudioWidget extends StatelessWidget {
  final String audioUrl;
  final Function(String) playPause;
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final AudioPlayer player;

  AudioWidget({
    required this.audioUrl,
    required this.playPause,
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Audio',
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () => playPause(audioUrl),
              color: Colors.white,
            ),
            Expanded(
              child: Slider(
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  await player.seek(Duration(seconds: value.toInt()));
                },
                min: 0,
                max: duration.inSeconds.toDouble(),
                inactiveColor: Colors.grey,
                activeColor: Colors.red,
              ),
            ),
            Text(duration.formattedDuration,
                style: TextStyle(
                    color: Colors.white)), // Moved the duration text here
          ],
        ),
      ],
    );
  }
}

class VideoWidget extends StatefulWidget {
  final String videoUrl;

  VideoWidget({required this.videoUrl});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool _isBuffering = true;
  bool _isMuted = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(_updateState)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _controller.play();
            _isPlaying = true;
          });
        }
      })
      ..setLooping(true);
  }

  void _updateState() {
    if (_controller.value.isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = _controller.value.isBuffering;
      });
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Video',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
      subtitle: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  _VideoProgressBar(_controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                  if (_isBuffering) CircularProgressIndicator(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: _isPlaying
                            ? Icon(Icons.stop)
                            : Icon(Icons.play_arrow),
                        onPressed: _togglePlayPause,
                        color: Colors.white,
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        icon:
                            Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                        onPressed: _toggleMute,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            )
          : CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    _controller.dispose();
    super.dispose();
  }
}

class _VideoProgressBar extends StatelessWidget {
  final VideoPlayerController controller;

  _VideoProgressBar(this.controller);

  @override
  Widget build(BuildContext context) {
    return VideoProgressIndicator(
      controller,
      allowScrubbing: true,
      padding: EdgeInsets.all(3.0),
      colors: VideoProgressColors(
        playedColor: Colors.red, // Replace with your desired color
      ),
    );
  }
}

class ReviewButton extends StatelessWidget {
  final String placeName;
  final String token;

  ReviewButton({required this.placeName, required this.token});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ReviewPage(placeName: placeName, token: token)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[700],
      ),
      child: Text(
        'Reviews',
        style: TextStyle(
            fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class RatePage extends StatelessWidget {
  final String placeName;
  final String token;

  RatePage({required this.placeName, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate $placeName'),
      ),
      body: Center(
        child: Text('Rating functionality for $placeName'),
      ),
    );
  }
}

extension DurationExtensions on Duration {
  String get formattedDuration {
    String twoDigitMinutes =
        this.inMinutes.remainder(60).toString().padLeft(2, '0');
    String twoDigitSeconds =
        this.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
