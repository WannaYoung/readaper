class Bookmark {
  String? id;
  String? href;
  String? title;
  String? description;
  String? siteName;
  String? site;
  String? published;
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

  BookmarkResources? resources;

  int? wordCount;
  int? readingTime;

  Bookmark({
    this.id,
    this.href,
    this.title,
    this.description,
    this.siteName,
    this.site,
    this.published,
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
    this.resources,
    this.wordCount,
    this.readingTime,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      href: json['href'],
      title: json['title'] ?? '',
      description: json['description'],
      siteName: json['site_name'],
      site: json['site'],
      published: json['published'],
      url: json['url'],
      created: json['created'],
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
      resources: json['resources'] is Map<String, dynamic>
          ? BookmarkResources.fromJson(
              json['resources'] as Map<String, dynamic>)
          : null,
      wordCount:
          (json['word_count'] is int) ? (json['word_count'] as int) : null,
      readingTime:
          (json['reading_time'] is int) ? (json['reading_time'] as int) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'href': href,
      'title': title,
      'description': description,
      'site_name': siteName,
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
      'published': published,
      'read_progress': readProgress,
      'is_marked': isMarked,
      'is_archived': isArchived,
      'is_deleted': isDeleted,
      'authors': authors,
      'labels': labels,
      'resources': resources?.toJson(),
      'word_count': wordCount,
      'reading_time': readingTime,
    };
  }

  String? get iconUrl => resources?.icon?.src?.replaceFirst('http:', 'https:');

  String? get articleUrl =>
      resources?.article?.src?.replaceFirst('http:', 'https:');

  String? get imageUrl =>
      resources?.image?.src?.replaceFirst('http:', 'https:');

  String? get thumbnailUrl =>
      resources?.thumbnail?.src?.replaceFirst('http:', 'https:');

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
      siteName: siteName,
      site: site,
      published: published,
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
      resources: resources,
      wordCount: wordCount,
      readingTime: readingTime,
    );
  }
}

class BookmarkResources {
  BookmarkResourceItem? article;
  BookmarkResourceItem? icon;
  BookmarkResourceItem? image;
  BookmarkResourceItem? thumbnail;
  BookmarkResourceItem? log;
  BookmarkResourceItem? props;

  BookmarkResources({
    this.article,
    this.icon,
    this.image,
    this.thumbnail,
    this.log,
    this.props,
  });

  factory BookmarkResources.fromJson(Map<String, dynamic> json) {
    BookmarkResourceItem? parseItem(dynamic raw) {
      if (raw is Map<String, dynamic>) {
        return BookmarkResourceItem.fromJson(raw);
      }
      return null;
    }

    return BookmarkResources(
      article: parseItem(json['article']),
      icon: parseItem(json['icon']),
      image: parseItem(json['image']),
      thumbnail: parseItem(json['thumbnail']),
      log: parseItem(json['log']),
      props: parseItem(json['props']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'article': article?.toJson(),
      'icon': icon?.toJson(),
      'image': image?.toJson(),
      'thumbnail': thumbnail?.toJson(),
      'log': log?.toJson(),
      'props': props?.toJson(),
    };
  }
}

class BookmarkResourceItem {
  String? src;
  int? width;
  int? height;

  BookmarkResourceItem({
    this.src,
    this.width,
    this.height,
  });

  factory BookmarkResourceItem.fromJson(Map<String, dynamic> json) {
    return BookmarkResourceItem(
      src: json['src'],
      width: (json['width'] is int) ? (json['width'] as int) : null,
      height: (json['height'] is int) ? (json['height'] as int) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'src': src,
      'width': width,
      'height': height,
    };
  }
}
