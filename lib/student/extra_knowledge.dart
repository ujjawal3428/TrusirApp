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
                  _buildRecentlyViewed(),
                   const SizedBox(
                  height: 20,
                ),
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
                                      maxLines: 2,
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
}// Add this variable to track the selected category.

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
      color : selectedCategory == category
                        ? Colors.red
                        : Colors.indigo.shade900,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextButton(
      onPressed: () {
        setState(() {
          selectedCategory = category; // Update selectedCategory when clicked
        });
        fetchSubCategories(category); // Call the method to fetch subcategories
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
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
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
                      maxLines: 2,
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
  // Efficiently remove duplicates from subcategory list
  final uniqueSubcategories = subcategory.toSet().toList();

  return Padding(
    padding: const EdgeInsets.only(top: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontally scrollable subcategories
        SizedBox(
          height: 37,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: uniqueSubcategories.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final currentSubcategory = uniqueSubcategories[index];
              return GestureDetector(
                onTap: () {
                  selectedCategory = currentSubcategory;
                  (context as Element).markNeedsBuild();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedCategory == currentSubcategory
                        ? Colors.blue
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: Center(
                    child: Text(
                      currentSubcategory.capitalize(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selectedCategory == currentSubcategory
                        ? Colors.white
                        : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Vertical list of subcategories and their items
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: uniqueSubcategories.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final currentSubcategory = uniqueSubcategories[index];
            final subcategoryItems = gks
                .where((item) => item.subCategory == currentSubcategory)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subcategory title
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentSubcategory.capitalize(),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubcategoryDetailsPage(
                                subcategory: currentSubcategory,
                                items: subcategoryItems,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Horizontal list of KnowledgeItems for the subcategory
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subcategoryItems.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, itemIndex) {
                      final item = subcategoryItems[itemIndex];
                      return GestureDetector(
                        onTap: () {
                          addToRecentlyViewed(item);
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
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ],
    ),
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
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                            textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
}

// Extension method to capitalize first letter
extension StringCapitalization on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}

class SubcategoryDetailsPage extends StatelessWidget {
  final String subcategory;
  final List<KnowledgeItem> items;

  const SubcategoryDetailsPage({
    super.key,
    required this.subcategory,
    required this.items,
  });

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
              Text(
                subcategory.capitalize(),
                style: const TextStyle(
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
      body: ListView.builder(
        itemCount: items.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          final item = items[index];
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
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Image.network(
                    item.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


