/// W3Schools-style Courses Screen
/// Redirects to new Course Catalog with 25 programming languages
library;

import 'package:flutter/material.dart';
import '../courses/screens/course_catalog_screen.dart';

class W3CoursesScreen extends StatelessWidget {
  const W3CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CourseCatalogScreen();
  }
}
