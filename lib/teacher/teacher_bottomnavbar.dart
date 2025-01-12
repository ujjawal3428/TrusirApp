import 'package:flutter/material.dart';

class TeacherBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onTap;

  const TeacherBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/bnbbg@4x.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.grey[200]!,
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
            buildIconWithLabel(0, Icons.home_rounded, 'Home'),
            buildIconWithLabel(1, Icons.book_rounded, 'Courses'),
            buildIconWithLabel(2, Icons.menu_rounded, 'Menu'),
          ],
        ),
      ),
    );
  }

  Widget buildIconWithLabel(int index, IconData iconData, String title) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
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
                    child: Icon(
                      iconData,
                      size: 27,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    iconData,
                    size: 27,
                    color: Colors.grey.shade700,
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
