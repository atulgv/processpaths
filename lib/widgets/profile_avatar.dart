import 'package:flutter/material.dart';

Widget buildProfileAvatar(
  String? photoUrl, {
  double radius = 20,
  double textSize = 20,
}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.blue,
    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
        ? NetworkImage(photoUrl) // ✅ Show profile picture
        : null,
    child: photoUrl == null || photoUrl.isEmpty
        ? Icon(Icons.person, color: Colors.white, size: textSize)
        : null,
  );
}
