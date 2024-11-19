import 'package:flutter/material.dart';
import 'package:trusir/enquiry.dart';
import 'package:trusir/menu.dart';
import 'package:trusir/student_homepage.dart';

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
  _TrusirLoginPageState createState() => _TrusirLoginPageState();
}

class _TrusirLoginPageState extends State<TrusirLoginPage> {
  String? _selectedLanguage;
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
            return SingleChildScrollView(
              child: ConstrainedBox(
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
                        SizedBox(height: responsive.safeHeight * 0.08),
                        _buildCarousel(responsive),
                        SizedBox(height: responsive.safeHeight * 0.08),
                        _buildPageIndicators(responsive),
                        SizedBox(height: responsive.safeHeight * 0.08),
                        _buildPhoneInput(responsive),
                        SizedBox(height: responsive.safeHeight * 0.08),
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
          child: Image.asset(
            'assets/skipbutton.png',
            width: responsive.screenWidth * 0.15,
            height: responsive.safeHeight * 0.05,
            fit: BoxFit.contain,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EnquiryPage()),
          ),
          child: const Text('go'),
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
      items: <String>['Hindi', 'Punjabi', 'Marathi']
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
                  style: TextStyle(
                    fontSize: responsive.titleSize,
                    fontWeight: FontWeight.w900,
                    color: const Color.fromRGBO(72, 17, 106, 1),
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
                SizedBox(height: responsive.safeHeight * 0.02),
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
        Image.asset(
          'assets/textfield.png',
          width: double.infinity,
          height: responsive.safeHeight * 0.08,
          fit: BoxFit.fill,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.screenWidth * 0.03,
            vertical: responsive.safeHeight * 0.015,
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/indianflag.png',
                width: responsive.flagIconSize,
                height: responsive.flagIconSize,
              ),
              SizedBox(width: responsive.screenWidth * 0.02),
              Text(
                "+91 |",
                style: TextStyle(
                  fontSize: responsive.screenWidth * 0.04,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(width: responsive.screenWidth * 0.02),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: responsive.screenWidth * 0.04),
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
      ],
    );
  }

  Widget _buildSendOTPButton(ResponsiveDimensions responsive) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentHomepage()),
          );
        },
        child: Image.asset(
          'assets/send_otp.png',
          width: responsive.screenWidth * 0.8,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  void _onPost() {
    print("OTP sent");
  }
}
