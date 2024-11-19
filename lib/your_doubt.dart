import 'package:flutter/material.dart';

class YourDoubtPage extends StatelessWidget {
  const YourDoubtPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/dikshaback@2x.png',
                            width: 58,
                            height: 58,
                          ),
                          const SizedBox(width: 22),
                          const Text(
                            'Your Doubts',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            
                  const SizedBox(height: 20,),
            
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                       width: MediaQuery.of(context).size.width * 1, 
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade100,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                           const  Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:  EdgeInsets.only(left: 5.0, top: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:  [
                                        Text(
                                          'Name of test',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Science',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '28/08/2024',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding:  EdgeInsets.only(top: 10.0),
                                    child: Column(
                                      children:  [
                                        Padding(
                                          padding: EdgeInsets.only(left: 20.0),
                                          child: Text(
                                            '10:42 AM',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            
                          
                           Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                Container(
                  width: MediaQuery.of(context).size.width * 0.4, 
                  height: 37,
                  decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.indigo.shade900,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Doubts',
                style: TextStyle(
                  color: Colors.indigo.shade900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.file_download_rounded,
                color: Colors.indigo.shade900,
                size: 16,
              ),
            ],
                  ),
                ),
                const SizedBox(width: 5), 
                
                Container(
                  width: MediaQuery.of(context).size.width * 0.4, 
                  height: 37,
                  decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.blue.shade900,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Answers',
                style: TextStyle(
                  color: Colors.indigo.shade900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.file_download_rounded,
                color: Colors.indigo.shade900,
                size: 16,
              ),
            ],
                  ),
                ),
              ],
            ),
            
                          ],
                        ),
                      ),
                    ),
                  ),
            
                    Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                       width: MediaQuery.of(context).size.width * 1, 
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                           const  Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:  EdgeInsets.only(left: 5.0, top: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:  [
                                        Text(
                                          'Name of test',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Science',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '28/08/2024',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding:  EdgeInsets.only(top: 10.0),
                                    child: Column(
                                      children:  [
                                        Padding(
                                          padding: EdgeInsets.only(left: 20.0),
                                          child: Text(
                                            '10:42 AM',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            
                          
                           Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                Container(
                  width: MediaQuery.of(context).size.width * 0.4, 
                  height: 37,
                  decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.indigo.shade900,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Doubts',
                style: TextStyle(
                  color: Colors.indigo.shade900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.file_download_rounded,
                color: Colors.indigo.shade900,
                size: 16,
              ),
            ],
                  ),
                ),
                const SizedBox(width: 5), 
                
                Container(
                  width: MediaQuery.of(context).size.width * 0.4, 
                  height: 37,
                  decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.blue.shade900,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Answers',
                style: TextStyle(
                  color: Colors.indigo.shade900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.file_download_rounded,
                color: Colors.indigo.shade900,
                size: 16,
              ),
            ],
                  ),
                ),
              ],
            ),
            
                          ],
                        ),
                      ),
                    ),
                  ),
            
            
                    Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                       width: MediaQuery.of(context).size.width * 1, 
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                           const  Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:  EdgeInsets.only(left: 5.0, top: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:  [
                                        Text(
                                          'Name of test',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Science',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '28/08/2024',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding:  EdgeInsets.only(top: 10.0),
                                    child: Column(
                                      children:  [
                                        Padding(
                                          padding: EdgeInsets.only(left: 20.0),
                                          child: Text(
                                            '10:42 AM',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            
                          
                           Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                Container(
                  width: MediaQuery.of(context).size.width * 0.4, 
                  height: 37,
                  decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.indigo.shade900,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Doubts',
                style: TextStyle(
                  color: Colors.indigo.shade900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.file_download_rounded,
                color: Colors.indigo.shade900,
                size: 16,
              ),
            ],
                  ),
                ),
                const SizedBox(width: 5), 
                
                Container(
                  width: MediaQuery.of(context).size.width * 0.4, 
                  height: 37,
                  decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.blue.shade900,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Answers',
                style: TextStyle(
                  color: Colors.indigo.shade900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.file_download_rounded,
                color: Colors.indigo.shade900,
                size: 16,
              ),
            ],
                  ),
                ),
              ],
            ),
            
                          ],
                        ),
                      ),
                    ),
                  ),
            
                    Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                       width: MediaQuery.of(context).size.width * 1, 
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade100,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                           const  Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:  EdgeInsets.only(left: 5.0, top: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:  [
                                        Text(
                                          'Name of test',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Science',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '28/08/2024',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding:  EdgeInsets.only(top: 10.0),
                                    child: Column(
                                      children:  [
                                        Padding(
                                          padding: EdgeInsets.only(left: 20.0),
                                          child: Text(
                                            '10:42 AM',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            
                          
                           Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                Container(
                  width: MediaQuery.of(context).size.width * 0.4, 
                  height: 37,
                  decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.indigo.shade900,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Doubts',
                style: TextStyle(
                  color: Colors.indigo.shade900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.file_download_rounded,
                color: Colors.indigo.shade900,
                size: 16,
              ),
            ],
                  ),
                ),
                const SizedBox(width: 5), 
                
                Container(
                  width: MediaQuery.of(context).size.width * 0.4, 
                  height: 37,
                  decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.blue.shade900,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Answers',
                style: TextStyle(
                  color: Colors.indigo.shade900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.file_download_rounded,
                color: Colors.indigo.shade900,
                size: 16,
              ),
            ],
                  ),
                ),
              ],
            ),
            
                          ],
                        ),
                      ),
                    ),
                  ),
            
              
                ],
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
                        'Create Doubt',
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
      ),
    );
  }
}
