import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/student/menu.dart';
import 'package:http/http.dart' as http;
import 'package:trusir/common/api.dart';
import 'package:trusir/common/otp_screen.dart';

// Custom class to handle responsive dimensions
class ResponsiveDimensions {
  final double screenWidth;
  final double screenHeight;
  final double safeHeight;

  ResponsiveDimensions({
    required this.screenWidth,
    required this.screenHeight,
    required this.safeHeight,
  });

  // Responsive getters for common dimensions
  double get titleSize => screenWidth * 0.06;
  double get subtitleSize => screenWidth * 0.04;
  double get horizontalPadding => screenWidth * 0.05;
  double get verticalPadding => safeHeight * 0.02;

  // Image dimensions - can be adjusted as needed
  double get carouselImageHeight => safeHeight * 0.4;
  double get carouselImageWidth => screenWidth * 0.9;
  double get flagIconSize => screenWidth * 0.06;
}

class TrusirLoginPage extends StatefulWidget {
  // Allow customization of carousel image size ratio
  final double carouselImageHeightRatio;

  const TrusirLoginPage({
    super.key,
    this.carouselImageHeightRatio = 0.4,
  });

  @override
  TrusirLoginPageState createState() => TrusirLoginPageState();
}

class TrusirLoginPageState extends State<TrusirLoginPage> {
  final TextEditingController _phonecontroller = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String phonenum = '';

  Future<void> storePhoneNo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone_number', phonenum);
    print('Phone Number Stored to shared preferences: $phonenum');
  }

  final List<Map<String, String>> pageContent = [
    {
      'title': 'Home Tuitions',
      'subtitle': 'Get the tuition from the best \nteachers at your home',
      'imagePath': 'assets/girlimage@4x.png',
    },
    {
      'title': 'Special Education',
      'subtitle': 'Education for your child at home \nwith personal attention',
      'imagePath': 'assets/girlimage@4x.png',
    },
    {
      'title': '',
      'subtitle': '',
      'imagePath': 'assets/pamplate.png',
    },
    {
      'title': 'Trusted Teachers',
      'subtitle': 'Trusted teachers by \nTrusir',
      'imagePath': 'assets/girlimage@4x.png',
    },
    {
      'title': 'Monthly Test Series',
      'subtitle': 'Test series every month facility \nto test your kids',
      'imagePath': 'assets/girlimage@4x.png',
    },
  ];

  Widget _buildSendOTPButton(ResponsiveDimensions responsive) {
    return SafeArea(
      child: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              phonenum = _phonecontroller.text;
            });
      
            if (phonenum.length < 10 || !RegExp(r'^[0-9]+$').hasMatch(phonenum)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enter a valid phone number'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              sendOTP(phonenum);
              storePhoneNo();
            }
          },
          child: Image.asset(
            'assets/send_otp.png',
            width: responsive.screenWidth,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(ResponsiveDimensions responsive) {
    return Center(
      child: GestureDetector(
        onTap: () {
          showPopupDialog(context);
        },
        child: Image.asset(
          'assets/skipbutton.png',
          height: 35,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Future<void> sendOTP(String phoneNumber) async {
    final url = Uri.parse(
      '$otpapi/SMS/+91$phoneNumber/AUTOGEN3/TRUSIR_OTP',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('OTP sent successfully: ${response.body}');
        storePhoneNo();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP Sent Successfully'),
            duration: Duration(seconds: 1),
          ),
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTPScreen(
                      phonenum: phonenum,
                    )));
      } else {
        print('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final safeHeight = size.height - padding.top - padding.bottom;

    final responsive = ResponsiveDimensions(
      screenWidth: size.width,
      screenHeight: size.height,
      safeHeight: safeHeight,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true, // Adjust the layout when keyboard appears
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: responsive.verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(responsive),
                      SizedBox(height: responsive.safeHeight * 0.04),
                      _buildCarousel(responsive),
                      SizedBox(height: responsive.safeHeight * 0.04),
                      _buildPageIndicators(responsive),
                      SizedBox(height: responsive.safeHeight * 0.04),
                      _buildPhoneInput(responsive),
                      const Spacer(),
                      _buildSendOTPButton(responsive),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveDimensions responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [_buildSkipButton(responsive)],
    );
  }

  Widget _buildCarousel(ResponsiveDimensions responsive) {
    return SizedBox(
      height: 400,
      width: 600,
      child: PageView.builder(
        controller: _pageController,
        itemCount: pageContent.length,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          final hasText = pageContent[index]['title']!.isNotEmpty ||
              pageContent[index]['subtitle']!.isNotEmpty;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasText) ...[
                Text(
                  pageContent[index]['title']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Color.fromRGBO(72, 17, 106, 1),
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  pageContent[index]['subtitle']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.subtitleSize,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(194, 32, 84, 1),
                    fontFamily: 'Poppins-semi bold',
                  ),
                ),
              ],
              Expanded(
                child: Image.asset(
                  pageContent[index]['imagePath']!,
                  width: responsive.carouselImageWidth,
                  height: responsive.carouselImageHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPageIndicators(ResponsiveDimensions responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageContent.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin:
              EdgeInsets.symmetric(horizontal: responsive.screenWidth * 0.01),
          height: responsive.screenWidth * 0.03,
          width: responsive.screenWidth * 0.03,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color.fromRGBO(72, 17, 106, 1)
                : Colors.grey,
            borderRadius: BorderRadius.circular(180),
          ),
        );
      }),
    );
  }

  Widget _buildPhoneInput(ResponsiveDimensions responsive) {
    return Stack(
      children: [
        // Background shape for the input field
        Container(
          width: double.infinity,
          height: responsive.safeHeight * 0.08,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.screenWidth * 0.04,
            vertical: responsive.safeHeight * 0.01,
          ),
          child: Center(
            child: Row(
              children: [
                // Country flag icon
                Image.asset(
                  'assets/indianflag.png',
                  width: responsive.flagIconSize,
                  height: responsive.flagIconSize,
                ),
                SizedBox(width: responsive.screenWidth * 0.02),
                // Country code text
                Text(
                  "+91 |",
                  style: TextStyle(
                    fontSize: responsive.screenWidth * 0.04,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(width: responsive.screenWidth * 0.02),
                // Mobile number input field
                Expanded(
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null, // Hides counter
                    onChanged: (value) {
                      if (value.length == 10) {
                        FocusScope.of(context)
                            .unfocus(); // Dismiss keyboard after 6 digits
                      }
                    },
                    controller: _phonecontroller,
                    style: TextStyle(
                      fontSize: responsive.screenWidth * 0.04,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Mobile Number',
                      hintStyle: TextStyle(
                        fontSize: responsive.screenWidth * 0.04,
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
