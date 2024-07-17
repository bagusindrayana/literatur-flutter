import 'dart:convert';

import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Translatehelper {
  static List<String> providers = ["Google", "DeepL", "Gemini", "Llama"];
  static List<String> languages = [
    "Indonesian",
    "Japanese",
    "Chinese",
    "Korean",
    "English",
  ];

  static String countryId(String name) {
    if (name == "Indonesian") {
      return "id";
    }
    if (name == "Japanese") {
      return "ja";
    }
    if (name == "Chinese") {
      return "cn";
    }
    if (name == "Korean") {
      return "kr";
    }
    return "en";
  }

  static String promptBuilder(
      String from, String to, String prePrompt, String text) {
    // print("From : ${from} To : ${to}");
    if (to == "Indonesian") {
      return "Terjemahkan teks ${from} berikut ke bahasa ${to} \n\n Teksnya adalah : \n`${text}`. \n\n, untuk informasi dan instruktsi tambahan terjemahan : \n ${prePrompt}.\n tolong hanya berikan response dan jawab hasil terjemahan saja dan jangan berikan response lainnya.";
    } else {
      return "Translate the following ${from} texts  to ${to} language : \n\n The texts is : \n`${text}`. \n\n, for aditional information or instruction translation : \n ${prePrompt}.\n please only response or answer with translation result only and never give any response else.";
    }
  }

  static Future<void> translateGemini(
      String text, Function successCallback, Function errorCallback) async {
    final gemini = Gemini.instance;
    print('translate gemini');
    try {
      Candidates? value = await gemini.text(text);
      if (value != null &&
          value.content != null &&
          value.content!.parts != null &&
          value.content!.parts!.isNotEmpty) {
        successCallback(value.content!.parts!.lastOrNull?.text);
      } else {
        if (value != null) {
          throw Exception("Cant translate this text : ${value!.toJson()}");
        } else {
          throw Exception("Cant translate this text : Uknown");
        }
      }
    } catch (e) {
      print(e);
      errorCallback(e);
    }
  }

  static Future<void> translateGoogle(String text, String from, String to,
      String wordlist, Function successCallback, Function errorCallback) async {
    print('translate google');
    List<String> words = wordlist.split(",");
    for (var word in words) {
      var arr = word.split("=");
      if (arr.length > 1 &&
          arr[0].trim().isNotEmpty &&
          arr[1].trim().isNotEmpty) {
        text = text.replaceAll(arr[0].trim(), ' "${arr[1].trim()}" ');
      }
    }

    String f = countryId(from);
    String t = countryId(to);

    String googleKey = String.fromEnvironment('GOOGLE_TRANSLATE_API_KEY',
        defaultValue: dotenv.env['GOOGLE_TRANSLATE_API_KEY'] ?? "");
    var url =
        "https://translation.googleapis.com/language/translate/v2?key=$googleKey";
    var body = {"q": text, "target": f, "source": f};
    var headers = {"Content-Type": "application/json"};
    try {
      http.Response response = await http.post(Uri.parse(url),
          body: jsonEncode(body), headers: headers);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        successCallback(data["data"]["translations"][0]["translatedText"]);
      } else {
        errorCallback("Failed to translate text");
      }
    } catch (e) {
      errorCallback(e);
    }
  }

  static Future<void> translateDeepL(String text, String from, String to,
      String wordlist, Function successCallback, Function errorCallback) async {
    print('translate DeepL');
    List<String> words = wordlist.split(",");
    for (var word in words) {
      var arr = word.split("=");
      if (arr.length > 1 &&
          arr[0].trim().isNotEmpty &&
          arr[1].trim().isNotEmpty) {
        text = text.replaceAll(arr[0].trim(), ' "${arr[1].trim()}" ');
      }
    }

    String f = countryId(from);
    String t = countryId(to);
    var deepLKey = String.fromEnvironment('DEEPL_API_KEY',
        defaultValue: dotenv.env['DEEPL_API_KEY'] ?? "");
    var url = "https://api-free.deepl.com/v2/translate";
    var body = {
      "text": text,
      "target_lang": t,
      "source_lang": f,
    };

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "DeepL-Auth-Key $deepLKey"
    };

    try {
      http.Response response = await http.post(Uri.parse(url),
          body: jsonEncode(body), headers: headers);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        successCallback(data["translations"][0]["text"]);
      } else {
        errorCallback("Failed to translate text");
      }
    } catch (e) {
      errorCallback(e);
    }
  }

  static Future<void> translateLlama(
      String text, Function successCallback, Function errorCallback) async {
    print("translate with Llama");
    var groqApiKey = String.fromEnvironment('GROQ_API_KEY',
        defaultValue: dotenv.env['GROQ_API_KEY'] ?? "");
    var url = "https://api.groq.com/openai/v1/chat/completions";
    var body = {
      "messages": [
        {"role": "user", "content": text}
      ],
      "model": "llama3-70b-8192"
    };
    var header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $groqApiKey"
    };
    try {
      http.Response response = await http.post(Uri.parse(url),
          body: jsonEncode(body), headers: header);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["choices"] != null && data["choices"].length > 0) {
          successCallback(data["choices"][0]["message"]["content"]);
        } else {
          errorCallback("Failed to translate text");
        }
      } else {
        errorCallback("Failed to translate text");
      }
    } catch (e) {
      print(e);
      errorCallback(e);
    }
  }

  static Future<void> translate(
      String provider,
      String text,
      String from,
      String to,
      String prePrompt,
      Function successCallback,
      Function errorCallback) async {
    if (provider == "Google") {
      await translateGoogle(
          text, from, to, prePrompt, successCallback, errorCallback);
    } else if (provider == "Gemini") {
      var prompt = promptBuilder(from, to, prePrompt, text);
      await translateGemini(prompt, successCallback, errorCallback);
    } else if (provider == "DeepL") {
      await translateDeepL(
          text, from, to, prePrompt, successCallback, errorCallback);
    } else if (provider == "Llama") {
      var prompt = promptBuilder(from, to, prePrompt, text);
      await translateLlama(prompt, successCallback, errorCallback);
    } else {
      errorCallback("Provider not found");
    }
  }
}
