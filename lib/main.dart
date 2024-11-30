// lib/main.dart
import 'package:flutter/material.dart';
import 'models/joke_model.dart';
import 'services/joke_service.dart';
import 'widgets/joke_card.dart';

void main() {
  runApp(const JokesApp());
}

class JokesApp extends StatelessWidget {
  const JokesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Jokes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4EFF),
          secondary: const Color(0xFFFF4E8C),
        ),
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme,
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const JokesHomePage(),
    );
  }
}

class JokesHomePage extends StatefulWidget {
  const JokesHomePage({super.key});

  @override
  State<JokesHomePage> createState() => _JokesHomePageState();
}

class _JokesHomePageState extends State<JokesHomePage>
    with SingleTickerProviderStateMixin {
  final JokeService _jokeService = JokeService();
  List<Joke> _jokes = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'random';
  int _selectedCount = 5;
  late AnimationController _animationController;
  late ScrollController _scrollController;

  final List<String> _categories = ['random', 'programming', 'general'];
  final List<int> _countOptions = [5, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scrollController = ScrollController();
    _fetchJokes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchJokes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Joke> jokes;
      if (_selectedCategory == 'random') {
        jokes = await _jokeService.getRandomJokes(_selectedCount);
      } else {
        jokes = await _jokeService.getJokesByType(
            _selectedCategory, _selectedCount);
      }
      setState(() {
        _jokes = jokes;
        _isLoading = false;
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleJoke(int index) {
    setState(() {
      _jokes[index].isExpanded = !_jokes[index].isExpanded;
    });
  }

  Widget _buildCategoryIcon(String category) {
    IconData iconData;
    switch (category) {
      case 'programming':
        iconData = Icons.computer;
        break;
      case 'general':
        iconData = Icons.public;
        break;
      default:
        iconData = Icons.shuffle;
    }
    return Icon(iconData, size: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Joke Master'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.sentiment_very_satisfied,
                    size: 80,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: _buildCategoryIcon(_selectedCategory),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  _buildCategoryIcon(category),
                                  const SizedBox(width: 6),
                                  Text(category.toUpperCase()),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedCount,
                          decoration: InputDecoration(
                            labelText: 'Count',
                            prefixIcon: const Icon(Icons.format_list_numbered),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: _countOptions.map((count) {
                            return DropdownMenuItem(
                              value: count,
                              child: Text('$count jokes'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCount = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchJokes,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Load Jokes'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildJokesList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  Widget _buildJokesList() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchJokes,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_jokes.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text('No jokes available'),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  index / _jokes.length,
                  (index + 1) / _jokes.length,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: JokeCard(
              joke: _jokes[index],
              onToggle: () => _toggleJoke(index),
            ),
          );
        },
        childCount: _jokes.length,
      ),
    );
  }
}
