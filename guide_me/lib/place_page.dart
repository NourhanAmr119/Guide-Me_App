import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:guide_me/review_page.dart';
import 'package:guide_me/rate_page.dart';
import 'package:audioplayers/audioplayers.dart';
class PlacePage extends StatefulWidget {
  final Map<String, dynamic> place;
  final String token;

  PlacePage({required this.place, required this.token});

  @override
  _PlacePageState createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  List<dynamic> mediaList = [];

  @override
  void initState() {
    super.initState();
    fetchMedia();
  }

  Future<void> fetchMedia() async {
    final response = await http.get(
      Uri.parse('http://guide-me.somee.com/api/Place/${widget.place['name']}/places/media'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        mediaList = json.decode(response.body)
            .where((media) => media['mediaType'] != 'audio')
            .toList(); // Exclude audio media
      });
    } else {
      print('Failed to fetch media: ${response.statusCode}');
    }
  }

  Widget buildMediaWidget(dynamic media) {
    switch (media['mediaType']) {
      case 'image':
        return Column(
          children: [
            Image.network(media['mediaContent']),
            SizedBox(height: 10),
            ReviewButton(placeName: widget.place['name'], token: widget.token),
          ],
        );
      case 'text':
        return TextWidget(textUrl: media['mediaContent']);
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
              icon: Icon(Icons.star,  color: Colors.yellow),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RatePage(placeName: widget.place['name'], token: widget.token),
                  ),
                );
              },
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

class TextWidget extends StatefulWidget {
  final String textUrl;

  TextWidget({required this.textUrl});

  @override
  _TextWidgetState createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
  String? textContent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTextContent();
  }

  Future<void> fetchTextContent() async {
    final response = await http.get(Uri.parse(widget.textUrl));
    if (response.statusCode == 200) {
      setState(() {
        textContent = response.body;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        textContent = 'Failed to load text content';
      });
      print('Error fetching text content: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('About the Place', style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold)),
      subtitle: isLoading
          ? CircularProgressIndicator()
          : Container(
        height: 100, // Set the height of the text area
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Text(
              textContent ?? 'Failed to load text content',
              style: TextStyle(color: Colors.white, fontSize: 14), // Adjust the font size
            ),
          ),
        ),
      ),
    );
  }
}
// class AudioWidget extends StatelessWidget {
//   final String audioUrl;
//
//   AudioWidget({required this.audioUrl});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text('Audio', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
//       subtitle: AudioPlayerWidget(audioUrl: audioUrl),
//     );
//   }
// }
//
// class AudioPlayerWidget extends StatefulWidget {
//   final String audioUrl;
//
//   AudioPlayerWidget({required this.audioUrl});
//
//   @override
//   _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
// }
//
// class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
//   late AudioPlayer _audioPlayer;
//
//   @override
//   void initState() {
//     super.initState();
//     _audioPlayer = AudioPlayer();
//     _audioPlayer.setUrl(widget.audioUrl);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: Icon(Icons.play_arrow),
//           onPressed: () {
//             _audioPlayer.play();
//           },
//         ),
//         IconButton(
//           icon: Icon(Icons.pause),
//           onPressed: () {
//             _audioPlayer.pause();
//           },
//         ),
//         IconButton(
//           icon: Icon(Icons.stop),
//           onPressed: () {
//             _audioPlayer.stop();
//           },
//         ),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
// }
Widget buildMediaWidget(dynamic media) {
  switch (media['mediaType']) {
    case 'image':
      var widget;
      return Column(
        children: [
          Image.network(media['mediaContent']),
          SizedBox(height: 10),
          ReviewButton(placeName: widget.place['name'], token: widget.token),
        ],
      );
    // case 'audio':
    //   return AudioWidget(audioUrl: media['mediaContent']);
    case 'text':
      return TextWidget(textUrl: media['mediaContent']);
    case 'video':
      return VideoWidget(videoUrl: media['mediaContent']);
    default:
      return SizedBox();
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
      title: Text('Video', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
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
                  icon: _isPlaying ? Icon(Icons.stop) : Icon(Icons.play_arrow),
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
              builder: (context) => ReviewPage(placeName: placeName, token: token)
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[700],
      ),
      child: Text(
        'Reviews',
        style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.bold),
      ),
    );
  }
}