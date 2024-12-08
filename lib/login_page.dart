import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/menu.dart';
import 'package:trusir/otp_screen.dart';

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
  double get carouselImageWidth => screenWidth * 0.8;
  double get flagIconSize => screenWidth * 0.06;
}

class TrusirLoginPage extends StatefulWidget {
  // Allow customization of carousel image size ratio
  final double carouselImageHeightRatio;

  const TrusirLoginPage({
    super.key,
    this.carouselImageHeightRatio = 0.4, // Default ratio can be adjusted
  });

  @override
  TrusirLoginPageState createState() => TrusirLoginPageState();
}

class TrusirLoginPageState extends State<TrusirLoginPage> {
  String? _selectedLanguage;
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
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            phonenum = _phonecontroller.text;
          });
          // sendOTP(phonenum);
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
        },
        child: Image.asset(
          'assets/send_otp.png',
          width: responsive.screenWidth,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // Future<void> sendOTP(String phoneNumber) async {
  //   final url = Uri.parse(
  //     '$otpapi/SMS/+91$phoneNumber/AUTOGEN3/Test',
  //   );

  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       print('OTP sent successfully: ${response.body}');
  //       storePhoneNo();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('OTP Sent Successfully'),
  //           duration: Duration(seconds: 1),
  //         ),
  //       );
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => OTPScreen(
  //                     phonenum: phonenum,
  //                   )));
  //     } else {
  //       print('Failed to send OTP: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error sending OTP: $e');
  //   }
  // }

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
      backgroundColor: Colors.grey.shade100,
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
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(responsive),
                        SizedBox(height: responsive.safeHeight * 0.08),
                        _buildCarousel(responsive),
                        SizedBox(height: responsive.safeHeight * 0.06),
                        _buildPageIndicators(responsive),
                        SizedBox(height: responsive.safeHeight * 0.04),
                        _buildPhoneInput(responsive),
                        SizedBox(height: responsive.safeHeight * 0.04),
                        _buildSendOTPButton(responsive),
                      ],
                    ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            showPopupDialog(context);
          },
          child: Container(
            height: 30,
            width: 54,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8)),
            child: const Center(
              child: Text(
                'Skip',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
        _buildLanguageDropdown(responsive),
      ],
    );
  }

  Widget _buildLanguageDropdown(ResponsiveDimensions responsive) {
    return DropdownButton<String>(
      value: _selectedLanguage,
      hint: Text(
        "Language",
        style: TextStyle(fontSize: responsive.screenWidth * 0.04),
      ),
      items: <String>['Hindi', 'English']
          .map<DropdownMenuItem<String>>((String language) {
        return DropdownMenuItem<String>(
          value: language,
          child: Text(
            language,
            style: TextStyle(fontSize: responsive.screenWidth * 0.04),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedLanguage = newValue;
        });
      },
    );
  }

  Widget _buildCarousel(ResponsiveDimensions responsive) {
    return SizedBox(
      height: responsive.safeHeight * widget.carouselImageHeightRatio,
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
                SizedBox(height: responsive.safeHeight * 0.01),
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
                  child: TextField(
                    keyboardType: TextInputType.phone,
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
