import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myanmar_dictionary_mobile/models/word_model.dart';
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
        limit: 50,
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
      appBar: AppBar(
        title: const Text("Myanmar Dictionary"),
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
