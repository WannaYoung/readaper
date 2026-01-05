class ReadingContentService {
  String preprocessMarkdown(String text) {
    String processed = text
        .replaceAll('http://', 'https://')
        .replaceFirst(RegExp(r'^---[\s\S]*?---\s*'), '')
        .replaceAll('。**', '**');

    processed = _removeFirstImageAfterFirstH1(processed);
    processed = _removeWwwInBracketText(processed);
    return processed;
  }

  String _removeFirstImageAfterFirstH1(String text) {
    final matchH1 = RegExp(r'^#\s+.+$', multiLine: true).firstMatch(text);
    if (matchH1 == null) return text;

    final start = matchH1.end;
    if (start < 0 || start >= text.length) return text;

    final after = text.substring(start);
    final matchImage = RegExp(
      r'^\s*(?:\r?\n)+\s*!\[[^\]]*\]\(\s*(?:<[^>]+>|[^)\s]+)(?:\s+"[^"]*")?\s*\)\s*(?:\r?\n+)?',
    ).firstMatch(after);
    if (matchImage == null) return text;

    return text.substring(0, start) +
        after.replaceRange(matchImage.start, matchImage.end, '\n');
  }

  String _removeWwwInBracketText(String text) {
    return text.replaceAllMapped(
      RegExp(r'(!?)\[([^\]]*)\]\(([^)]+)\)'),
      (m) {
        final prefix = m.group(1) ?? '';
        final bracketText = m.group(2) ?? '';
        final dest = m.group(3) ?? '';
        final cleaned = bracketText.replaceAll(RegExp(r'\bwww\.'), '');
        return '$prefix[$cleaned]($dest)';
      },
    );
  }

  List<String> extractImageUrls(String text) {
    final urls = <String>[];
    final seen = <String>{};

    final matches = RegExp(r'!\[[^\]]*\]\(([^)\s]+)').allMatches(text);
    for (final m in matches) {
      final raw = (m.group(1) ?? '').trim();
      if (raw.isEmpty) continue;
      final url = raw.startsWith('<') && raw.endsWith('>')
          ? raw.substring(1, raw.length - 1)
          : raw;
      if (url.isEmpty) continue;
      if (seen.add(url)) {
        urls.add(url);
      }
    }
    return urls;
  }
}
