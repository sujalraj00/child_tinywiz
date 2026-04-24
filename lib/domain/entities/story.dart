import 'package:flutter/material.dart';
import 'quiz.dart';

class Story {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String audioFile;
  final int colorValue;
  final Quiz? quiz;

  Story({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.audioFile,
    required this.colorValue,
    this.quiz,
  });

  Color get color => Color(colorValue);
}

