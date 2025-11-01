import 'package:flutter/material.dart';

class SearchInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSubmitted;
  final String hintText;

  const SearchInputWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.onSubmitted,
    this.hintText = "Search for words...",
  });

  @override
  State<SearchInputWidget> createState() => _SearchInputWidgetState();
}

class _SearchInputWidgetState extends State<SearchInputWidget> {
  bool _hasText = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _clearText() {
    widget.controller.clear();
    setState(() {
      _hasText = false;
    });
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  void _onSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      widget.onSubmitted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (_focusNode.hasFocus)
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: false,
          textInputAction: TextInputAction.search,
          onChanged: widget.onChanged,
          onSubmitted: _onSubmitted,
          // REMOVED the onTap callback that was causing the focus behavior
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: theme.hintColor.withOpacity(0.7),
              fontSize: 16,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                Icons.search_rounded,
                color:
                    _focusNode.hasFocus
                        ? theme.colorScheme.primary
                        : theme.hintColor.withOpacity(0.7),
                size: 24,
              ),
            ),
            suffixIcon:
                _hasText
                    ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.hintColor.withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: theme.hintColor.withOpacity(0.7),
                          ),
                        ),
                        onPressed: _clearText,
                        splashRadius: 20,
                      ),
                    )
                    : null,
            filled: true,
            fillColor:
                isDark
                    ? theme.colorScheme.surface.withOpacity(0.8)
                    : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: theme.dividerColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w400,
          ),
          cursorColor: theme.colorScheme.primary,
          cursorWidth: 1.5,
        ),
      ),
    );
  }
}
