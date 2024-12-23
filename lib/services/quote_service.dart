// lib/services/quote_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class Quote {
  final String content;
  final String author;
  final List<String> tags;

  Quote({
    required this.content,
    required this.author,
    this.tags = const [],
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    print('Quote.fromJson: Processing JSON: $json');
    return Quote(
      content: json['content'] ?? json['q'] ?? '', // Support multiple API formats
      author: json['author'] ?? json['a'] ?? 'Unknown',
      tags: const ['inspiration'], // Default tag since API doesn't provide tags
    );
  }
}

class QuoteService {
  // Using ZenQuotes API which is more reliable for desktop apps
  static const String _baseUrl = 'https://zenquotes.io/api/random';
  
  static Future<Quote> getRandomQuote() async {
    print('QuoteService: Starting quote fetch from ZenQuotes API');
    
    try {
      print('QuoteService: Sending request to $_baseUrl');
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'ZenFlow/1.0', // Adding a user agent can help with API stability
        },
      );
      
      print('QuoteService: Response status code: ${response.statusCode}');
      print('QuoteService: Response headers: ${response.headers}');
      print('QuoteService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        if (jsonData.isNotEmpty) {
          return Quote.fromJson(jsonData.first);
        }
      }
      
      throw Exception('Failed to load quote: ${response.statusCode}');
    } catch (e, stackTrace) {
      print('QuoteService: Error occurred while fetching quote:');
      print('Error: $e');
      print('Stack trace:\n$stackTrace');
      rethrow;
    }
  }

  static Future<Quote> getQuoteByTags(List<String> tags) async {
    // ZenQuotes free API doesn't support tags, so we'll just get a random quote
    return getRandomQuote();
  }
}