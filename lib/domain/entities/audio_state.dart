class AudioState {
  final bool isPlaying;
  final bool isLoading;
  final bool isLoaded;
  final Duration duration;
  final Duration position;

  AudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.isLoaded = false,
    this.duration = Duration.zero,
    this.position = Duration.zero,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    bool? isLoaded,
    Duration? duration,
    Duration? position,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      duration: duration ?? this.duration,
      position: position ?? this.position,
    );
  }
}

