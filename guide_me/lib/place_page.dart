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
  final String
  placeName; // Assuming 'placeName' represents the name of the place
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

  const PlacePage(
      {Key? key,
        required this.touristName,
        required this.cityName,
        required this.place,
        required this.token,
        required this.appLocalization, // Add this line
        this.locale})
      : super(key: key);

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
    fetchAudio();
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
          'http://guideme.runasp.net/api/Recommendation/GetRecommendations'
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
        'http://guideme.runasp.net/api/Place/${widget.place['name']}/${widget.touristName}/places/media',
      ),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> fetchedMedia = json.decode(response.body);

      List<dynamic> processedMedia = [];

      fetchedMedia.forEach((media) {
        // Filter out audio types initially
        if (media['mediaType'] != 'audio') {
          processedMedia.add(media);
        }
      });

      // Fetch audio separately and add it at the end
      await fetchAudio().then((audioUrl) {
        if (audioUrl != null) {
          processedMedia.add({'mediaType': 'audio', 'mediaContent': audioUrl});
        }
      });

      // Sort media list: images first, then text, then audio, then video
      processedMedia.sort((a, b) {
        const mediaOrder = {'image': 0, 'text': 1, 'audio': 2, 'video': 3};

        // Ensure a['mediaType'] and b['mediaType'] are non-null and exist in mediaOrder
        final int? aTypeIndex = mediaOrder[a['mediaType']];
        final int? bTypeIndex = mediaOrder[b['mediaType']];

        // Handle cases where a['mediaType'] or b['mediaType'] might not be in mediaOrder
        // Default behavior: if mediaType is not found in mediaOrder, sort it to the end
        if (aTypeIndex != null && bTypeIndex != null) {
          return aTypeIndex.compareTo(bTypeIndex);
        } else if (aTypeIndex != null) {
          return -1; // a is prioritized if b's mediaType is not in mediaOrder
        } else if (bTypeIndex != null) {
          return 1; // b is prioritized if a's mediaType is not in mediaOrder
        } else {
          return 0; // both a and b are considered equal if neither mediaType is in mediaOrder
        }
      });

      setState(() {
        mediaList = processedMedia;
      });
    } else {
      print('Failed to fetch media: ${response.statusCode}');
    }
  }

  Future<String?> fetchAudio() async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://guideme.runasp.net/api/AudioTranslation/translate-audio/${widget.place['name']}/${widget.touristName}',
        ),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('path')) {
          return data['path']; // Assuming 'path' contains the audio URL
        } else {
          print('Failed to fetch audio: Response does not contain audio path');
          return null;
        }
      } else {
        print('Failed to fetch audio: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Failed to fetch audio: $e');
      return null;
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
          'http://guideme.runasp.net/api/Place/${widget.place['name']}/${widget.touristName}/places/location'),
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
          builder: (context) => MapPage(
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
          'http://guideme.runasp.net/Rating/GetLatestRate?TouristName=${Uri.encodeComponent(_touristName)}&PlaceName=${Uri.encodeComponent(placeName)}',
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
                Icon(Icons.star, color: Colors.yellow, size: 30),
                // Increase star size
                if (index < 4) SizedBox(width: 4),
                // Adjust spacing as needed
              ],
            );
          } else {
            return Row(
              children: [
                Icon(Icons.star_border, color: Colors.grey, size: 30),
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
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                media['mediaContent'],
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRatingStars(_rating),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RatePage(
                            placeName: widget.place['name'],
                            token: widget.token,
                            appLocalization: widget.appLocalization,
                            locale: widget.locale,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: Text(
                      _rating == 0
                          ? widget.appLocalization.translate('rate_this_place')
                          : widget.appLocalization.translate('change_rate'),
                      style: TextStyle(color: Colors.white),
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
      case 'text':
        return TextWidget(textContent: media['mediaContent'],appLocalization: widget
            .appLocalization, // Pass the localization instance
            locale: widget.locale);
      case 'audio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 10),
            AudioWidget(
              audioUrl: media['mediaContent'],
              playPause: playPause,
              isPlaying: isPlaying,
              duration: _duration,
              position: _position,
              player: player,
            ),
          ],
        );
      case 'video':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            Text(widget.appLocalization.translate('video'),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoWidget(videoUrl: media['mediaContent']),
            ),
          ],
        );
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization =
        widget.appLocalization; // Access AppLocalization instance
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
                  Image.asset(
                    'assets/scan_icon.jpg',
                    width: 34, // Adjust the width as needed
                    height: 24, // Adjust the height as needed
                    // color: Colors.white, // Apply color filter if necessary
                  ),
                  SizedBox(
                      height: 2), // Adjust the height as needed for spacing
                  Text(appLocalization.translate('scan'),
                      style: TextStyle(color: Colors.black, fontSize: 9)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewPage(
                      placeName: widget.place['name'],
                      token: widget.token,
                      appLocalization: widget
                          .appLocalization, // Pass the localization instance
                      locale: widget.locale,
                    ),
                  ),
                );
              },
              icon: Column(
                children: [
                  Icon(Icons.rate_review_rounded, color: Colors.black),
                  // Replace with your reviews icon
                  SizedBox(height: 2),
                  // Adjust the height as needed for spacing
                  Text(appLocalization.translate('Reviews'),
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
        itemCount: mediaList.length +
            2, // Increment itemCount by 2 to include recommendation header and media
        itemBuilder: (context, index) {
          if (index < mediaList.length) {
            return buildMediaWidget(mediaList[index]);
          } else if (index == mediaList.length) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // buildRecommendationHeader(), // Add the recommendation header
                buildRecommendationList(), // Add the horizontal recommendation list
              ],
            );
          } else {
            return SizedBox(); // Handle any additional cases here if necessary
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
                touristName: widget.touristName,
                appLocalization:
                widget.appLocalization, // Pass the localization instanc
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
              appLocalization:
              appLocalization, // Pass the localization instance
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
  final Locale? locale;
  final AppLocalization appLocalization;

  TextWidget({required this.textContent,required this.appLocalization, // Add this line
    this.locale});

  @override
  Widget build(BuildContext context) {


    return ListTile(
      title: Text(appLocalization.translate('about_the_place'),
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
      ..initialize().then((_) {
        setState(() {
          _isBuffering = false;
        });
      });
    _controller.addListener(() {
      if (_controller.value.isBuffering != _isBuffering) {
        setState(() {
          _isBuffering = _controller.value.isBuffering;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9, // Ensure the aspect ratio matches the image
      child: Stack(
        children: [
          VideoPlayer(_controller),
          if (_isBuffering)
            Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                      _controller.setVolume(_isMuted ? 0 : 1);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

extension DurationExtensions on Duration {
  String get formattedDuration {
    String twoDigitMinutes =
    this.inMinutes.remainder(60).toString().padLeft(2, '0');
    String twoDigitSeconds =
    this.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}