import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:trusir/common/delete.dart';
import 'package:trusir/student/main_screen.dart';
import 'package:trusir/student/teacher_profile_page.dart';

class Mycourses extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  const Mycourses({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return courses.isEmpty
        ? const Center(child: Text('No Courses'))
        : isWeb
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisExtent: 560),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return MyCourseCard(
                    course: course,
                  );
                },
              )
            : ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return MyCourseCard(
                    course: course,
                  );
                },
              );
  }
}

class MyCourseCard extends StatefulWidget {
  final Map<String, dynamic> course;

  const MyCourseCard({super.key, required this.course});

  @override
  State<MyCourseCard> createState() => _MyCourseCardState();
}

class _MyCourseCardState extends State<MyCourseCard> {
  bool isWeb = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isWeb = MediaQuery.of(context).size.width > 600;
    double discount = 100 -
        int.parse(widget.course['new_amount']) /
            int.parse(widget.course['amount']) *
            100;

    String formattedDiscount = discount.toStringAsFixed(2);
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isWeb ? 30 : 16, vertical: isWeb ? 15 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isWeb ? 30 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.course['image'],
                    width: double.infinity,
                    height: isWeb ? 300 : 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error,
                          size: 40,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Best Seller',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isWeb ? 18 : 14,
                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                        onPressed: () {
                          DeleteUtility.deleteItem(
                              'individualSlot', widget.course['slotID']);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MainScreen(index: 1)));
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.redAccent,
                        )))
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.course['name'],
              style: TextStyle(
                fontSize: isWeb ? 21 : 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.course['subject'],
              style: TextStyle(
                fontSize: isWeb ? 18 : 14,
                fontFamily: 'Poppins',
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  '₹${widget.course['new_amount']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  '₹${widget.course['amount']}', // Placeholder for original price
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  '$formattedDiscount% OFF', // Placeholder for original price
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: isWeb ? 200 : 300,
                height: isWeb ? 40 : null,
                child: ElevatedButton(
                  onPressed: () {
                    widget.course['teacherID'] == 'N/A'
                        ? Fluttertoast.showToast(
                            msg: 'No Teachers Assigned Yet')
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TeacherProfilePage(
                                    userID: widget.course['teacherID'])),
                          );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Know More',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
