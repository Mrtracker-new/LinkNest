enum ItemType { link, document, note }

class Tag {
  final String id;
  final String name;
  final int? color;

  const Tag({required this.id, required this.name, this.color});
}

abstract class Item {
  final String id;
  final ItemType type;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final List<Tag> tags;

  const Item({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.tags = const [],
  });
}

class LinkItem extends Item {
  final String url;
  final String? faviconUrl;

  const LinkItem({
    required String id,
    required String title,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isFavorite = false,
    List<Tag> tags = const [],
    required this.url,
    this.faviconUrl,
  }) : super(
          id: id,
          type: ItemType.link,
          title: title,
          description: description,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isFavorite: isFavorite,
          tags: tags,
        );

  LinkItem copyWith({
    String? title,
    String? description,
    String? url,
    String? faviconUrl,
    bool? isFavorite,
    List<Tag>? tags,
  }) {
    return LinkItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }
}

class DocumentItem extends Item {
  final String filePath;
  final String fileType;
  final int fileSize;

  const DocumentItem({
    required String id,
    required String title,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isFavorite = false,
    List<Tag> tags = const [],
    required this.filePath,
    required this.fileType,
    required this.fileSize,
  }) : super(
          id: id,
          type: ItemType.document,
          title: title,
          description: description,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isFavorite: isFavorite,
          tags: tags,
        );

  DocumentItem copyWith({
    String? title,
    String? description,
    String? filePath,
    String? fileType,
    int? fileSize,
    bool? isFavorite,
    List<Tag>? tags,
  }) {
    return DocumentItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }
}

class NoteItem extends Item {
  final String content;

  const NoteItem({
    required String id,
    required String title,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isFavorite = false,
    List<Tag> tags = const [],
    required this.content,
  }) : super(
          id: id,
          type: ItemType.note,
          title: title,
          description: description,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isFavorite: isFavorite,
          tags: tags,
        );

  NoteItem copyWith({
    String? title,
    String? description,
    String? content,
    bool? isFavorite,
    List<Tag>? tags,
  }) {
    return NoteItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }
}
