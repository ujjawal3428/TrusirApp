import 'package:flutter/material.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
  backgroundColor: Colors.grey[50],
  elevation: 0,
  automaticallyImplyLeading: false,
  title: Padding(
    padding: const EdgeInsets.only(left: 1.0), 
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
       const SizedBox(width: 5), 
        const Text(
          'Notice',
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
  floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16.0, right: 16.0), 
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.grey[300]!, Colors.white], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Your onPressed action
          },
          elevation: 0, // To match the gradient
          backgroundColor:const Color(0xFF48116A), // Transparent for gradient to show
          child: const Icon(
            Icons.add, // Plus icon
          color: Colors.white,
            size: 50, // Icon size
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left:15, right: 15, bottom: 15, top : 0),
              child: Column(
                children: [
  
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 10, right: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 386,
                          height: 136,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 251, 202, 218),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 55, top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Republic Day Holiday',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Posted on : January 26, 2023',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'The class will have a off on 26th Jan 2023 on the occasion of Republic Day',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Image.asset(
                            'assets/bell.png',
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 20, right: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 386,
                          height: 136,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 182, 211, 255),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 55, top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Republic Day Holiday',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Posted on : January 26, 2023',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'The class will have a off on 26th Jan 2023 on the occasion of Republic Day',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Image.asset(
                            'assets/bell.png',
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 20, right: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 386,
                          height: 136,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 255, 229, 142),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 55, top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Republic Day Holiday',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Posted on : January 26, 2023',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'The class will have a off on 26th Jan 2023 on the occasion of Republic Day',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Image.asset(
                            'assets/bell.png',
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
