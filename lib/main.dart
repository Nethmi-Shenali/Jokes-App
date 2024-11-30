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
      debugShowCheckedModeBanner: false,
      title: 'Joke Master',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          primary: const Color(0xFF1976D2),
          secondary: const Color(0xFF64B5F6),
          background: Colors.white,
        ),
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme.copyWith(
          bodyMedium: const TextStyle(fontSize: 14, color: Colors.white),
          bodySmall: const TextStyle(fontSize: 12, color: Colors.white70),
          titleMedium: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
        cardTheme: CardTheme(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black38,
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

  final List<String> _categories = ['random', 'Computer', 'general'];
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
        iconData = Icons.computer_rounded;
        break;
      case 'general':
        iconData = Icons.emoji_emotions_rounded;
        break;
      default:
        iconData = Icons.shuffle_rounded;
    }
    return Icon(iconData, size: 22, color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1976D2),
              const Color(0xFF42A5F5),
              const Color(0xFF1565C0),
            ],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 250,
              floating: false,
              pinned: true,
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'Joke Master',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                background: Center(
                  child: Icon(
                    Icons.sentiment_very_satisfied_rounded,
                    size: 120,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassDropdown<String>(
                            value: _selectedCategory,
                            hint: 'Category',
                            items: _categories,
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              }
                            },
                            itemBuilder: (category) => Row(
                              children: [
                                _buildCategoryIcon(category),
                                const SizedBox(width: 8),
                                Text(
                                  category.toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGlassDropdown<int>(
                            value: _selectedCount,
                            hint: 'Count',
                            items: _countOptions,
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCount = newValue;
                                });
                              }
                            },
                            itemBuilder: (count) => Text(
                              '$count jokes',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchJokes,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      label: const Text(
                        'Load Jokes',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.white.withOpacity(0.5)),
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white.withOpacity(0.3),
        foregroundColor: Colors.white,
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: const Icon(Icons.arrow_upward_rounded),
      ),
    );
  }

  Widget _buildGlassDropdown<T>({
    required T value,
    required String hint,
    required List<T> items,
    required void Function(T?) onChanged,
    required Widget Function(T) itemBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: DropdownButton<T>(
        value: value,
        dropdownColor: const Color(0xFF2196F3).withOpacity(0.8),
        isExpanded: true,
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            hint,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        underline: const SizedBox(),
        icon: const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
        ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: itemBuilder(item),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildJokesList() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
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
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchJokes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh_rounded),
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
          child: Text(
            'No jokes available',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: JokeCard(
                joke: _jokes[index],
                onToggle: () => _toggleJoke(index),
              ),
            ),
          );
        },
        childCount: _jokes.length,
      ),
    );
  }
}