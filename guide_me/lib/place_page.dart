import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacePage extends StatefulWidget {
  final Map<String, dynamic> place;
  final String token;

  const PlacePage({Key? key, required this.place, required this.token}) : super(key: key);

  @override
  _PlacePageState createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  VideoPlayerController? _videoPlayerController;
  AudioPlayer? _audioPlayer;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _initializeMediaPlayers();
  }

  void _initializeMediaPlayers() {
    // Initialize video player
    var videoMedia = widget.place['media'].firstWhere(
            (m) => m['mediaType'] == 'video',
        orElse: () => null);
    if (videoMedia != null) {
      _videoPlayerController = VideoPlayerController.network(
        videoMedia['mediaContent'],
      )..initialize().then((_) {
        setState(() {});
        _videoPlayerController!.play();
      });
    }

    // Initialize audio player
    _audioPlayer = AudioPlayer();
    var audioMedia = widget.place['media'].firstWhere(
            (m) => m['mediaType'] == 'audio',
        orElse: () => null);
    if (audioMedia != null) {
      _audioPlayer!.play(UrlSource(audioMedia['mediaContent']));
      setState(() {
        _isPlayingAudio = true;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place['name'] ?? 'Place Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_videoPlayerController != null &&
                _videoPlayerController!.value.isInitialized)
              Container(
                padding: const EdgeInsets.all(8),
                child: AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController!),
                ),
              ),
            if (_isPlayingAudio)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: IconButton(
                  icon: Icon(_isPlayingAudio ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (_isPlayingAudio) {
                      _audioPlayer!.pause();
                    } else {
                      _audioPlayer!.resume();
                    }
                    setState(() {
                      _isPlayingAudio = !_isPlayingAudio;
                    });
                  },
                ),
              ),
            if (widget.place['media'] != null)
              Container(
                height: 200,
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.place['media'].length,
                  itemBuilder: (context, index) {
                    var media = widget.place['media'][index];
                    if (media['mediaType'] == 'image') {
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.network(media['mediaContent']),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.place['description'] ?? 'No description available.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}