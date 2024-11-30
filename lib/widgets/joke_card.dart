import 'package:flutter/material.dart';
import '../models/joke_model.dart';

class JokeCard extends StatelessWidget {
  final Joke joke;
  final VoidCallback onToggle;

  const JokeCard({
    super.key,
    required this.joke,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white, // Explicit white background
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white, // Consistent white background
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Joke Section (Setup)
                  Text(
                    joke.setup,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900], // Deep blue color for setup
                    ),
                  ),

                  // Punchline Section (Revealed on Tap)
                  if (joke.isExpanded) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50], // Light blue background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        joke.punchline,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              Colors.blue[900], // Deep blue color for punchline
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],

                  // Bottom Row with Category and Expand Icon
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(joke.type),
                              size: 16,
                              color: Colors.blue[900],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              joke.type.toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expand/Collapse Icon
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: joke.isExpanded ? 0.5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'programming':
        return Icons.computer;
      case 'general':
        return Icons.public;
      default:
        return Icons.emoji_emotions;
    }
  }
}
