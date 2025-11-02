// screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:myanmar_dictionary_mobile/models/word_model.dart';
import 'package:myanmar_dictionary_mobile/screens/word_definition_screen.dart';
import 'package:myanmar_dictionary_mobile/services/database_helper.dart';
import 'package:myanmar_dictionary_mobile/widgets/word_cart_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<WordPreviewModel> _favorites = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;
  int? _total;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_loadingMore &&
          _hasMore) {
        _loadMoreFavorites();
      }
    });
  }

  Future<void> _loadFavorites() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _currentPage = 1;
        _hasMore = true;
      });

      final result = await DatabaseHelper.getFavoritesPaginated(
        page: _currentPage,
        limit: _limit,
      );

      setState(() {
        _favorites = result.items;
        _isLoading = false;
        _hasMore = result.hasMore;
        _total = result.total;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadMoreFavorites() async {
    if (_loadingMore || !_hasMore) return;

    try {
      setState(() {
        _loadingMore = true;
      });

      final nextPage = _currentPage + 1;
      final result = await DatabaseHelper.getFavoritesPaginated(
        page: nextPage,
        limit: _limit,
      );

      setState(() {
        _favorites.addAll(result.items);
        _currentPage = nextPage;
        _loadingMore = false;
        _hasMore = result.hasMore;
      });
    } catch (e) {
      setState(() {
        _loadingMore = false;
      });
      debugPrint('Error loading more favorites: $e');
    }
  }

  Future<void> _refreshFavorites() async {
    await _loadFavorites();
  }

  Future<void> _removeFromFavorites(WordPreviewModel word) async {
    try {
      await DatabaseHelper.removeFromFavorites(word.word);

      // Remove from local list
      setState(() {
        _favorites.removeWhere((w) => w.id == word.id);
      });

      // If we're on the last page and remove an item, we might need to load more
      if (_favorites.length < _currentPage * _limit && _hasMore) {
        _loadMoreFavorites();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showWordDetails(WordPreviewModel word) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                WordDefinitionScreen(wordName: word.word),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites'), elevation: 0),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _favorites.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError && _favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Failed to load favorites',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tap the heart icon on any word to add it to your favorites',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFavorites,
      child: Column(
        children: [
          if (_total != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_total!} favorite words',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _favorites.length + (_loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _favorites.length) {
                  return _buildLoadingMoreIndicator();
                }

                final word = _favorites[index];
                return WordCard(
                  word: word,
                  isFavorite: true,
                  onTap: () {
                    _showWordDetails(word);
                    DatabaseHelper.addToRecents(word);
                  },
                  onFavoriteToggle: () => _removeFromFavorites(word),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child:
            _hasMore
                ? const CircularProgressIndicator()
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No more favorite words',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
      ),
    );
  }
}
