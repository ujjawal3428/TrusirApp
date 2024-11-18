import 'dart:convert';
import 'package:http/http.dart' as http;

class TestSeriesService {
  static const String _url = 'https://balvikasyojana.com:8899/test-series/testID';

  Future<List<TestSeries>> fetchTestSeries() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body);
      return jsonData.map((data) => TestSeries.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load test series');
    }
  }
}


class TestSeries {
  final String name;
  final String subject;
  final String date;
  final String time;
  final String questionsUrl;
  final String answersUrl;

  TestSeries({
    required this.name,
    required this.subject,
    required this.date,
    required this.time,
    required this.questionsUrl,
    required this.answersUrl,
  });

  factory TestSeries.fromJson(Map<String, dynamic> json) {
    return TestSeries(
      name: json['name'],
      subject: json['subject'],
      date: json['date'],
      time: json['time'],
      questionsUrl: json['questions'],
      answersUrl: json['answers'],
    );
  }
}






/*


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
            'Questions',
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
            'Questions',
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
            'Questions',
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


*/