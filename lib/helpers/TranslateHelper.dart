import 'dart:convert';

import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:translator/translator.dart';
import 'package:simplytranslate/simplytranslate.dart';
import 'package:http/http.dart';

class Translatehelper {
  static List<String> providers = [
    "Google",
    "Yandex",
    "DeepL",
    "Gemini",
    "Libre"
  ];
  static List<String> languages = [
    "Indonesian",
    "Japanese",
    "Chinese",
    "Korean",
    "English",
  ];
  static String promptBuilder(
      String from, String to, String prePrompt, String text) {
    // print("From : ${from} To : ${to}");
    if (to == "Indonesian") {
      return "Terjemahkan teks ${from} berikut ke bahasa ${to} \n\n Teksnya adalah : \n```${text}``` \n\n, untuk informasi dan instruktsi tambahan : \n ${prePrompt}.\n (Jangan terjemahkan keterangan informasi dan instruksi tambahan, hanya terjemahkan teks yang ada dalam simbol ```) dan tolong hanya berikan response dan jawab hasil terjemahan saja.";
    } else {
      return "Translate the following ${from} texts  to ${to} language : \n\n The texts is : \n```${text}``` \n\n, for aditional information or instruction : \n ${prePrompt}.\n (Dont Translate information or instruction, only translate text inside ```) and please only response or answer with translation result only.";
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
        print(value);
        throw Exception("No translation found");
      }
    } catch (e) {
      errorCallback(e);
    }
  }

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
    try {
      final st = SimplyTranslator(EngineType.google);
      st.setSimplyInstance = "mozhi.pussthecat.org";
      String value = await st.trSimply(text, f, t);
      successCallback(value);
    } catch (e) {
      print(e);
      try {
        final translator = GoogleTranslator();
        final value = await translator.translate(text, from: f, to: t);
        successCallback(value.text);
      } catch (e) {
        print(e);
        errorCallback(e);
      }
    }
  }

  static Future<void> translateLibre(String text, String from, String to,
      String wordlist, Function successCallback, Function errorCallback) async {
    print('translate Libre');
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
    try {
      final st = SimplyTranslator(EngineType.libre);
      String value = await st.trSimply(text, f, t);
      successCallback(value);
    } catch (e) {
      errorCallback(e);
    }
  }

  static Future<String> requestMozhi(
      String engine, String from, String to, String text) async {
    //https://mozhi.pussthecat.org/api/translate?engine=yandex&from=en&to=ja&text=how%20are%20you%3F
    String url =
        "https://mozhi.pussthecat.org/api/translate?engine=${engine}&from=${from}&to=${to}&text=${text.trim()}";
    print(url);
    //request http, response json and return translated-text
    String value = get(Uri.parse(url)).then((response) {
      return jsonDecode(response.body)["translated-text"];
    }) as String;
    return value;
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
    try {
      String value = await requestMozhi("deepl", f, t, text);
      successCallback(value);
    } catch (e) {
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
    } else if (provider == "Libre") {
      await translateLibre(
          text, from, to, prePrompt, successCallback, errorCallback);
    } else if (provider == "DeepL") {
      await translateDeepL(
          text, from, to, prePrompt, successCallback, errorCallback);
    } else {
      errorCallback("Provider not found");
    }
  }
}
