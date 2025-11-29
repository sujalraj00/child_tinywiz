class UserProgress {
  final int collectedStars;
  final int totalStars;
  final DateTime lastUpdated;

  UserProgress({
    required this.collectedStars,
    required this.totalStars,
    required this.lastUpdated,
  });

  UserProgress copyWith({
    int? collectedStars,
    int? totalStars,
    DateTime? lastUpdated,
  }) {
    return UserProgress(
      collectedStars: collectedStars ?? this.collectedStars,
      totalStars: totalStars ?? this.totalStars,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get isComplete => collectedStars >= totalStars;
  double get progressPercentage => collectedStars / totalStars;
}

