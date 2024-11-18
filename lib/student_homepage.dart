import 'package:flutter/material.dart';
import 'package:trusir/studentfacilities.dart';

class StudentHomepage extends StatelessWidget {
  const StudentHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with logo and language selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'trusir',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              DropdownButton<String>(
                items: const [
                  DropdownMenuItem(
                    value: 'English',
                    child: Text('Language',
                        style: TextStyle(fontFamily: 'Poppins')),
                  ),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Welcome text
          const Text(
            'Welcome To Trusir',
            style: TextStyle(
              fontSize: 47,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const Divider(color: Colors.black, thickness: 1.5, endIndent: 200),
          const SizedBox(height: 10),
          const Text(
            'Trusir is a registered and trusted Indian company that offers Home to Home tuition service. We have a clear vision of helping students achieve their academic goals through one-to-one teaching.',
            style: TextStyle(fontSize: 26, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 20),

          // Services ListView (Horizontal)
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _serviceCard(
                  title: 'Trusted Teachers',
                  imagePath: 'assets/girlimage@4x.png',
                  backgroundColor: Colors.pink.shade50,
                ),
                _serviceCard(
                  title: 'Home to Home Tuition',
                  imagePath: 'assets/girlimage@4x.png',
                  backgroundColor: Colors.orange.shade50,
                ),
                _serviceCard(
                  title: 'Qualified And Trusted Teachers',
                  imagePath: 'assets/girlimage@4x.png',
                  backgroundColor: Colors.blue.shade50,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Our Services title
          const Text(
            'Our Services',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),

          // Offline Payment Button with descriptive text
          Center(
            child: GestureDetector(
              onTap: () {
                // Define your onTap action here
              },
              child: Column(
                children: [
                  Image.asset(
                    'assets/g1@4x.png',
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Click here for registration text
          const Center(
            child: Text(
              'Click here for registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Additional text sections
          const Center(
            child: Column(
              children: [
                Text(
                  'Get the Best Tutor for your child',
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Get the best learning support for your child',
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'For all your learning support needs such as homework, test, school project and examinations; we are here to give you the best support.',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  'The best tutors are here',
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Our tutors are seasoned professionals, screened and given relevant training on a monthly basis to deliver the excellent results you desire.',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Row of two images
          Column(
            children: [
              Image.asset(
                'assets/t1@3x.png',
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/t2.jpg',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Explore our offerings text
          const Center(
            child: Text(
              'Explore our offerings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 43, 58, 100),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Subjects Buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              'Nursery',
              'LKG',
              'UKG',
              'Class 1',
              'Class 2',
              'Class 3',
              'Class 4',
              'Class 5',
              'Class 6',
              'Class 7',
              'Class 8',
              'Class 9',
              'Class 10',
            ].map((subject) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subject,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Explore Subjects title
          const Center(
            child: Text(
              'Explore Subjects',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 43, 58, 100),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              'Hindi',
              'English',
              'Maths',
              'Science: Physics, Chemistry, Biology',
              'Social Science: History, Geography, Political Science, Economics'
            ].map((subject) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subject,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Studentfacilities(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
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
                          'Registeration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    )));
  }

  Widget _serviceCard(
      {required String title,
      required String imagePath,
      required Color backgroundColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 160,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 100, fit: BoxFit.cover),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class ContactInfoRow extends StatelessWidget {
  final String imagePath;
  final String info;

  const ContactInfoRow(
      {super.key, required this.imagePath, required this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          imagePath,
          height: 60,
          width: 60,
        ),
        const SizedBox(width: 10),
        Text(
          info,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
