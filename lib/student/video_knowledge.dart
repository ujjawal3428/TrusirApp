import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      'thumbnail':
          'https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg',
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Color(0xFF48116A),
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
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
          const CategoriesList(),
          const SizedBox(height: 10),
          Expanded(
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
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
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

class CategoriesList extends StatefulWidget {
  const CategoriesList({super.key});

  @override
  CategoriesListState createState() => CategoriesListState();
}

class CategoriesListState extends State<CategoriesList> {
  // List of categories
  final List<String> categories = [
    'English',
    'Hindi',
    'Maths',
    'Science',
    'History',
    'GK'
  ];

  // Currently selected category
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          bool isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
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
                title: title,
                description: description,
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
  final String title;
  final String description;

  const VideoPlayerScreen(
      {super.key,
      required this.videoUrl,
      required this.title,
      required this.description});

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
            allowPlaybackSpeedChanging: true,
            looping: false,
            aspectRatio: _videoPlayerController.value.aspectRatio,
            allowedScreenSleep: false,
            showControlsOnInitialize: true,
            materialSeekButtonFadeDuration: const Duration(milliseconds: 100),
            materialSeekButtonSize: 30,
            hideControlsTimer: const Duration(seconds: 2),
            autoInitialize: true,
            draggableProgressBar: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.red,
              handleColor: Colors.white,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.black,
            ),
          );
        });
      });
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Center(
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
