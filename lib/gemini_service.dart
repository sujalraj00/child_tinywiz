import 'dart:convert';

import 'package:child_tinywiz/secrets.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final List<Map<String, dynamic>> conversationHistory = [];
  bool isFirstMessage = true; // Track if this is the first message
  // Try gemini-1.5-flash first (free tier, faster), fallback to gemini-1.5-pro
  static const String modelName = 'gemini-2.5-flash-lite';
  static const String fallbackModelName = 'gemini-2.5-flash-lite';
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // Method to clear conversation history
  void clearHistory() {
    conversationHistory.clear();
    isFirstMessage = true;
    print('🔄 [GeminiService] Conversation history cleared');
  }

  // Child-friendly system instruction (only added once)
  static const String childFriendlySystemInstruction = '''
You are a friendly and helpful assistant talking to an 8-year-old child. 
- Use simple words and short sentences
- Explain things in a fun and easy way
- Use examples that children can relate to
- Be enthusiastic and encouraging
- Keep your answers clear and not too long (2-3 sentences is perfect)
- Avoid complex technical terms, or if you must use them, explain them simply
- Make learning fun and engaging!
''';

  // Helper method to make API call with model fallback
  Future<http.Response> _makeApiCall(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    // Try primary model with v1beta first
    var res = await http.post(
      Uri.parse('$baseUrl/$modelName:generateContent?key=$geminiAPIKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    // If 404, try fallback model with v1beta
    if (res.statusCode == 404) {
      print('⚠️ [$endpoint] Primary model not found, trying fallback model...');
      res = await http.post(
        Uri.parse(
          '$baseUrl/$fallbackModelName:generateContent?key=$geminiAPIKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    }

    // If still 404, try v1 API version with primary model
    if (res.statusCode == 404) {
      print('⚠️ [$endpoint] v1beta not working, trying v1 API...');
      const v1BaseUrl = 'https://generativelanguage.googleapis.com/v1/models';
      res = await http.post(
        Uri.parse('$v1BaseUrl/$modelName:generateContent?key=$geminiAPIKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    }

    return res;
  }

  Future<String> isArtPromptAPI(String prompt) async {
    print('🎨 [isArtPromptAPI] Starting API call with prompt: "$prompt"');
    try {
      final checkPrompt =
          'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.';

      print('📤 [isArtPromptAPI] Sending request to Gemini...');

      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": checkPrompt},
            ],
          },
        ],
      };

      final res = await _makeApiCall('isArtPromptAPI', requestBody);

      print('📥 [isArtPromptAPI] Response status code: ${res.statusCode}');
      print('📥 [isArtPromptAPI] Response body: ${res.body}');

      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        String content =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        content = content.trim().toLowerCase();

        print('✅ [isArtPromptAPI] Response content: "$content"');

        // Check if it's an image request
        if (content.contains('yes')) {
          print(
            '🖼️ [isArtPromptAPI] Detected image request, calling image generation handler...',
          );
          // For image requests, return a helpful message since Gemini doesn't support image generation
          final res = await dallEAPI(prompt);
          return res;
        } else {
          print(
            '💬 [isArtPromptAPI] Detected text request, calling Gemini API...',
          );
          final res = await chatGPTAPI(prompt);
          return res;
        }
      } else {
        print(
          '❌ [isArtPromptAPI] API call failed with status ${res.statusCode}',
        );
        print('❌ [isArtPromptAPI] Error response: ${res.body}');
        return 'API Error: Status ${res.statusCode} - ${res.body}';
      }
    } catch (e, stackTrace) {
      print('❌ [isArtPromptAPI] Exception occurred: $e');
      print('❌ [isArtPromptAPI] Stack trace: $stackTrace');
      return 'Error: $e';
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    print('💬 [chatGPTAPI] Starting Gemini API call with prompt: "$prompt"');

    // Prepare the user message with child-friendly context
    String userMessage;
    if (isFirstMessage) {
      // First message: include system instruction
      userMessage =
          '$childFriendlySystemInstruction\n\nNow, answer this question in a way an 8-year-old would understand: $prompt';
      isFirstMessage = false;
    } else {
      // Subsequent messages: just add the prompt with reminder
      userMessage =
          'Remember to answer like you\'re talking to an 8-year-old child. Keep it simple and fun!\n\n$prompt';
    }

    // Add user message to conversation history with proper role
    conversationHistory.add({
      "role": "user",
      "parts": [
        {"text": userMessage},
      ],
    });

    try {
      // Build conversation history for Gemini (alternating user/model messages)
      final requestBody = {"contents": conversationHistory};

      print('📤 [chatGPTAPI] Sending request to Gemini...');
      print('📤 [chatGPTAPI] Request body: ${jsonEncode(requestBody)}');

      final res = await _makeApiCall('chatGPTAPI', requestBody);

      print('📥 [chatGPTAPI] Response status code: ${res.statusCode}');
      print('📥 [chatGPTAPI] Response body: ${res.body}');

      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        String content =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        content = content.trim();

        print('✅ [chatGPTAPI] Success! Response content: "$content"');

        // Add model response to conversation history with proper role
        conversationHistory.add({
          "role": "model",
          "parts": [
            {"text": content},
          ],
        });

        return content;
      } else {
        print('❌ [chatGPTAPI] API call failed with status ${res.statusCode}');
        print('❌ [chatGPTAPI] Error response: ${res.body}');

        // Try to extract error message
        try {
          final errorData = jsonDecode(res.body);
          if (errorData['error'] != null) {
            return 'Error: ${errorData['error']['message'] ?? res.body}';
          }
        } catch (_) {}

        return 'API Error: Status ${res.statusCode} - ${res.body}';
      }
    } catch (e, stackTrace) {
      print('❌ [chatGPTAPI] Exception occurred: $e');
      print('❌ [chatGPTAPI] Stack trace: $stackTrace');
      return 'Error: $e';
    }
  }

  // Note: Gemini doesn't have a direct image generation API like Dall-E
  // For image generation, you would need to use a different service
  // For now, we'll return a message suggesting text-based alternatives
  Future<String> dallEAPI(String prompt) async {
    print('🖼️ [dallEAPI] Image generation requested: "$prompt"');
    print('⚠️ [dallEAPI] Gemini doesn\'t support image generation directly.');
    print(
      '💡 [dallEAPI] Returning a child-friendly text description instead...',
    );

    // Create child-friendly description prompt
    final descriptionPrompt =
        '''
You are talking to an 8-year-old child. They asked for an image of "$prompt". 
Since I can't show pictures, please describe what this would look like in a fun, 
simple way that a child would enjoy. Use colorful and exciting words! 
Keep it short (2-3 sentences) and make it sound fun and interesting.
''';

    try {
      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": descriptionPrompt},
            ],
          },
        ],
      };

      final res = await _makeApiCall('dallEAPI', requestBody);

      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        String content =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        content = content.trim();
        return content;
      } else {
        // Fallback message
        return 'I\'d love to show you a picture of "$prompt"! Even though I can\'t draw pictures right now, I can tell you all about it in a fun way. What would you like to know?';
      }
    } catch (e) {
      print('❌ [dallEAPI] Error: $e');
      return 'I\'d love to show you a picture of "$prompt"! Even though I can\'t draw pictures right now, I can tell you all about it in a fun way. What would you like to know?';
    }
  }
}
