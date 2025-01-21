import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'specificextraknowledge.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trusir/common/api.dart';

class KnowledgeItem {
  final int id;
  final String category;
  final String subCategory;
  final String image;
  final String title;
  final String description;

  KnowledgeItem({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.image,
    required this.title,
    required this.description,
  });

  // Factory constructor to create an instance from JSON
  factory KnowledgeItem.fromJson(Map<String, dynamic> json) {
    return KnowledgeItem(
      id: json['id'] as int,
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      image: json['image'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  // Method to convert the instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'sub_category': subCategory,
      'image': image,
      'title': title,
      'description': description,
    };
  }
}

class ExtraKnowledge extends StatefulWidget {
  const ExtraKnowledge({super.key});

  @override
  State<ExtraKnowledge> createState() => _ExtraKnowledgeState();
}

class _ExtraKnowledgeState extends State<ExtraKnowledge> {
  final TextEditingController _searchController = TextEditingController();
  bool isTeacherSelected = false;
  List<KnowledgeItem> recentlyViewed = [];
  List<KnowledgeItem> allgks = [];
  List<String> categories = [];
  String selectedCategory = '';
  String selectedSubcategory = '';
  List<String> subcategory = [];
  List<KnowledgeItem> gks = [];

  Future<void> fetchSubCategories(String category) async {
    try {
      // Clear previous subcategories before fetching new ones
      setState(() {
        subcategory = [];
        gks = [];
      });

      // Build the URL by appending the category name
      final String url = "$baseUrl/get-gks-sub-category/$category";

      // Fetch data from the API
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode JSON response
        List<dynamic> jsonResponse = jsonDecode(response.body);

        // Update the subcategory list in the state
        setState(() {
          subcategory =
              jsonResponse.map((item) => item['name'] as String).toList();
          selectedCategory = category;
          selectedSubcategory = subcategory[0];
          fetchGks();
        });

        // Print the subcategory names for debugging
      } else {
        print(
            "Failed to fetch subcategories for $category. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching subcategories for $category: $e");
    }
  }

  Future<List<KnowledgeItem>> fetchAllGks() async {
    const String apiUrl = "$baseUrl/get-gks";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((item) => KnowledgeItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load gks');
      }
    } catch (e) {
      print("Error fetching all gks: $e");
      return [];
    }
  }

  void initialize() async {
    final gks = await fetchAllGks();
    setState(() {
      allgks = gks;
    });
    await fetchcategories();
    setState(() {
      selectedCategory = categories[0];
    });
    await fetchSubCategories(selectedCategory);
    setState(() {
      selectedSubcategory = subcategory[0];
      fetchGks();
    });
  }

  Future<void> fetchcategories() async {
    const String apiUrl = "$baseUrl/get-gks-category";

    // Fetch data from the API
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decode JSON response
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          categories =
              jsonResponse.map((item) => item['name'] as String).toList();
        });
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> fetchGks() async {
    String apiUrl = "$baseUrl/get-gks/$selectedCategory/$selectedSubcategory";

    // Fetch data from the API
    try {
      setState(() {
        gks = [];
      });
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decode JSON response
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          gks = jsonResponse
              .map((item) =>
                  KnowledgeItem.fromJson(item as Map<String, dynamic>))
              .toList();
        });
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> loadRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('recentlyViewed');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        recentlyViewed = jsonList
            .map((item) => KnowledgeItem.fromJson(item as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> saveRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final data =
        jsonEncode(recentlyViewed.map((item) => item.toJson()).toList());
    await prefs.setString('recentlyViewed', data);
  }

  // Add a new item to recently viewed
  void addToRecentlyViewed(KnowledgeItem item) {
    setState(() {
      // Remove the item if it already exists
      recentlyViewed.removeWhere((viewedItem) => viewedItem.id == item.id);
      // Add the new item to the beginning of the list
      recentlyViewed.insert(0, item);
      // Ensure the list doesn't exceed 5 items
      if (recentlyViewed.length > 5) {
        recentlyViewed = recentlyViewed.sublist(0, 5);
      }
    });
    saveRecentlyViewed();
  }

  @override
  void initState() {
    super.initState();
    initialize();
    loadRecentlyViewed();
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
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset('assets/back_button.png', height: 50),
              ),
              const SizedBox(width: 20),
              const Text(
                'Extra Knowledge',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                _buildSearchBar(),
                categories.isEmpty
                    ? const Text('No Categories available')
                    : _buildCategoryList(),
                subcategory.isEmpty
                    ? selectedCategory.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 16.0),
                                child: Text(
                                  selectedCategory,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  height: 50,
                                  child: Center(
                                      child:
                                          Text('No Sub-Categories available'))),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 16.0),
                                child: Text(
                                  selectedCategory,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  height: 50,
                                  child: Center(
                                      child:
                                          Text('Select a Category to start'))),
                            ],
                          )
                    : _buildSubcategoriesSection(),
                gks.isEmpty
                    ? subcategory.isNotEmpty
                        ? const SizedBox(
                            height: 50,
                            child: Center(child: Text('Select a Sub-Category')))
                        : const SizedBox()
                    : _buildThumbnailGallery(),
                _buildRecentlyViewed(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Search GK',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      // Implement search functionality here
                      setState(() {
                        // Filter your gks list based on search value
                      });
                    },
                    style: const TextStyle(fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey.shade500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400),
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allgks.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final gk = allgks[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpecificExtraKnowledge(
                                title: gk.title,
                                imagePath: gk.image,
                                content: gk.description,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  gk.image,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gk.title,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      gk.description,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            gk.category,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            gk.subCategory,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              color: Colors.purple.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              'Search..',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(Icons.search, color: Colors.grey.shade600)
          ],
        ),
      ),
    ),
  );
}

Widget _buildCategoryList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _buildCategoryChip(categories[index]),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildCategoryChip(String category) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade700, Colors.blue.shade500],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextButton(
      onPressed: () {
        fetchSubCategories(category);
        setState(() {});
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        '${category[0].toUpperCase()}${category.substring(1)}',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget _buildThumbnailGallery() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Text(
          '${selectedSubcategory[0].toUpperCase()}${selectedSubcategory.substring(1)}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: gks.length,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) {
            final item = gks[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpecificExtraKnowledge(
                      title: item.title,
                      imagePath: item.image,
                      content: item.description,
                    ),
                  ),
                );
                addToRecentlyViewed(item);
              },
              child: Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(item.image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildSubcategoriesSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Text(
         '${selectedCategory[0].toUpperCase()}${selectedCategory.substring(1)}',

          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: subcategory.length,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSubcategory = subcategory[index];
                });
                fetchGks();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Chip(
                  label: Text(
                    subcategory[index].isNotEmpty
      ? '${subcategory[index][0].toUpperCase()}${subcategory[index].substring(1)}'
      : '',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildRecentlyViewed() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Text(
          'Recently Viewed',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      if (recentlyViewed.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'No recently viewed items',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        )
      else
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentlyViewed.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final item = recentlyViewed[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpecificExtraKnowledge(
                        title: item.title,
                        imagePath: item.image,
                        content: item.description,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(item.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
    ],
  );
}}