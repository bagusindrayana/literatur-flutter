# Literatur

Read Epub and translate using AI.

### Development
- clone this repo
- install requirements with `flutter pub get`
- run the app with `flutter run --dart-define=GEMINI_API_KEY=YOUR_API_KEY,GOOGLE_TRANSLATE_API_KEY=YOUR_API_KEY,GROQ_API_KEY=YOUR_API_KEY,DEEPL_API_KEY=YOUR_API_KEY` 
- or make `.env` file with the keys and run `flutter run --dart-define-from-file=.env`

### Add more translate API
- edit `helpers/TranslateHelper.dart` and add your own function to call the API

### Add more language selection
- edit `helpers/TranslateHelper.dart` and add your own language code in variable `languages`, also change function `countryId` to return the language code