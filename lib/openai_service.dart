// import 'dart:convert';

// import 'package:child_tinywiz/secrets.dart';
// import 'package:http/http.dart' as http;

// class OpenAIService {
//   final List<Map<String, String>> messages = [];

//   Future<String> isArtPromptAPI(String prompt) async {
//     print('🎨 [isArtPromptAPI] Starting API call with prompt: "$prompt"');
//     try {
//       final requestBody = {
//         "model": "gpt-3.5-turbo",
//         "messages": [
//           {
//             'role': 'user',
//             'content':
//                 'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.',
//           },
//         ],
//       };

//       print('📤 [isArtPromptAPI] Sending request to OpenAI...');
//       print('📤 [isArtPromptAPI] Request body: ${jsonEncode(requestBody)}');

//       final res = await http.post(
//         Uri.parse('https://api.openai.com/v1/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $openAIAPIKey',
//         },
//         body: jsonEncode(requestBody),
//       );

//       print('📥 [isArtPromptAPI] Response status code: ${res.statusCode}');
//       print('📥 [isArtPromptAPI] Response body: ${res.body}');

//       if (res.statusCode == 200) {
//         final responseData = jsonDecode(res.body);
//         String content = responseData['choices'][0]['message']['content'];
//         content = content.trim();

//         print('✅ [isArtPromptAPI] Response content: "$content"');

//         switch (content) {
//           case 'Yes':
//           case 'yes':
//           case 'Yes.':
//           case 'yes.':
//             print(
//               '🖼️ [isArtPromptAPI] Detected image request, calling Dall-E API...',
//             );
//             final res = await dallEAPI(prompt);
//             return res;
//           default:
//             print(
//               '💬 [isArtPromptAPI] Detected text request, calling ChatGPT API...',
//             );
//             final res = await chatGPTAPI(prompt);
//             return res;
//         }
//       } else {
//         print(
//           '❌ [isArtPromptAPI] API call failed with status ${res.statusCode}',
//         );
//         print('❌ [isArtPromptAPI] Error response: ${res.body}');
//         return 'API Error: Status ${res.statusCode} - ${res.body}';
//       }
//     } catch (e, stackTrace) {
//       print('❌ [isArtPromptAPI] Exception occurred: $e');
//       print('❌ [isArtPromptAPI] Stack trace: $stackTrace');
//       return 'Error: $e';
//     }
//   }

//   Future<String> chatGPTAPI(String prompt) async {
//     print('💬 [chatGPTAPI] Starting ChatGPT API call with prompt: "$prompt"');
//     messages.add({'role': 'user', 'content': prompt});
//     try {
//       final requestBody = {"model": "gpt-3.5-turbo", "messages": messages};

//       print('📤 [chatGPTAPI] Sending request to OpenAI...');
//       print('📤 [chatGPTAPI] Request body: ${jsonEncode(requestBody)}');

//       final res = await http.post(
//         Uri.parse('https://api.openai.com/v1/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $openAIAPIKey',
//         },
//         body: jsonEncode(requestBody),
//       );

//       print('📥 [chatGPTAPI] Response status code: ${res.statusCode}');
//       print('📥 [chatGPTAPI] Response body: ${res.body}');

//       if (res.statusCode == 200) {
//         final responseData = jsonDecode(res.body);
//         String content = responseData['choices'][0]['message']['content'];
//         content = content.trim();

//         print('✅ [chatGPTAPI] Success! Response content: "$content"');

//         messages.add({'role': 'assistant', 'content': content});
//         return content;
//       } else {
//         print('❌ [chatGPTAPI] API call failed with status ${res.statusCode}');
//         print('❌ [chatGPTAPI] Error response: ${res.body}');
//         return 'API Error: Status ${res.statusCode} - ${res.body}';
//       }
//     } catch (e, stackTrace) {
//       print('❌ [chatGPTAPI] Exception occurred: $e');
//       print('❌ [chatGPTAPI] Stack trace: $stackTrace');
//       return 'Error: $e';
//     }
//   }

//   Future<String> dallEAPI(String prompt) async {
//     print('🖼️ [dallEAPI] Starting Dall-E API call with prompt: "$prompt"');
//     messages.add({'role': 'user', 'content': prompt});
//     try {
//       final requestBody = {'prompt': prompt, 'n': 1};

//       print('📤 [dallEAPI] Sending request to OpenAI...');
//       print('📤 [dallEAPI] Request body: ${jsonEncode(requestBody)}');

//       final res = await http.post(
//         Uri.parse('https://api.openai.com/v1/images/generations'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $openAIAPIKey',
//         },
//         body: jsonEncode(requestBody),
//       );

//       print('📥 [dallEAPI] Response status code: ${res.statusCode}');
//       print('📥 [dallEAPI] Response body: ${res.body}');

//       if (res.statusCode == 200) {
//         final responseData = jsonDecode(res.body);
//         String imageUrl = responseData['data'][0]['url'];
//         imageUrl = imageUrl.trim();

//         print('✅ [dallEAPI] Success! Image URL: $imageUrl');

//         messages.add({'role': 'assistant', 'content': imageUrl});
//         return imageUrl;
//       } else {
//         print('❌ [dallEAPI] API call failed with status ${res.statusCode}');
//         print('❌ [dallEAPI] Error response: ${res.body}');
//         return 'API Error: Status ${res.statusCode} - ${res.body}';
//       }
//     } catch (e, stackTrace) {
//       print('❌ [dallEAPI] Exception occurred: $e');
//       print('❌ [dallEAPI] Stack trace: $stackTrace');
//       return 'Error: $e';
//     }
//   }
// }
