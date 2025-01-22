import 'package:flutter/material.dart';

class FilterSwitch extends StatefulWidget {
  final String option1;
  final String option2;
  final String option3;
  final ValueChanged<int> onChanged;
  final int initialSelectedIndex;

  const FilterSwitch({
    required this.option1,
    required this.option2,
    required this.option3,
    required this.onChanged,
    this.initialSelectedIndex = 0,
    super.key,
  });

  @override
  FilterSwitchState createState() => FilterSwitchState();
}

class FilterSwitchState extends State<FilterSwitch> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onOptionTap(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      widget.onChanged(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return Center(
      child: Container(
        width: isWeb ? 450 : 350,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              left: isWeb
                  ? _selectedIndex == 0
                      ? 4
                      : _selectedIndex == 1
                          ? (450 / 3) + 4
                          : (2 * (450 / 3)) + 4
                  : _selectedIndex == 0
                      ? 4
                      : _selectedIndex == 1
                          ? (350 / 3) + 4
                          : (2 * (350 / 3)) + 4,
              top: 4,
              child: Container(
                width: (isWeb ? 450 / 3 : 350 / 3) - 8,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 119, 0, 255),
                  gradient: const LinearGradient(colors: [
                    Color(0xFFC22054),
                    Color(0xFF48116A),
                  ]),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onOptionTap(0),
                    child: Center(
                      child: Text(
                        widget.option1,
                        style: TextStyle(
                          color:
                              _selectedIndex == 0 ? Colors.white : Colors.black,
                          fontWeight: _selectedIndex == 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: isWeb ? 18 : 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onOptionTap(1),
                    child: Center(
                      child: Text(
                        widget.option2,
                        style: TextStyle(
                          color:
                              _selectedIndex == 1 ? Colors.white : Colors.black,
                          fontWeight: _selectedIndex == 1
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: isWeb ? 18 : 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onOptionTap(2),
                    child: Center(
                      child: Text(
                        widget.option3,
                        style: TextStyle(
                          color:
                              _selectedIndex == 2 ? Colors.white : Colors.black,
                          fontWeight: _selectedIndex == 2
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: isWeb ? 18 : 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
