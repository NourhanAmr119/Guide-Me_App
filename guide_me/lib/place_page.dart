import 'package:flutter/material.dart';
import 'package:guide_me/review_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'map_page.dart';
import 'package:jwt_decode/jwt_decode.dart';
import "rate_page.dart";


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
  double _rating = 0.0;
  String _touristName = '';

  @override
  void initState() {
    super.initState();
    fetchMedia();
    initPlayer();
    _touristName = decodeToken(widget.token);
    print('Extracted tourist name: $_touristName');
    if (_touristName.isNotEmpty) {
      fetchRating();
    } else {
      print('Failed to decode tourist name from token.');
    }
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
  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    print('Decoded token: $decodedToken');
    return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? '';
  }

  Future<void> fetchRating() async {
    if (_touristName.isEmpty) {
      print('Tourist name is required.');
      return;
    }

    final placeName = widget.place['name'];
    if (placeName == null || placeName.isEmpty) {
      print('Place name is required.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://guide-me.somee.com/Rating/GetLatestRate?TouristName=${Uri.encodeComponent(_touristName)}&PlaceName=${Uri.encodeComponent(placeName)}',
        ),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      print('Request URL: ${response.request?.url}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final rating = double.tryParse(response.body) ?? 0.0;
        setState(() {
          _rating = rating;
        });
      } else {
        print('Failed to fetch rating: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rating: $e');
    }
  }

  Widget _buildRatingStars(double rating) {
    int roundedRating = rating.round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adjust padding as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          if (index < roundedRating) {
            return Row(
              children: [
                Icon(Icons.star, color: Colors.yellow),
                if (index < 4) SizedBox(width: 4), // Adjust spacing as needed
              ],
            );
          } else {
            return Row(
              children: [
                Icon(Icons.star_border, color: Colors.grey),
                if (index < 4) SizedBox(width: 4), // Adjust spacing as needed
              ],
            );
          }
        }),
      ),
    );
  }


  Widget buildMediaWidget(dynamic media) {
    switch (media['mediaType']) {
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عرض الصورة
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                media['mediaContent'],
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10), // مسافة بين الصورة وعناصر التقييم
            // عرض النجوم الخاصة بالتقييم وزر التقييم في صف
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0), // إضافة مسافة من اليمين واليسار
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // نجوم التقييم
                  _buildRatingStars(_rating),
                  // زر التقييم
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RatePage(
                            placeName: widget.place['name'],
                            token: widget.token,
                          ),
                        ),
                      );
                    },
                    child: Text('Rate This Place'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: fetchLocationAndNavigate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.blue),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.place['name'],
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
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
        iconTheme: IconThemeData(color: Colors.black),
        title: Row(
          children: [
            Flexible(
              child: Text(
                widget.place['name'],
                style: TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () {
                // Handle your scan action
              },
              icon: Column(
                children: [
                  Icon(Icons.qr_code,
                      color: Colors.black), // Replace with your reviews icon
                  SizedBox(
                      height: 2), // Adjust the height as needed for spacing
                  Text('Scan',
                      style:
                      TextStyle(color: Colors.black)), // Title of the icon
                ],
              ),
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
                      color: Colors.black), // Replace with your reviews icon
                  SizedBox(
                      height: 2), // Adjust the height as needed for spacing
                  Text('Reviews',
                      style:
                      TextStyle(color: Colors.black)), // Title of the icon
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 246, 243, 177),
      ),
      backgroundColor: Color.fromARGB(255, 246, 243, 177),
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
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold)),
      subtitle: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Text(
              textContent,
              style: TextStyle(
                  color: Colors.black, fontSize: 14), // Adjust the font size
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
                color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 35,),
              onPressed: () => playPause(audioUrl),
              color: Colors.blueAccent,
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
                activeColor: Colors.blueAccent,
              ),
            ),
            Text(duration.formattedDuration,
                style: TextStyle(color: Colors.black)),
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
            _isBuffering = false;
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
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold)),
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
                  icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
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
        playedColor: Colors.red,
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


extension DurationExtensions on Duration {
  String get formattedDuration {
    String twoDigitMinutes =
    this.inMinutes.remainder(60).toString().padLeft(2, '0');
    String twoDigitSeconds =
    this.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}