import 'package:flutter/material.dart';



class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/dikshaback@2x.png',
                                width: 58,
                                height: 58,
                              ),
                              const SizedBox(
                                width: 135,
                              ),
                             const Text(
                               'Notice',
                               style: TextStyle(
                                 color: Color(0xFF48116A),
                                 fontSize: 22,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 20, right: 10),
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
                      padding: const EdgeInsets.only(left: 10, top: 20, right: 10),
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
                      padding: const EdgeInsets.only(left: 10, top: 20, right: 10),
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
                  
                      const SizedBox(
                        height: 40,
                      ),
                      
                  ],
                ),
              ),
            ),
             Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: InkWell(
                  onTap: () {   
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF045C19),
                          Color(0xFF77D317),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Add Notice',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'Poppins'
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ],
        ),
      );
  }
}
