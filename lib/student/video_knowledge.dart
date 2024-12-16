import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:chewie/chewie.dart';

class VideoKnowledge extends StatefulWidget {
  const VideoKnowledge({super.key});

  @override
  State<VideoKnowledge> createState() => _VideoKnowledgeState();
}

class _VideoKnowledgeState extends State<VideoKnowledge> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _videos = [
    {
      'title': 'Learn Flutter Basics',
      'url':
          'https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/sample-mp4-file.mp4',
      'thumbnail':
          'https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg',
      'time': '9:45 AM',
      'description': 'description',
      'profile':
          'https://th.bing.com/th/id/OIP.XSZAFm-5JI7nriDLwZqRQQHaE7?rs=1&pid=ImgDetMain.jpg'
    },
    {
      'title': 'Advanced Dart Techniques',
      'url':
          'https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/sample-mp4-file.mp4',
      'thumbnail': 'https://via.placeholder.com/300x169.png?text=Dart+Advanced',
      'time': '10:45 AM',
      'description': 'description',
      'profile':
          'https://th.bing.com/th/id/OIP.XSZAFm-5JI7nriDLwZqRQQHaE7?rs=1&pid=ImgDetMain.jpg'
    },
    {
      'title': 'Understanding State Management',
      'url':
          'https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/sample-mp4-file.mp4',
      'thumbnail':
          'https://th.bing.com/th/id/OIP.XSZAFm-5JI7nriDLwZqRQQHaE7?rs=1&pid=ImgDetMain.jpg',
      'time': '9:45 PM',
      'description': 'description',
      'profile':
          'https://th.bing.com/th/id/OIP.XSZAFm-5JI7nriDLwZqRQQHaE7?rs=1&pid=ImgDetMain.jpg'
    },
  ];

  List<Map<String, String>> _filteredVideos = [];

  @override
  void initState() {
    super.initState();
    _filteredVideos = _videos;
    _searchController.addListener(_filterVideos);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Color(0xFF48116A),
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 20),
              const Text(
                'Video Knowledge',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF48116A),
                ),
                hintText: 'Search videos',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontFamily: 'Poppins',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return WideScreenLayout(videos: _filteredVideos);
                  } else {
                    return MobileLayout(videos: _filteredVideos);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MobileLayout extends StatelessWidget {
  final List<Map<String, String>> videos;

  const MobileLayout({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return VideoCard(
          videoUrl: Uri.parse(videos[index]['url']!),
          title: videos[index]['title']!,
          thumbnailUrl: videos[index]['thumbnail']!,
          description: videos[index]['description']!,
          channelPicUrl: videos[index]['profile']!,
          uploadTime: videos[index]['time']!,
        );
      },
    );
  }
}

class WideScreenLayout extends StatelessWidget {
  final List<Map<String, String>> videos;

  const WideScreenLayout({super.key, required this.videos});

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
          videoUrl: Uri.parse(videos[index]['url']!),
          title: videos[index]['title']!,
          thumbnailUrl: videos[index]['thumbnail']!,
          description: videos[index]['description']!,
          channelPicUrl: videos[index]['profile']!,
          uploadTime: videos[index]['time']!,
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
              builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
            ),
          );
        },
        child: Card(
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
                        color: Colors.grey[300],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16.0,
                              backgroundImage: NetworkImage(
                                  channelPicUrl), // Channel picture
                              backgroundColor: Colors.grey[300],
                            ),
                            const SizedBox(width: 8.0),
                            RichText(
                              text: TextSpan(
                                text: title,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          uploadTime,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
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

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _videoPlayerController = VideoPlayerController.networkUrl(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: true,
            looping: false,
            aspectRatio: _videoPlayerController.value.aspectRatio,
            allowedScreenSleep: false,
            autoInitialize: true,
            additionalOptions: (context) {
              return [
                OptionItem(
                  onTap: () => _showCustomOption(),
                  iconData: Icons.info_outline,
                  title: 'Info',
                ),
              ];
            },
            subtitle: Subtitles([]),
            subtitleBuilder: (context, subtitle) => Container(
              padding: const EdgeInsets.all(10.0),
              color: Colors.black45,
              child: Text(
                subtitle,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.black,
            ),
          );
        });
      });
  }

  void _showCustomOption() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Custom option clicked")),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
