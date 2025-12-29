class Bookmark {
  String? id;
  String? href;
  String? title;
  String? description;
  String? site;
  String? iconUrl;
  String? articleUrl;
  String? imageUrl;
  String? thumbnailUrl;
  String? url;
  String? created;
  String? updated;
  int state;
  bool loaded;
  String? documentType;
  String? type;
  bool hasArticle;
  String? lang;
  String? textDirection;
  int readProgress;
  bool isMarked;
  bool isArchived;
  bool isDeleted;
  List<dynamic>? authors;
  List<dynamic>? labels;

  Bookmark({
    this.id,
    this.href,
    this.title,
    this.description,
    this.site,
    this.iconUrl,
    this.articleUrl,
    this.imageUrl,
    this.thumbnailUrl,
    this.url,
    this.created,
    this.updated,
    this.state = 0,
    this.loaded = false,
    this.documentType,
    this.type,
    this.hasArticle = false,
    this.lang,
    this.textDirection,
    this.readProgress = 0,
    this.isMarked = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.authors,
    this.labels,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    final resources = json['resources'] ?? {};
    return Bookmark(
      id: json['id'],
      href: json['href'],
      title: json['title'] ?? '',
      description: json['description'],
      site: json['site_name'] ?? json['site'],
      iconUrl: (resources['icon']?['src'] as String?)
          ?.replaceFirst('http:', 'https:'),
      articleUrl: resources['article']?['src']?.replaceFirst('http:', 'https:'),
      imageUrl: resources['image']?['src']?.replaceFirst('http:', 'https:'),
      thumbnailUrl:
          resources['thumbnail']?['src']?.replaceFirst('http:', 'https:'),
      url: json['url'],
      created: (json['created'] as String?)?.split('T').first,
      updated: json['updated'],
      state: (json['state'] is int) ? (json['state'] as int) : 0,
      loaded: json['loaded'] == true,
      documentType: json['document_type'],
      type: json['type'],
      hasArticle: json['has_article'] == true,
      lang: json['lang'],
      textDirection: json['text_direction'],
      readProgress:
          (json['read_progress'] is int) ? (json['read_progress'] as int) : 0,
      isMarked: json['is_marked'] ?? false,
      isArchived: json['is_archived'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      authors: (json['authors'] is List) ? (json['authors'] as List) : null,
      labels: (json['labels'] is List) ? (json['labels'] as List) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'href': href,
      'title': title,
      'description': description,
      'site': site,
      'url': url,
      'created': created,
      'updated': updated,
      'state': state,
      'loaded': loaded,
      'document_type': documentType,
      'type': type,
      'has_article': hasArticle,
      'lang': lang,
      'text_direction': textDirection,
      'read_progress': readProgress,
      'is_marked': isMarked,
      'is_archived': isArchived,
      'is_deleted': isDeleted,
      'authors': authors,
      'labels': labels,
    };
  }

  Bookmark copyWith({
    bool? isMarked,
    bool? isArchived,
    bool? isDeleted,
    int? readProgress,
    String? type,
    int? state,
    bool? loaded,
  }) {
    return Bookmark(
      id: id,
      href: href,
      title: title,
      description: description,
      site: site,
      iconUrl: iconUrl,
      articleUrl: articleUrl,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      url: url,
      created: created,
      updated: updated,
      state: state ?? this.state,
      loaded: loaded ?? this.loaded,
      documentType: documentType,
      type: type ?? this.type,
      hasArticle: hasArticle,
      lang: lang,
      textDirection: textDirection,
      readProgress: readProgress ?? this.readProgress,
      isMarked: isMarked ?? this.isMarked,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      authors: authors,
      labels: labels,
    );
  }
}
