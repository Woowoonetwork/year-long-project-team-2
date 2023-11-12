// create_post.dart
// a page that allows users to create a new post
import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

// class _CreatePostPageState extends State<CreatePostScreen> {
//   TextEditingController titleController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
    
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Title:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             TextField(
//               controller: titleController,
//               decoration: InputDecoration(
//                 hintText: 'Enter title...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _CreatePostPageState extends State<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 430,
      height: 1663,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
      child: Stack(
        children: [
          Positioned(
            left: 24,
            top: 293,
            child: Container(
              width: 379,
              height: 206,
              decoration: ShapeDecoration(
                color: Color(0xFFF8F8F8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 190,
            child: Container(
              width: 379,
              height: 56,
              decoration: ShapeDecoration(
                color: Color(0xFFF8F8F8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            left: 125,
            top: 633,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 69, vertical: 31),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Color(0xFFF8F8F8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'No Alt Text Entered',
                    style: TextStyle(
                      color: Color(0xFFA1A1A1),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 0,
                      letterSpacing: -0.32,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 265,
            child: Text(
              'Description',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 0,
                letterSpacing: -0.32,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 159,
            child: Text(
              'Title',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 0,
                letterSpacing: -0.32,
              ),
            ),
          ),
          Positioned(
            left: 128,
            top: 386,
            child: Text(
              'No Description Entered',
              style: TextStyle(
                color: Color(0xFFA1A1A1),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 0,
                letterSpacing: -0.32,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 36,
            child: Container(
              width: 24,
              height: 24,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Stack(
                children: [
                  // Add child widgets for this stack
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 605,
            child: Text(
              'Photo',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 0,
                letterSpacing: -0.32,
              ),
            ),
          ),
          Positioned(
            left: 125,
            top: 605,
            child: Text(
              'Alt Text',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 0,
                letterSpacing: -0.32,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 926,
            child: Text(
              'Expiration Date',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 0,
                letterSpacing: -0.32,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 1529,
            child: Text(
              'Pickup Time',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 0,
                letterSpacing: -0.32,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 1145,
            child: Text(
              'Pickup Location',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 0,
                letterSpacing: -0.32,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 633,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 40,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Stack(
                      children: [
                        // Add child widgets for this stack
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 1459,
            child: Container(
              width: 382,
              height: 43,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Color(0xFFF8F8F8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // Add child widgets for this container
            ),
          ),
        ],
      ),
    );
  }
}


