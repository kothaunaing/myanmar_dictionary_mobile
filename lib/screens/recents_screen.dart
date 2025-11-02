// screens/recents_screen.dart
import 'package:flutter/material.dart';
import 'package:myanmar_dictionary_mobile/models/word_model.dart';
import 'package:myanmar_dictionary_mobile/screens/word_definition_screen.dart';
import 'package:myanmar_dictionary_mobile/services/database_helper.dart';
import 'package:myanmar_dictionary_mobile/widgets/word_cart_widget.dart';

class RecentsScreen extends StatefulWidget {
  const RecentsScreen({Key? key}) : super(key: key);

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
  List<WordPreviewModel> _recents = [];
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
    _loadRecents();
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
        _loadMoreRecents();
      }
    });
  }

  Future<void> _loadRecents() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _currentPage = 1;
        _hasMore = true;
      });

      final result = await DatabaseHelper.getRecentsPaginated(
        page: _currentPage,
        limit: _limit,
      );

      setState(() {
        _recents = result.items;
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

  Future<void> _loadMoreRecents() async {
    if (_loadingMore || !_hasMore) return;

    try {
      setState(() {
        _loadingMore = true;
      });

      final nextPage = _currentPage + 1;
      final result = await DatabaseHelper.getRecentsPaginated(
        page: nextPage,
        limit: _limit,
      );

      setState(() {
        _recents.addAll(result.items);
        _currentPage = nextPage;
        _loadingMore = false;
        _hasMore = result.hasMore;
      });
    } catch (e) {
      setState(() {
        _loadingMore = false;
      });
      debugPrint('Error loading more recents: $e');
    }
  }

  Future<void> _refreshRecents() async {
    await _loadRecents();
  }

  Future<void> _clearAllRecents() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Recent Words'),
            content: const Text(
              'Are you sure you want to clear all recent words? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );

    if (shouldClear == true) {
      try {
        await DatabaseHelper.clearRecents();
        setState(() {
          _recents.clear();
          _currentPage = 1;
          _hasMore = false;
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> _removeRecent(WordPreviewModel word) async {
    try {
      await DatabaseHelper.removeRecent(word.id);

      // Remove from local list
      setState(() {
        _recents.removeWhere((w) => w.id == word.id);
      });

      // If we're on the last page and remove an item, we might need to load more
      if (_recents.length < _currentPage * _limit && _hasMore) {
        _loadMoreRecents();
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
      appBar: AppBar(title: const Text('Recent Words'), elevation: 0),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _recents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError && _recents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Failed to load recent words',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecents,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_recents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No recent words',
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
                'Words you search for will appear here for quick access',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshRecents,
      child: Column(
        children: [
          if (_total != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_total!} recent words',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAllRecents,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _recents.length + (_loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _recents.length) {
                  return _buildLoadingMoreIndicator();
                }

                final word = _recents[index];
                return FutureBuilder<bool>(
                  future: DatabaseHelper.isFavorite(word.word),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    return WordCard(
                      word: word,
                      isFavorite: isFavorite,
                      onTap: () => _showWordDetails(word),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => _removeRecent(word),
                        tooltip: 'Remove from recents',
                      ),
                    );
                  },
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
                    'No more recent words',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
      ),
    );
  }
}
