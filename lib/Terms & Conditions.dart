import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        elevation: 0,
        leading: GestureDetector(
          onTap: () => _goBack(context),
          child: Container( 
            margin: const EdgeInsets.only(left: 20.0, top: 20.0),
            child: Image.asset(
              "back_button.png", // Ensure this path is correct
              width: 40,  // Set to a smaller size for a standard back button
              height: 40,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            "Terms & Conditions",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900, 
              color: Colors.deepPurple,
            ),
          ),
        ),
        centerTitle: true, // Center title in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Aligns all text to the left
            children: [
              SizedBox(height: 20), // Add space if needed
              Text(
                '1. Acceptance of Terms:',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              
              Text(
                'By accessing or using the Trusir app, you agree to be legally bound by these Terms and Conditions. If you do not agree to these Terms and Conditions, you must not access or use the Trusir app.',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  
                ),
              ),

              SizedBox(height: 20),


              Text(
                '2. License:',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              
              
              Text(
                'Trusir grants you a limited, non-exclusive, non-transferable license to use the Trusir app. This license gives you the right to access and use the Trusir app for your personal, non-commercial purposes.',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 20),

               Text(
                '3. User Content:',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              

              Text(
                'You understand that any content that you post or submit to the Trusir app may be viewed by other users. You are solely responsible for all the content that you post or submit to the Trusir app and any consequences arising out of such content. You agree to not post or submit any content that is defamatory, offensive, pornographic, or otherwise inappropriate.',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 20),

              Text(
                '4. Disclaimer:',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              

              Text(
                'The Trusir app and all content and services provided on the app are provided on an “as is” basis.  Trusir does not warrant or guarantee the accuracy or completeness of any content or services provided on the app. Trusir is not responsible for any errors or omissions in the content or services provided on the app.',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 20),
            
            Text(
                '5. Limitation of Liability:',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              

              Text(
                'Trusir is not liable for any direct, indirect, incidental, punitive, or consequential damages arising out of the use of the Trusir app. This includes, but is not limited to, damages resulting from errors or omissions in the content or services provided on the app.',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 20),

              Text(
                '6. Indemnification:',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              

              Text(
                'You agree to indemnify and hold harmless Trusir Farm from and against all claims, damages, losses, and expenses (including legal fees) arising out of or related to your use of the Trusir.',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 20),

              Text(
                '7. Termination:',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              

              Text(
                'Trusir may terminate your access to the Trusir app at any time for any reason. Upon termination, you must immediately cease using the Trusir app.',
                textAlign: TextAlign.left, // Aligns text to the left
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }

  // Go back function
  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
