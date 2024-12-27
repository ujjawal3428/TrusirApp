import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:trusir/common/api.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoKnowledge extends StatefulWidget {
  const VideoKnowledge({super.key});

  @override
  State<VideoKnowledge> createState() => _VideoKnowledgeState();
}

class _VideoKnowledgeState extends State<VideoKnowledge> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _videos = [];
  List<Map<String, dynamic>> _filteredVideos = [];
  List<String> categories = [];
  int selectedIndex = 0;
  int currentPage = 1;
  bool isFetching = false;
  bool hasMoreVideos = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterVideos);
    fetchVideoCategory();
    fetchData(category: 'All');
  }

  Future<void> fetchVideoCategory() async {
    final url = Uri.parse('$baseUrl/video-category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          categories = [
            "All",
            ...data.map<String>((course) {
              return course['name'] as String;
            })
          ];
        });
      }
    } else {
      throw Exception('Failed to fetch categories');
    }
  }

  Future<void> fetchData(
      {required String category, bool isLoadMore = false}) async {
    if (isFetching) return;

    setState(() {
      isFetching = true;
    });

    try {
      final apiCategory = category == "All" ? "all" : category;
      final apiUrl =
          "$baseUrl/video/$apiCategory?page=$currentPage&data_per_page=10";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        if (jsonData.isEmpty) {
          setState(() {
            hasMoreVideos = false;
          });
        } else {
          final newVideos = jsonData.map((item) {
            return {
              "title": item["title"],
              "url": item["url"],
              "time": item["time"],
              "description": item["description"],
              "profile": item["profile"] == ""
                  ? "https://admin.trusir.com/uploads/profile/profile_1735053128.png"
                  : item["profile"],
              "category": item["category"],
            };
          }).toList();

          setState(() {
            if (isLoadMore) {
              _videos.addAll(newVideos);
            } else {
              _videos = newVideos;
            }
            _filteredVideos = _videos;
            currentPage++;
          });
        }
      } else {
        throw Exception(
            "Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

  void _filterVideos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVideos = _videos
          .where((video) => video['title']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int index) {
    setState(() {
      selectedIndex = index;
      currentPage = 1;
      hasMoreVideos = true;
    });
    fetchData(category: categories[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset('assets/back_button.png', height: 50)),
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  suffixIcon: const Icon(
                    Icons.search,
                    color: Colors.black87,
                  ),
                  hintText: 'Search videos',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  hintStyle: TextStyle(
                    color: Colors.black87,
                    fontFamily: GoogleFonts.notoSans().fontFamily,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          _buildCategories(context),
          const SizedBox(height: 10),
          Expanded(
            child: _filteredVideos.isEmpty
                ? const Center(child: Text("No videos available"))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return WideScreenLayout(videos: _filteredVideos);
                      } else {
                        return MobileLayout(videos: _filteredVideos);
                      }
                    },
                  ),
          ),
          _filteredVideos.isEmpty
              ? const SizedBox()
              : hasMoreVideos
                  ? TextButton(
                      onPressed: () {
                        fetchData(
                            category: categories[selectedIndex],
                            isLoadMore: true);
                      },
                      child: const Text('Load More..'),
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("No more videos"),
                    ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          bool isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => _onCategorySelected(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[200],
                gradient: LinearGradient(
                  colors: isSelected
                      ? [
                          const Color(0xFFC22054),
                          const Color(0xFF48116A),
                        ]
                      : [Colors.grey[200]!, Colors.grey[200]!],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class MobileLayout extends StatelessWidget {
  final List<Map<String, dynamic>> videos;

  const MobileLayout({super.key, required this.videos});

  String getYouTubeThumbnail(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null) {
        return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      }
    } else if (uri.host.contains('youtu.be')) {
      final videoId =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      if (videoId != null) {
        return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      }
    }
    return ''; // Return an empty string or a default thumbnail if URL is invalid.
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return VideoCard(
          videoUrl: Uri.parse(videos[index]['url'] ?? ''),
          title: videos[index]['title'] ?? 'title',
          thumbnailUrl: getYouTubeThumbnail(videos[index]['url'] ??
              'https://admin.trusir.com/uploads/profile/profile_1735053128.png'),
          description: videos[index]['description'] ?? 'description',
          channelPicUrl: videos[index]['profile'] ??
              'https://admin.trusir.com/uploads/profile/profile_1735053128.png',
          uploadTime: videos[index]['time'] ?? 'time',
        );
      },
    );
  }
}

class WideScreenLayout extends StatelessWidget {
  final List<Map<String, dynamic>> videos;

  const WideScreenLayout({super.key, required this.videos});

  String getYouTubeThumbnail(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null) {
        return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      }
    } else if (uri.host.contains('youtu.be')) {
      final videoId =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      if (videoId != null) {
        return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      }
    }
    return ''; // Return an empty string or a default thumbnail if URL is invalid.
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 16 / 9,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return VideoCard(
          videoUrl: Uri.parse(videos[index]['url'] ?? ''),
          title: videos[index]['title'] ?? 'title',
          thumbnailUrl: getYouTubeThumbnail(videos[index]['url'] ??
              'https://admin.trusir.com/uploads/profile/profile_1735053128.png'),
          description: videos[index]['description'] ?? 'description',
          channelPicUrl: videos[index]['profile'] ??
              'https://admin.trusir.com/uploads/profile/profile_1735053128.png',
          uploadTime: videos[index]['time'] ?? 'time',
        );
      },
    );
  }
}

class VideoCard extends StatelessWidget {
  final Uri videoUrl;
  final String title;
  final String thumbnailUrl;
  final String description;
  final String channelPicUrl;
  final String uploadTime;

  const VideoCard({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.thumbnailUrl,
    required this.description,
    required this.channelPicUrl,
    required this.uploadTime,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                videoUrl: videoUrl,
              ),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(0.0)),
                  child: Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        child: const Center(
                          child: Icon(
                            Icons.error,
                            size: 50.0,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage:
                              NetworkImage(channelPicUrl), // Channel picture
                          backgroundColor: Colors.grey[300],
                        ),
                        const SizedBox(width: 8.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: GoogleFonts.notoSans().fontFamily,
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: GoogleFonts.notoSans().fontFamily,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      uploadTime,
                      style: TextStyle(
                        fontFamily: GoogleFonts.notoSans().fontFamily,
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final Uri videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _youtubeController;
  bool _controlsVisible = true;
  late Timer _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startHideControlsTimer();
  }

  void _initializePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl.toString());
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          loop: false, // Set to true for looping
          forceHD: true, // Force HD quality if available
        ),
      );
    } else {
      throw Exception("Invalid YouTube URL");
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        if (_controlsVisible) {
          setState(() {
            _controlsVisible = false;
          });
        }
      },
    );
  }

  void _seekForward() {
    final currentPosition = _youtubeController.value.position;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _youtubeController.seekTo(newPosition);
    _resetHideControlsTimer();
  }

  void _seekBackward() {
    final currentPosition = _youtubeController.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _youtubeController.seekTo(newPosition);
    _resetHideControlsTimer();
  }

  void _resetHideControlsTimer() {
    if (_hideControlsTimer.isActive) {
      _hideControlsTimer.cancel();
    }
    setState(() {
      _controlsVisible = true;
    });
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    _hideControlsTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          _resetHideControlsTimer(); // Show controls when screen is tapped
        },
        child: OrientationBuilder(
          builder: (context, orientation) {
            // orientation == landscape;
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      YoutubePlayer(
                        controller: _youtubeController,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.red,
                        onReady: () {
                          print("Video is ready to play");
                        },
                        onEnded: (data) {
                          print("Video has ended");
                        },
                      ),
                      Center(
                        child: AnimatedOpacity(
                          opacity: _controlsVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Backward button
                              IconButton(
                                icon: const Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                onPressed: _seekBackward,
                              ),
                              const SizedBox(width: 40),
                              IconButton(
                                icon: const Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                onPressed: _seekForward,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
