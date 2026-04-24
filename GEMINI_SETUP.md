# Gemini API Setup Guide

This app now uses Google Gemini API (free tier) instead of OpenAI.

## How to Get Your Free Gemini API Key

1. **Visit Google AI Studio:**
   - Go to https://aistudio.google.com/app/apikey
   - Or visit https://makersuite.google.com/app/apikey

2. **Sign in with your Google account**

3. **Create API Key:**
   - Click "Create API Key" or "Get API Key"
   - Copy your API key

4. **Add API Key to the App:**
   - Open `lib/secrets.dart`
   - Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key:
   ```dart
   const geminiAPIKey = 'your-actual-api-key-here';
   ```

## Free Tier Limits

- **60 requests per minute** (free tier)
- **1,500 requests per day** (free tier)
- No credit card required for free tier

## Features

✅ **Text Chat** - Full conversation support with Gemini Pro
⚠️ **Image Generation** - Not available with Gemini (returns helpful text instead)

## Notes

- The API key is stored in `lib/secrets.dart` - make sure not to commit this file to public repositories
- Gemini Pro is used for all text-based conversations
- Conversation history is maintained for context-aware responses

