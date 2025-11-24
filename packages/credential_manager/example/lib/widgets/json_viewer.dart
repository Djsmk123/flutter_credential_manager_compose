import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that displays JSON data in a formatted, syntax-highlighted view
/// with collapsible sections for objects and arrays.
class JsonViewer extends StatelessWidget {
  final Map<String, dynamic> data;
  final String? title;
  final bool initiallyExpanded;

  const JsonViewer({
    super.key,
    required this.data,
    this.title,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.data_object,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyToClipboard(context),
                    tooltip: 'Copy JSON',
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: title == null
                  ? BorderRadius.circular(12)
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
            ),
            child: _JsonObjectView(
              data: data,
              initiallyExpanded: initiallyExpanded,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final jsonString = _prettyPrintJson(data);
    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _prettyPrintJson(Map<String, dynamic> json, [int indent = 0]) {
    final buffer = StringBuffer();
    final spaces = '  ' * indent;
    final childSpaces = '  ' * (indent + 1);

    buffer.writeln('{');
    final entries = json.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('$childSpaces"${entry.key}": ');
      buffer.write(_formatValue(entry.value, indent + 1));
      if (i < entries.length - 1) buffer.write(',');
      buffer.writeln();
    }
    buffer.write('$spaces}');

    return buffer.toString();
  }

  String _formatValue(dynamic value, int indent) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is num || value is bool) return value.toString();
    if (value is Map<String, dynamic>) return _prettyPrintJson(value, indent);
    if (value is List) {
      if (value.isEmpty) return '[]';
      final buffer = StringBuffer();
      final spaces = '  ' * indent;
      final childSpaces = '  ' * (indent + 1);
      buffer.writeln('[');
      for (var i = 0; i < value.length; i++) {
        buffer.write(childSpaces);
        buffer.write(_formatValue(value[i], indent + 1));
        if (i < value.length - 1) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('$spaces]');
      return buffer.toString();
    }
    return value.toString();
  }
}

class _JsonObjectView extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool initiallyExpanded;

  const _JsonObjectView({
    required this.data,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        return _JsonEntryView(
          keyName: entry.key,
          value: entry.value,
          initiallyExpanded: initiallyExpanded,
        );
      }).toList(),
    );
  }
}

class _JsonEntryView extends StatefulWidget {
  final String keyName;
  final dynamic value;
  final bool initiallyExpanded;

  const _JsonEntryView({
    required this.keyName,
    required this.value,
    this.initiallyExpanded = true,
  });

  @override
  State<_JsonEntryView> createState() => _JsonEntryViewState();
}

class _JsonEntryViewState extends State<_JsonEntryView> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final isExpandable = widget.value is Map || widget.value is List;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: isExpandable
                ? () => setState(() => _isExpanded = !_isExpanded)
                : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isExpandable)
                    Icon(
                      _isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 4),
                  Text(
                    widget.keyName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    ': ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (!isExpandable)
                    Expanded(child: _buildValueWidget(context, widget.value))
                  else
                    Text(
                      _getCollapsedPreview(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isExpandable && _isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: _buildExpandedContent(),
            ),
        ],
      ),
    );
  }

  String _getCollapsedPreview() {
    if (widget.value is Map) {
      final map = widget.value as Map;
      return '{${map.length} ${map.length == 1 ? 'item' : 'items'}}';
    }
    if (widget.value is List) {
      final list = widget.value as List;
      return '[${list.length} ${list.length == 1 ? 'item' : 'items'}]';
    }
    return '';
  }

  Widget _buildExpandedContent() {
    if (widget.value is Map<String, dynamic>) {
      return _JsonObjectView(
        data: widget.value as Map<String, dynamic>,
        initiallyExpanded: widget.initiallyExpanded,
      );
    }
    if (widget.value is List) {
      return _JsonArrayView(
        data: widget.value as List,
        initiallyExpanded: widget.initiallyExpanded,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildValueWidget(BuildContext context, dynamic value) {
    if (value == null) {
      return Text(
        'null',
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
          fontFamily: 'monospace',
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (value is bool) {
      return Text(
        value.toString(),
        style: TextStyle(
          color: value ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
      );
    }

    if (value is num) {
      return Text(
        value.toString(),
        style: TextStyle(
          color: Colors.orange.shade800,
          fontFamily: 'monospace',
        ),
      );
    }

    if (value is String) {
      // Check if it's a URL
      final isUrl = value.startsWith('http://') || value.startsWith('https://');
      return Text(
        '"$value"',
        style: TextStyle(
          color: isUrl ? Colors.blue.shade700 : Colors.green.shade800,
          fontFamily: 'monospace',
        ),
        softWrap: true,
      );
    }

    return Text(
      value.toString(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontFamily: 'monospace',
      ),
    );
  }
}

class _JsonArrayView extends StatelessWidget {
  final List data;
  final bool initiallyExpanded;

  const _JsonArrayView({
    required this.data,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.asMap().entries.map((entry) {
        return _JsonEntryView(
          keyName: '[${entry.key}]',
          value: entry.value,
          initiallyExpanded: initiallyExpanded,
        );
      }).toList(),
    );
  }
}
