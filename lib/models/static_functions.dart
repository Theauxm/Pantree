List<String> getKeywords(String word) {
  word = word.toLowerCase();

  Set<String> keywords = {};
  for (int i = 0; i < word.length; i++)
    for (int j = 0; j < word.length; j++) {
      if (i > j)
        continue;
      keywords.add(word.substring(i, j + 1));
    }

    return keywords.toList();
}