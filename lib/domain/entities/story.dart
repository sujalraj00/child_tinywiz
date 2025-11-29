import 'package:flutter/material.dart';

class Story {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String audioFile;
  final int colorValue;

  Story({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.audioFile,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
}

