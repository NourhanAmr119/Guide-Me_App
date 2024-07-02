import 'package:flutter/material.dart';
import 'package:guide_me/review_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'map_page.dart';
import 'package:jwt_decode/jwt_decode.dart';
import "rate_page.dart";
import 'AppLocalization.dart';

class Recommendation {
  final String placeName; // Assuming 'placeName' represents the name of the place
  final String cityName;
  final String image;
  final double rate;
  final String touristName;
  // final Locale? locale;
  // final AppLocalization appLocalization;// Assuming this field represents the tourist's name

  Recommendation({
    required this.placeName,
    required this.cityName,
    required this.image,
    required this.rate,
    required this.touristName,
    // required this.appLocalization,
    // this.locale,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      placeName: json['placeName'] ?? '',
      cityName: json['cityName'] ?? '',
      image: json['image'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
      touristName: json['touristName'] ?? '',
      // appLocalization: appLocalization,
      // locale: locale,
    );
  }
}



class PlacePage extends StatefulWidget {
  final String touristName;
  final String cityName;
  final Map<String, dynamic> place;
  final String token;
  final Locale? locale;
  final AppLocalization appLocalization;

  const PlacePage({
    Key? key,
    required this.touristName,
    required this.cityName,
    required this.place,
    required this.token,
    required this.appLocalization, // Add this line
    this.locale

  }) : super(key: key);

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
  List<Recommendation> recommendations = [];

  @override
  void initState() {
    super.initState();
    fetchMedia();
    initPlayer();
    _touristName = decodeToken(widget.token);
    if (_touristName.isNotEmpty) {
      fetchRating();
    } else {
      print('Failed to decode tourist name from token.');
    }
    fetchRecommendations(); // Fetch recommendations on init
    print('Locale: ${widget.locale}');
  }

  Future<void> fetchRecommendations() async {
    // Check if widget.cityName is populated
    if (widget.cityName == null || widget.cityName.isEmpty) {
      print('Error: widget.cityName is null or empty.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://guide-me.somee.com/api/Recommendation/GetRecommendations'
              '?touristName=${Uri.encodeComponent(widget.touristName)}'
              '&cityName=${Uri.encodeComponent(widget.cityName)}'
              '&placeName=${Uri.encodeComponent(widget.place['name'])}',
        ),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          recommendations = (json.decode(response.body) as List)
              .map((data) => Recommendation.fromJson(data))
              .toList();
        });
      } else {
        print('Failed to fetch recommendations: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Failed to fetch recommendations: $e');
    }
  }


  Future<void> fetchMedia() async {
    final response = await http.get(
      Uri.parse(
          'http://guide-me.somee.com/api/Place/${widget
              .place['name']}/places/media'),
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
          'http://guide-me.somee.com/api/Place/${widget
              .place['name']}/places/location'),
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
              MapPage(
                latitude: latitude,
                longitude: longitude,
                locationName: '',
              ),
        ),
      );
    } else {
      print('Failed to fetch location: ${response.statusCode}');
    }
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    print('Decoded token: $decodedToken');
    return decodedToken[
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ??
        '';
  }

  Future<void> fetchRating() async {
    if (_touristName.isEmpty) {
      print('Tourist name is required.');
      return;
    }
    print('place in : $widget.place');

    final placeName = widget.place['name'];
    if (placeName == null || placeName.isEmpty) {
      print('Place name is required.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://guide-me.somee.com/Rating/GetLatestRate?TouristName=${Uri
              .encodeComponent(_touristName)}&PlaceName=${Uri.encodeComponent(
              placeName)}',
        ),
        headers: {
          'accept': '/',
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      // Adjust padding as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          if (index < roundedRating) {
            return Row(
              children: [
                Icon(Icons.star, color: Colors.yellow, size: 40),
                // Increase star size
                if (index < 4) SizedBox(width: 4),
                // Adjust spacing as needed
              ],
            );
          } else {
            return Row(
              children: [
                Icon(Icons.star_border, color: Colors.grey, size: 40),
                // Increase star size
                if (index < 4) SizedBox(width: 4),
                // Adjust spacing as needed
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
            // Display the image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                media['mediaContent'],
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10), // Space between the image and rating elements
            // Display the rating stars and rate button in a row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              // Add padding on the sides
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rating stars
                  _buildRatingStars(_rating),
                  // Rate button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RatePage(
                                placeName: widget.place['name'],
                                token: widget.token,
                                  appLocalization: widget.appLocalization, // Pass the localization instance
                                  locale: widget.locale
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Gold background
                    ),
                    child: Text(
                      _rating == 0 ? widget.appLocalization.translate('rate_this_place') : widget.appLocalization.translate('change_rate'),
                      // Conditional button text
                      style: TextStyle(color: Colors.white), // Black text
                    ),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                widget.place['name'],
                style: TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Spacer(), // This will push the icons to the right
            IconButton(
              onPressed: () {
                // Handle your scan action
              },
              icon: Column(
                children: [
                  Icon(Icons.qr_code,
                      color: Colors.black),
                  // Replace with your reviews icon
                  SizedBox(
                      height: 2),
                  // Adjust the height as needed for spacing
                  Text('Scan',
                      style: TextStyle(color: Colors.black)),
                  // Title of the icon
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReviewPage(
                            placeName: widget.place['name'],
                            token: widget.token,
                            appLocalization: widget.appLocalization, // Pass the localization instance
                            locale: widget.locale,
                        ),
                  ),
                );
              },
              icon: Column(
                children: [
                  Icon(Icons.rate_review_rounded,
                      color: Colors.black),
                  // Replace with your reviews icon
                  SizedBox(
                      height: 2),
                  // Adjust the height as needed for spacing
                  Text('Reviews',
                      style: TextStyle(color: Colors.black)),
                  // Title of the icon
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 246, 243, 177),
      ),
      backgroundColor: Color.fromARGB(255, 246, 243, 177),
      body: ListView.builder(
        itemCount: mediaList.length + 1,
        // Increment itemCount by 1 to include the recommendation list
        itemBuilder: (context, index) {
          if (index < mediaList.length) {
            return buildMediaWidget(mediaList[index]);
          } else {
            return buildRecommendationList(); // Add the horizontal recommendation list
          }
        },
      ),
    );
  }

  Widget buildRecommendationList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            widget.appLocalization.translate('places_you_might_like'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10), // Add some space
        Container(
          height: 300, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return RecommendationCard(
                  recommendation: recommendation,
                  token: widget.token, // Pass the token to RecommendationCard
                  cityName: widget.cityName,
                  touristName:widget.touristName,
                  appLocalization: widget.appLocalization, // Pass the localization instanc
                  locale: widget.locale,
                // Pass the cityName to RecommendationCard
              );
            },
          ),
        ),
      ],
    );
  }
}
class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final String cityName;
  final String token;
  final String touristName;
  final Locale? locale;
  final AppLocalization appLocalization;

  RecommendationCard({
    required this.recommendation,
    required this.cityName,
    required this.token,
    required this.touristName,
    required this.appLocalization, // Add this line
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.55;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlacePage(
              touristName: touristName,
              cityName: cityName,
              place: {
                'name': recommendation.placeName,
              },
              token: token,
              appLocalization: appLocalization, // Pass the localization instance
              locale: locale,
            ),
          ),
        ).then((_) {
          // Reload recommendations when returning to the previous page
          (context as Element).markNeedsBuild();
        });
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.all(10),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Image.network(
                recommendation.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.placeName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      _buildRatingStars(recommendation.rate.toInt()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars(int rate) {
    int roundedRating = rate.clamp(0, 5); // Ensure rating is between 0 and 5
    return Row(
      children: List.generate(5, (index) {
        if (index < roundedRating) {
          return Icon(Icons.star, color: Colors.yellow, size: 20);
        } else {
          return Icon(Icons.star_border, color: Colors.grey, size: 20);
        }
      }),
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
    final AppLocalization appLocalization = AppLocalization.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            appLocalization.translate('audio'),
            style: TextStyle(
                color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 35,
              ),
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
    final AppLocalization appLocalization = AppLocalization.of(context)!;

    return ListTile(
      title: Text(appLocalization.translate('video'),
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
        playedColor: Colors.red,
      ),
    );
  }
}

// class ReviewButton extends StatelessWidget {
//   final String placeName;
//   final String token;
//
//   ReviewButton({required this.placeName, required this.token});
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) =>
//                   ReviewPage(placeName: placeName, token: token,appLocalization: appLocalization, // Pass the localization instance
//                     locale: widget.locale,)),
//         );
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.blueGrey[700],
//       ),
//       child: Text(
//         'Reviews',
//         style: TextStyle(
//             fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }

extension DurationExtensions on Duration {
  String get formattedDuration {
    String twoDigitMinutes =
    this.inMinutes.remainder(60).toString().padLeft(2, '0');
    String twoDigitSeconds =
    this.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}