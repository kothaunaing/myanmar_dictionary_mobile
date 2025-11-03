import 'package:flutter/material.dart';
import 'package:myanmar_dictionary_mobile/models/word_model.dart';
import 'package:myanmar_dictionary_mobile/services/database_helper.dart';

class WordDefinitionScreen extends StatefulWidget {
  final String wordName;
  const WordDefinitionScreen({super.key, required this.wordName});

  @override
  State<WordDefinitionScreen> createState() => _WordDefinitionScreenState();
}

class _WordDefinitionScreenState extends State<WordDefinitionScreen> {
  List<WordModel> _words = [];
  List<WordPreviewModel?> _prevNextWords = [];
  bool _isLoading = true;
  bool _isFavorite = false;
  // TextToSpeech textToSpeech = TextToSpeech();

  @override
  void initState() {
    super.initState();
    _fetchWords();
    _checkIfFavorite();
  }

  Future<void> _fetchWords() async {
    try {
      final results = await DatabaseHelper.getWordsWithWordName(
        widget.wordName,
      );
      final prevNextWords = await DatabaseHelper.getPrevAndNextWords(
        widget.wordName,
      );

      setState(() {
        _words = results;
        _prevNextWords = prevNextWords;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
    }
  }

  Future<void> _checkIfFavorite() async {
    bool favorite = await DatabaseHelper.isFavorite(widget.wordName);
    setState(() {
      _isFavorite = favorite;
    });
  }

  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      await DatabaseHelper.addToFavorites(
        WordPreviewModel.fromJson(_words.first.toJson()),
      );
    } else {
      await DatabaseHelper.removeFromFavorites(_words.first.word);
    }
  }

  void _navigateToWord(String wordName, {bool isNext = true}) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                WordDefinitionScreen(wordName: wordName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(isNext ? 1.0 : -1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.wordName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              color: _isFavorite ? Colors.red : null,
            ),
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
          // IconButton(
          //   onPressed: () {
          //     // Share functionality
          //     _shareWord();
          //   },
          //   icon: const Icon(Icons.share_rounded),
          //   tooltip: 'Share word',
          // ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _words.isEmpty
              ? _buildEmptyState()
              : _buildWordDefinitions(),
      bottomNavigationBar: _buildNavigationButtons(),
    );
  }

  Widget _buildNavigationButtons() {
    if (_isLoading || _words.isEmpty || _prevNextWords.length < 2) {
      return const SizedBox.shrink();
    }

    final prevWord = _prevNextWords[0];
    final nextWord = _prevNextWords[1];

    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous button
            Expanded(
              child: _buildNavigationButton(word: prevWord, isNext: false),
            ),
            const SizedBox(width: 12),
            // Next button
            Expanded(
              child: _buildNavigationButton(word: nextWord, isNext: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required WordPreviewModel? word,
    required bool isNext,
  }) {
    final isEnabled = word != null;
    final icon = isNext ? Icons.arrow_forward_ios : Icons.arrow_back_ios;
    final text = isNext ? 'Next' : 'Previous';

    return ElevatedButton(
      onPressed:
          isEnabled ? () => _navigateToWord(word!.word, isNext: isNext) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isEnabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
        foregroundColor:
            isEnabled
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment:
            isNext ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isNext) ...[Icon(icon, size: 16), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isNext ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color:
                        isEnabled
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.38),
                  ),
                ),
                if (isEnabled) ...[
                  const SizedBox(height: 2),
                  Text(
                    word!.word,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isNext) ...[const SizedBox(width: 8), Icon(icon, size: 16)],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading definition...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
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
            color: Theme.of(context).hintColor.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Definition not found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sorry, we couldn\'t find the definition for "${widget.wordName}"',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordDefinitions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word header
          _buildWordHeader(),
          const SizedBox(height: 24),

          // Definitions list
          ..._words.asMap().entries.map((entry) {
            final index = entry.key;
            final word = entry.value;
            return _buildDefinitionCard(word, index);
          }),
        ],
      ),
    );
  }

  Widget _buildWordHeader() {
    final firstWord = _words.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main word with serial
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  firstWord.word,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Phonetics and pronunciation
          if (firstWord.phonetics != null && firstWord.phonetics!.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: Text(
                    '/${firstWord.phonetics!}/',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                // const SizedBox(width: 12),
                // IconButton(
                //   onPressed:
                //       () => textToSpeech.speakWord(
                //         firstWord.word,
                //         firstWord.phonetics,
                //       ),
                //   icon: Icon(
                //     Icons.volume_up_rounded,
                //     color: Theme.of(context).colorScheme.primary,
                //     size: 24,
                //   ),
                //   style: IconButton.styleFrom(
                //     backgroundColor: Theme.of(
                //       context,
                //     ).colorScheme.primary.withOpacity(0.1),
                //     padding: const EdgeInsets.all(8),
                //   ),
                // ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDefinitionCard(WordModel word, int index) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Part of speech header
          if (word.partOfSpeech != null && word.partOfSpeech!.isNotEmpty)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getColorForPartOfSpeech(
                      word.partOfSpeech!,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${word.partOfSpeech} ${word.type.isNotEmpty ? word.type : ""}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getColorForPartOfSpeech(word.partOfSpeech!),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (word.serial != null && word.serial!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${word.serial}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
              ],
            ),

          if (word.partOfSpeech != null && word.partOfSpeech!.isNotEmpty)
            const SizedBox(height: 16),

          // Meaning
          Text(
            word.meaning.replaceAll(r'\n', '\n'),
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
          if (word.origin != null && word.origin.isNotEmpty) ...[
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                word.origin,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColorForPartOfSpeech(String partOfSpeech) {
    final pos = partOfSpeech.toLowerCase();

    if (pos.contains('နာမ်')) return Colors.blue;
    if (pos.contains('ကြိယာ')) return Colors.green;
    if (pos.contains('နာမဝိသေသန')) return Colors.orange;
    if (pos.contains('ကြိယာဝိသေသန')) return Colors.purple;
    if (pos.contains('နာမ်စား')) return Colors.teal;
    if (pos.contains('ဝိဘတ်')) return Colors.pink;

    return Colors.grey;
  }

  void _shareWord() {
    // Implement share functionality
    // You can use packages like share_plus
  }
}
