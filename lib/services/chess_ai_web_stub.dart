/// Stub file for Stockfish on web platform
/// This file is used when dart:ffi is not available (web platform)

// Stub class to prevent compilation errors on web
class Stockfish {
  Stockfish();

  Stream<String> get stdout => const Stream.empty();
  set stdin(String value) {}

  void dispose() {}
}
