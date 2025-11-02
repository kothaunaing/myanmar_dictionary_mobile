import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myanmar_dictionary_mobile/config/config.dart';
import 'package:myanmar_dictionary_mobile/models/word_model.dart';
import 'package:myanmar_dictionary_mobile/screens/favorites_screen.dart';
import 'package:myanmar_dictionary_mobile/screens/recents_screen.dart';
import 'package:myanmar_dictionary_mobile/screens/settings_screen.dart';
import 'package:myanmar_dictionary_mobile/services/database_helper.dart';
import 'package:myanmar_dictionary_mobile/widgets/search_input_widget.dart';
import 'package:myanmar_dictionary_mobile/widgets/words_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<WordPreviewModel> _words = [];
  int? total;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _currentQuery = '';

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchWords(query: "", page: 1);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController.text.trim();
      if (query != _currentQuery) {
        _resetSearch();
        _currentQuery = query;
        _searchWords(query: query, page: 1);
      }
    });
  }

  void _resetSearch() {
    setState(() {
      _currentPage = 1;
      _words.clear();
      _hasMore = true;
      _isLoading = false;
    });
  }

  Future<void> _searchWords({required String query, required int page}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await DatabaseHelper.searchWord(
        query,
        page: page,
        limit: 100,
      );

      setState(() {
        if (page == 1) {
          _words = result.items;
        } else {
          _words.addAll(result.items);
        }
        total = result.total;
        _currentPage = page;
        _hasMore = result.hasMore;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
      print('Search error: $error');
    }
  }

  void _loadMore() {
    if (!_isLoading && _hasMore) {
      _searchWords(query: _currentQuery, page: _currentPage + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        "assets/icon/app_icon.png",
                        height: 40,
                        width: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Your Language Companion",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items Section
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildMenuItem(
                      context: context,
                      icon: Icons.favorite_rounded,
                      title: "Favorites",
                      subtitle: "Your saved words",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.history_rounded,
                      title: "Recents",
                      subtitle: "Recently searched",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecentsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Footer Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Version",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          appVersion,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Thank you for using $appName!",
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(appName),
        actions: [
          Tooltip(
            message: "Settings",
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SearchInputWidget(controller: _searchController),
          Expanded(
            child: WordsList(
              total: total,
              words: _words,
              query: _currentQuery,
              isLoading: _isLoading,
              onLoadMore: _loadMore,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for menu items
Widget _buildMenuItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    ),
    trailing: Icon(
      Icons.chevron_right_rounded,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    minVerticalPadding: 0,
    onTap: onTap,
  );
}
