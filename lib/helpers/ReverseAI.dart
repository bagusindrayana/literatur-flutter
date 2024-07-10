import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert' show utf8;

class ReverseAI {
  static Future<void> translateLlama(
      String text, Function successCallback, Function errorCallback) async {
    print("translate with Llama");
    try {
      var value = await blackboxAI(text);
      successCallback(value);
    } catch (e) {
      print(e);
      errorCallback(e);
    }
  }

  static Future<void> translateGpt3(
      String text, Function successCallback, Function errorCallback) async {
    print("translate with GPT-3.5");
    try {
      var value = await duckcukgoGpt3(text);
      successCallback(value);
    } catch (e) {
      print(e);
      errorCallback(e);
    }
  }

  static Future<String> blackboxAI(String text) async {
    var headers = {
      'authority': 'www.blackbox.ai',
      'accept': '*/*',
      'accept-language': 'en-GB,en;q=0.9,en-US;q=0.8,id;q=0.7',
      'content-type': 'application/json',
      'origin': 'https://www.blackbox.ai',
      'referer': 'https://www.blackbox.ai/',
      'sec-ch-ua':
          '"Not A(Brand";v="99", "Microsoft Edge";v="121", "Chromium";v="121"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0'
    };

    var request =
        http.Request('POST', Uri.parse('https://www.blackbox.ai/api/chat'));

    //generate 7 random string and number
    var id = randomString(7);
    //generate uuid
    var uuid = Uuid();
    var userId = uuid.v4();

    request.body = json.encode({
      "messages": [
        {"id": id, "content": text, "role": "user"}
      ],
      "id": id,
      "previewToken": null,
      "userId": userId,
      "codeModelMode": true,
      "agentMode": {},
      "trendingAgentMode": {},
      "isMicMode": false,
      "isChromeExt": false,
      "githubToken": null,
      "clickedAnswer2": false,
      "clickedAnswer3": false,
      "clickedForceWebSearch": false,
      "visitFromDelta": null
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var value = await response.stream.bytesToString();
    //remove $@$v=undefined-rv1$@$
    var arr = value.split(r"$@$");
    if (arr.length > 2) {
      value = arr[2];
    }
    return value;
  }

  static String randomString(int length) {
    var random = new Random();
    var codeUnits = new List.generate(
        length, (index) => random.nextInt(33) + 89); //from 89 to 122
    return new String.fromCharCodes(codeUnits);
  }

  static Future<String> hailist(String text) async {
    var headers = {
      'authority': 'halist.ai',
      'accept': '*/*',
      'accept-language': 'id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7',
      'authorization':
          'Bearer 8c0ab00da064293abcb4cc2e3ae151518f023ad33947a14f3deadd264ae2c01c',
      'content-type': 'application/json',
      'origin': 'https://halist.ai',
      'referer': 'https://halist.ai/app/',
      'sec-ch-ua':
          '"Not.A/Brand";v="8", "Chromium";v="114", "Google Chrome";v="114"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36'
    };
    var request =
        http.Request('POST', Uri.parse('https://halist.ai/api/v1/chat'));
    request.body = json.encode({
      "query": text,
      "context": [],
      "title": "Untitled",
      "model": "gpt-3.5-turbo"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var value = await response.stream.bytesToString();
    return value;
  }

  static Future<String> duckcukgoGpt3(String text) async {
    var headers = {
      'authority': 'duckduckgo.com',
      'accept': 'text/event-stream',
      'accept-language': 'en-GB,en;q=0.9,en-US;q=0.8,id;q=0.7',
      'content-type': 'application/json',
      'cookie': 'dcm=3',
      'origin': 'https://duckduckgo.com',
      'referer': 'https://duckduckgo.com/',
      'sec-ch-ua':
          '"Not A(Brand";v="99", "Microsoft Edge";v="121", "Chromium";v="121"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0',
      'x-vqd-4': '4-70090821786758274966646578462431991250'
    };
    var request = http.Request(
        'POST', Uri.parse('https://duckduckgo.com/duckchat/v1/chat'));
    request.body = json.encode({
      "model": "gpt-3.5-turbo-0125",
      "messages": [
        {"role": "user", "content": text}
      ]
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(response.statusCode);
    var value = "";
    await for (var chunk in response.stream.transform(utf8.decoder)) {
      // Process each chunk as it is received
      var _chunk_clean = chunk.replaceAll("data:", "");
      var lineChunk = _chunk_clean.split("\n");
      lineChunk.removeWhere((element) => element.trim().isEmpty);
      lineChunk.forEach((element) {
        if (element.trim().isNotEmpty && element.trim() != "[DONE]") {
          var jsonValue = json.decode(element);
          if (jsonValue["message"] != null) {
            value += jsonValue["message"];
          }
        }
      });
    }

    if (value.trim().isEmpty) {
      throw Exception("Empty response");
    }

    return value;
  }
}
