import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar(
      {super.key,
      required int currentIndex,
      required void Function(int index) onTap});

  @override
  CustomBottomNavigationBarState createState() =>
      CustomBottomNavigationBarState();
}

class CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 428,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/bnbbg@4x.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.1),
            BlendMode.darken,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildIconWithLabel(0, 'assets/home@3x.png', 'Home'),
            buildIconWithLabel(1, 'assets/course@3x.png', 'Courses'),
            buildIconWithLabel(2, 'assets/menu@3x.png', 'Menu'),
          ],
        ),
      ),
    );
  }

  Widget buildIconWithLabel(int index, String iconPath, String title) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 27,
            height: 29,
            child: isSelected
                ? ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [
                          Color(0xFFC22054),
                          Color(0xFF48116A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color.fromARGB(255, 255, 255, 255),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        iconPath,
                        width: 27,
                        height: 29,
                      ),
                    ),
                  )
                : ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.grey.shade700,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      iconPath,
                      width: 27,
                      height: 29,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color:
                  isSelected ? const Color(0xFF48116A) : Colors.grey.shade700,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
