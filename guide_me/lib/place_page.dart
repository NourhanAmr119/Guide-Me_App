import 'package:flutter/material.dart';
import 'package:guide_me/rate_place.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'review_page.dart';

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
            RateButton(placeName: widget.place['name'], token: widget.token),
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
        title: Text('Place Page'),
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
class VideoWidget extends StatefulWidget {
  final String videoUrl;

  VideoWidget({required this.videoUrl});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool _isBuffering = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(_updateState)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _controller.play();
          });
        }
      })
      ..setLooping(true); // Optionally, loop the video
  }

  void _updateState() {
    if (_controller.value.isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = _controller.value.isBuffering;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Video', style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold)),
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

class RateButton extends StatelessWidget {
  final String placeName;
  final String token;

  RateButton({required this.placeName, required this.token});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RatePage(placeName: placeName, token: token),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          child: Text(
            'Rate this place',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 10), // Add some space between the buttons
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewPage(placeName: placeName, token: token)

              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          child: Text(
            'Review',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

}

