import 'dart:async';

import 'package:flutter/material.dart';

import '../services/nominatim_service.dart';
import '../services/search_history_service.dart';

class SearchBarWidget extends StatefulWidget {
  final void Function(double lat, double lng, String name) onLocationSelected;

  const SearchBarWidget({super.key, required this.onLocationSelected});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _nominatim = NominatimService();
  final _history = SearchHistoryService();

  Timer? _debounce;
  List<NominatimResult> _suggestions = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _controller.text.isEmpty) {
        setState(() => _showSuggestions = true);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await _history.getHistory();
    if (mounted) setState(() => _recentSearches = history);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = _focusNode.hasFocus;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isLoading = true);
      try {
        final results = await _nominatim.search(query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _showSuggestions = true;
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  void _selectResult(NominatimResult result) {
    _controller.clear();
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
    _history.addEntry(result.displayName);
    _loadHistory();
    widget.onLocationSelected(
        result.latitude, result.longitude, result.displayName);
  }

  void _selectHistoryEntry(String entry) {
    _controller.text = entry;
    _onSearchChanged(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Ort oder Adresse suchen...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _suggestions = [];
                          _showSuggestions = false;
                        });
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        if (_showSuggestions) _buildDropdown(context),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    if (_suggestions.isNotEmpty) {
      return _buildSuggestionList();
    }

    if (_recentSearches.isNotEmpty && _controller.text.isEmpty) {
      return _buildHistoryList();
    }

    return const SizedBox.shrink();
  }

  Widget _buildSuggestionList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _suggestions.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final result = _suggestions[index];
          return ListTile(
            leading: const Icon(Icons.place),
            title: Text(
              result.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            dense: true,
            onTap: () => _selectResult(result),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _recentSearches
            .map((entry) => ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(
                    entry,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  dense: true,
                  onTap: () => _selectHistoryEntry(entry),
                ))
            .toList(),
      ),
    );
  }
}
