/// 书签分类数量
///
/// - 用于首页侧边栏展示
class BookmarkCounts {
  final int all;
  final int unread;
  final int archived;
  final int favorite;
  final int video;

  const BookmarkCounts({
    this.all = 0,
    this.unread = 0,
    this.archived = 0,
    this.favorite = 0,
    this.video = 0,
  });

  BookmarkCounts copyWith({
    int? all,
    int? unread,
    int? archived,
    int? favorite,
    int? video,
  }) {
    return BookmarkCounts(
      all: all ?? this.all,
      unread: unread ?? this.unread,
      archived: archived ?? this.archived,
      favorite: favorite ?? this.favorite,
      video: video ?? this.video,
    );
  }
}
