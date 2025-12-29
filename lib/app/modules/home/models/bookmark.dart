class Bookmark {
  String? id;
  String? title;
  String? description;
  String? site;
  String? iconUrl;
  String? articleUrl;
  String? created;
  String? updated;
  bool isMarked;
  bool isArchived;
  bool isDeleted;

  Bookmark({
    this.id,
    this.title,
    this.description,
    this.site,
    this.iconUrl,
    this.articleUrl,
    this.created,
    this.updated,
    this.isMarked = false,
    this.isArchived = false,
    this.isDeleted = false,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    final resources = json['resources'] ?? {};
    return Bookmark(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      site: json['site_name'] ?? json['site'],
      iconUrl: (resources['icon']?['src'] as String?)
          ?.replaceFirst('http:', 'https:'),
      articleUrl: resources['article']?['src']?.replaceFirst('http:', 'https:'),
      created: (json['created'] as String?)?.split('T').first,
      updated: json['updated'],
      isMarked: json['is_marked'] ?? false,
      isArchived: json['is_archived'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'site': site,
      'created': created,
      'updated': updated,
      'is_marked': isMarked,
      'is_archived': isArchived,
      'is_deleted': isDeleted,
    };
  }

  Bookmark copyWith({
    bool? isMarked,
    bool? isArchived,
    bool? isDeleted,
  }) {
    return Bookmark(
      id: id,
      title: title,
      description: description,
      site: site,
      iconUrl: iconUrl,
      articleUrl: articleUrl,
      created: created,
      updated: updated,
      isMarked: isMarked ?? this.isMarked,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
