import 'package:flutter/material.dart';


class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 30),
                  child: Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/dikshaback@2x.png',
                          width: 58,
                          height: 58,
                        ),
                        const Text(
                          'Courses',
                          style: TextStyle(
                           color:  Color(0xFF48116A),
                    
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    
                        Padding(
                          padding: const EdgeInsets.only(left: 200),
                          child: TextButton(onPressed: (){},
                           child: const Text('Cancel Course', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(child: Text('Courses Enrolled', style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),)),
               const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child:
              
              Container(
                width: 386,
                height: 112,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFC22054),
                      Color(0xFF48116A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                       Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 20.0, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mathematics',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Course started on: 14th Dec 2022',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child:
              Container(
                width: 386,
                height: 112,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFC22054),
                      Color(0xFF48116A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                       Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 20.0, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Science',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Course started on: 14th Dec 2022',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
                const SizedBox(height: 20),
              const Center(child: Text('Add Courses', style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),)),

              Padding(
                padding: const EdgeInsets.only(left: 10, top: 20, right: 10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 386,
                      height: 90,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/whitebg@4x.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child:const Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('English', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                          Text('Rs. 2000',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                        ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 386,
                      height: 90,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/whitebg@4x.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child:const Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hindi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                          Text('Rs. 2000',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                        ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 386,
                      height: 90,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/whitebg@4x.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Padding(
                        padding:  EdgeInsets.all(25.0),
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Social Science', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                          Text('Rs. 2000',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                        ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50,),
              InkWell(
                onTap: () {
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 388,
                      height: 73,
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
                          'Add Courses',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
