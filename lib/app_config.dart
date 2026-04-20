/// ─────────────────────────────────────────────────────────────────────────────
/// AquaSafe — API Keys & Configuration
/// ─────────────────────────────────────────────────────────────────────────────

class AppConfig {
  // ── ML Model API ──────────────────────────────────────────────────────────
  /// Live Flask model hosted on Render
  static const String mlApiUrl =
      'https://water-ml-model.onrender.com/predict';

  // ── Gemini API ────────────────────────────────────────────────────────────
  /// Get one at: https://aistudio.google.com/app/apikey
  static const String geminiApiKey = 'AIzaSyDrr4H2Lkzk0YO7dD6UUaumeGcjxH-X9io';
}
