import 'package:flutter/material.dart';
import 'package:myanmar_dictionary_mobile/models/word_model.dart';
import 'package:myanmar_dictionary_mobile/screens/word_definition_screen.dart';

class WordsList extends StatefulWidget {
  final int? total;
  final List<WordPreviewModel> words;
  final String query;
  final bool isLoading;
  final VoidCallback? onLoadMore;

  const WordsList({
    super.key,
    required this.total,
    required this.words,
    required this.query,
    this.isLoading = false,
    this.onLoadMore,
  });

  @override
  State<WordsList> createState() => _WordsListState();
}

class _WordsListState extends State<WordsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      widget.onLoadMore?.call();
    }
  }

  void _navigateToDefinition(String wordName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                WordDefinitionScreen(wordName: wordName),
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
    final theme = Theme.of(context);

    return Builder(
      builder: (context) {
        if (widget.words.isEmpty &&
            widget.query.isNotEmpty &&
            !widget.isLoading) {
          return _buildEmptyState();
        }

        if (widget.words.isEmpty && widget.query.isEmpty && !widget.isLoading) {
          return _buildInitialState();
        }

        return _buildWordsList();
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Theme.of(context).hintColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No results found",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "\"${widget.query}\" wasn't found in the dictionary",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () {
              // Optional: Add suggestion or retry logic
            },
            child: const Text("Try another word"),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: Theme.of(context).hintColor.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            "Search Myanmar Dictionary",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Type a word in the search bar above to get started",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              if (widget.total != null)
                Text(
                  "${widget.total} word${widget.total == 1 ? '' : 's'} ${widget.query.isNotEmpty ? "for \"${widget.query}\"" : ""}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              // if (widget.isLoading) ...[
              //   const SizedBox(width: 8),
              //   SizedBox(
              //     width: 16,
              //     height: 16,
              //     child: CircularProgressIndicator(
              //       strokeWidth: 2,
              //       valueColor: AlwaysStoppedAnimation<Color>(
              //         Theme.of(context).colorScheme.primary,
              //       ),
              //     ),
              //   ),
              // ],
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: widget.words.length + (widget.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= widget.words.length) {
                return _buildLoadingIndicator();
              }

              final WordPreviewModel word = widget.words[index];
              return _buildWordItem(word, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWordItem(WordPreviewModel word, int index) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          onTap: () => _navigateToDefinition(word.word),
          borderRadius: BorderRadius.circular(12),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: theme.colorScheme.primary.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Word indicator/avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getColorForIndex(index).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      word.word.length > 2
                          ? word.word.substring(0, 2)
                          : word.word,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getColorForIndex(index),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Word details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.word,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (word.partOfSpeech != null &&
                          word.partOfSpeech!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            word.partOfSpeech!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Navigation indicator
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.hintColor.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}
