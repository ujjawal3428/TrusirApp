import 'package:flutter/material.dart';

class ProfilePopup extends StatelessWidget {
  const ProfilePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54, 
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26), 
          child: Container(
            decoration:const BoxDecoration(
              color: Colors.white,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main Profile Container
                      Container(
                        padding: const EdgeInsets.only(top: 4), // Leave space for the close button
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 35,
                              backgroundImage: AssetImage('assets/rakesh@3x.png'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  
                                  const Text(
                                    'Your Name',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'youremail@example.com',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 25,
                                    width: 80,
                                    child: ElevatedButton(
                                      
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        
                                        backgroundColor: Colors.purple,
                                        shape: RoundedRectangleBorder(
                                        
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'View',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Scrollable Profiles List
                      const SizedBox(height: 8),
                      Container(
                        height: 215, // Adjust height as needed
                        color: Colors.grey[100],
                        child: ListView.builder(
                          itemCount: 3, // Number of profiles
                          itemBuilder: (context, index) {
                            return Column(
  children: [
    ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0), // Removes horizontal padding
      leading: const CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage('assets/profile_picture.png'),
      ),
      title: Text(
        'Profile Name $index',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        'profile$index@example.com',
        style: const TextStyle(fontSize: 13), // Adjust font size if needed
      ),
    ),
    Divider(
      color: Colors.grey[300],
      thickness: 1,
      height: 1, // Controls the space above and below the divider
    ),
  ],
);
                          },
                        ),
                      ),
                      // Sign Out Button
                      const SizedBox(height: 8),
                     Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    Container(
      width: 80,
      height: 26,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero, 
          minimumSize: Size.zero,  
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, 
        ),
        onPressed: () {
          Navigator.pop(context); // Close the popup
        },
        child: const Center( // Center the text within the button
          child: Text(
            'Sign Out',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 12,
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
                // Close Button (Top-Right)
                Positioned(
                  top: 2,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context); // Close the popup
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
