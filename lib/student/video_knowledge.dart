import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
    },
    {
      'title': 'Advanced Dart Techniques',
      'url':
          'https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/sample-mp4-file.mp4',
      'thumbnail': 'https://via.placeholder.com/300x169.png?text=Dart+Advanced',
    },
    {
      'title': 'Understanding State Management',
      'url':
          'https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/sample-mp4-file.mp4',
      'thumbnail':
          'https://via.placeholder.com/300x169.png?text=State+Management',
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
          videoUrl: videos[index]['url']!,
          title: videos[index]['title']!,
          thumbnailUrl: videos[index]['thumbnail']!,
          description: 'lorem adkjs sakndnsand sdldsd lkdsl dlsl lorem adkjs sakndnsand sdldsd lkdsl dlsl lorem adkjs sakndnsand sdldsd lkdsl dlsl', channelPicUrl: '', uploadTime: '9:45 AM',
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
          videoUrl: videos[index]['url']!,
          title: videos[index]['title']!,
          thumbnailUrl: videos[index]['thumbnail']!,
          description: '', channelPicUrl: '', uploadTime: '',
        );
      },
    );
  }
}

class VideoCard extends StatelessWidget {
  final String videoUrl;
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(0.0)),
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
                      backgroundImage: NetworkImage(channelPicUrl), // Channel picture
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
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
)
);
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
