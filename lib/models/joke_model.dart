class Joke {
  final String setup;
  final String punchline;
  final String type;
  bool isExpanded;

  Joke({
    required this.setup,
    required this.punchline,
    required this.type,
    this.isExpanded = false,
  });

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      setup: json['setup'] ?? '',
      punchline: json['punchline'] ?? '',
      type: json['type'] ?? 'general',
    );
  }
}
