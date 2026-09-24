// Lightweight parser for OSM opening_hours strings.
// Covers the most common formats (~90% of real-world data).
// Falls back gracefully to raw text for uncommon formats.

class OpeningHoursStatus {
  final bool isOpen;
  final String? nextChange; // e.g. "Schließt um 02:00" or "Öffnet um 18:00"
  final String formatted; // human-readable version of the raw string

  const OpeningHoursStatus({
    required this.isOpen,
    this.nextChange,
    required this.formatted,
  });
}

OpeningHoursStatus parseOpeningHours(String raw, {DateTime? now}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return const OpeningHoursStatus(
        isOpen: false, formatted: '', nextChange: null);
  }

  now ??= DateTime.now();

  // 24/7
  if (trimmed == '24/7') {
    return const OpeningHoursStatus(
      isOpen: true,
      nextChange: 'Rund um die Uhr',
      formatted: '24/7',
    );
  }

  final formatted = _humanFormat(trimmed);

  // Try to parse and evaluate
  try {
    final rules = _parseRules(trimmed);
    if (rules.isEmpty) {
      return OpeningHoursStatus(
          isOpen: false, formatted: formatted, nextChange: null);
    }

    final weekday = now.weekday; // 1=Mo .. 7=Su
    final minutes = now.hour * 60 + now.minute;

    for (final rule in rules) {
      if (!rule.days.contains(weekday)) continue;
      for (final span in rule.spans) {
        if (_isInSpan(minutes, span)) {
          final closeStr = _minutesToTime(span.end % 1440);
          return OpeningHoursStatus(
            isOpen: true,
            nextChange: 'Schließt um $closeStr',
            formatted: formatted,
          );
        }
      }
    }

    // Not open now — find next opening
    final nextOpen = _findNextOpening(rules, weekday, minutes);
    return OpeningHoursStatus(
      isOpen: false,
      nextChange: nextOpen,
      formatted: formatted,
    );
  } catch (_) {
    // Unparseable — return raw text as fallback
    return OpeningHoursStatus(
        isOpen: false, formatted: formatted, nextChange: null);
  }
}

// ---------------------------------------------------------------------------
// Internal parsing
// ---------------------------------------------------------------------------

class _Rule {
  final Set<int> days; // 1=Mo .. 7=Su
  final List<_TimeSpan> spans;
  _Rule(this.days, this.spans);
}

class _TimeSpan {
  final int start; // minutes since midnight
  final int end; // can be >1440 for overnight spans
  _TimeSpan(this.start, this.end);
}

List<_Rule> _parseRules(String raw) {
  final rules = <_Rule>[];
  // Split by ";" for multiple rules
  for (final part in raw.split(';')) {
    final trimmed = part.trim();
    if (trimmed.isEmpty) continue;
    // Skip comments like "by appointment"
    if (trimmed.startsWith('"')) continue;
    // Skip "off" rules (holidays etc.)
    if (trimmed.endsWith('off')) continue;

    final rule = _parseRule(trimmed);
    if (rule != null) rules.add(rule);
  }
  return rules;
}

_Rule? _parseRule(String part) {
  // Try to split into day-part and time-part
  // Formats: "Mo-Fr 18:00-02:00", "Sa,Su 16:00-02:00,08:00-12:00"
  //          "18:00-02:00" (no day = every day)

  final timePattern = RegExp(r'(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})');
  final firstTime = timePattern.firstMatch(part);
  if (firstTime == null) return null;

  final dayPart = part.substring(0, firstTime.start).trim();
  final timePart = part.substring(firstTime.start).trim();

  final days = dayPart.isEmpty ? {1, 2, 3, 4, 5, 6, 7} : _parseDays(dayPart);
  if (days.isEmpty) return null;

  final spans = <_TimeSpan>[];
  for (final match in timePattern.allMatches(timePart)) {
    final start = _parseTime(match.group(1)!);
    var end = _parseTime(match.group(2)!);
    if (end <= start) end += 1440; // overnight
    spans.add(_TimeSpan(start, end));
  }

  return spans.isEmpty ? null : _Rule(days, spans);
}

final _dayNames = {
  'Mo': 1, 'Tu': 2, 'We': 3, 'Th': 4, 'Fr': 5, 'Sa': 6, 'Su': 7,
};

Set<int> _parseDays(String dayStr) {
  final days = <int>{};
  // Handle comma-separated groups: "Mo-Fr,Su" or "Mo,We,Fr"
  for (final group in dayStr.split(',')) {
    final trimmed = group.trim();
    if (trimmed.contains('-')) {
      final parts = trimmed.split('-');
      if (parts.length == 2) {
        final start = _dayNames[parts[0].trim()];
        final end = _dayNames[parts[1].trim()];
        if (start != null && end != null) {
          if (start <= end) {
            for (var i = start; i <= end; i++) {
              days.add(i);
            }
          } else {
            // Wrap around: Fr-Mo = Fr,Sa,Su,Mo
            for (var i = start; i <= 7; i++) {
              days.add(i);
            }
            for (var i = 1; i <= end; i++) {
              days.add(i);
            }
          }
        }
      }
    } else {
      final day = _dayNames[trimmed];
      if (day != null) days.add(day);
    }
  }
  return days;
}

int _parseTime(String t) {
  final parts = t.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

bool _isInSpan(int minutes, _TimeSpan span) {
  if (span.end > 1440) {
    // Overnight: 22:00-02:00 → start=1320, end=1560
    return minutes >= span.start || minutes < (span.end - 1440);
  }
  return minutes >= span.start && minutes < span.end;
}

String? _findNextOpening(List<_Rule> rules, int currentDay, int currentMinutes) {
  // Check remaining spans today
  for (final rule in rules) {
    if (!rule.days.contains(currentDay)) continue;
    for (final span in rule.spans) {
      final effectiveStart = span.start;
      if (effectiveStart > currentMinutes) {
        return 'Öffnet um ${_minutesToTime(effectiveStart)}';
      }
    }
  }

  // Check next 7 days
  for (var offset = 1; offset <= 7; offset++) {
    final day = ((currentDay - 1 + offset) % 7) + 1;
    for (final rule in rules) {
      if (!rule.days.contains(day)) continue;
      if (rule.spans.isNotEmpty) {
        final dayName = _dayLabels[day] ?? '';
        final time = _minutesToTime(rule.spans.first.start);
        return offset == 1
            ? 'Öffnet morgen um $time'
            : 'Öffnet $dayName um $time';
      }
    }
  }
  return null;
}

String _minutesToTime(int minutes) {
  final h = (minutes ~/ 60) % 24;
  final m = minutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

const _dayLabels = {
  1: 'Mo', 2: 'Di', 3: 'Mi', 4: 'Do', 5: 'Fr', 6: 'Sa', 7: 'So',
};

/// Make the raw string slightly more readable.
String _humanFormat(String raw) {
  return raw
      .replaceAll('Mo', 'Mo')
      .replaceAll('Tu', 'Di')
      .replaceAll('We', 'Mi')
      .replaceAll('Th', 'Do')
      .replaceAll('Fr', 'Fr')
      .replaceAll('Sa', 'Sa')
      .replaceAll('Su', 'So');
}
