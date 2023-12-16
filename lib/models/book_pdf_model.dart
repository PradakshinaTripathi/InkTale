class BooksPdf {
  String kind;
  int totalItems;
  List<Item> items;

  BooksPdf({
    required this.kind,
    required this.totalItems,
    required this.items,
  });

}

class Item {
  Kind kind;
  String id;
  String etag;
  String selfLink;
  VolumeInfo volumeInfo;
  SaleInfo saleInfo;
  AccessInfo accessInfo;

  Item({
    required this.kind,
    required this.id,
    required this.etag,
    required this.selfLink,
    required this.volumeInfo,
    required this.saleInfo,
    required this.accessInfo,
  });

}

class AccessInfo {
  Country country;
  Viewability viewability;
  bool embeddable;
  bool publicDomain;
  TextToSpeechPermission textToSpeechPermission;
  Epub epub;
  Epub pdf;
  String webReaderLink;
  AccessViewStatus accessViewStatus;
  bool quoteSharingAllowed;

  AccessInfo({
    required this.country,
    required this.viewability,
    required this.embeddable,
    required this.publicDomain,
    required this.textToSpeechPermission,
    required this.epub,
    required this.pdf,
    required this.webReaderLink,
    required this.accessViewStatus,
    required this.quoteSharingAllowed,
  });

}

enum AccessViewStatus {
  FULL_PUBLIC_DOMAIN
}

enum Country {
  IN
}

class Epub {
  bool isAvailable;
  String? downloadLink;

  Epub({
    required this.isAvailable,
    this.downloadLink,
  });

}

enum TextToSpeechPermission {
  ALLOWED
}

enum Viewability {
  ALL_PAGES
}

enum Kind {
  BOOKS_VOLUME
}

class SaleInfo {
  Country country;
  Saleability saleability;
  bool isEbook;
  String buyLink;

  SaleInfo({
    required this.country,
    required this.saleability,
    required this.isEbook,
    required this.buyLink,
  });

}

enum Saleability {
  FREE
}

class VolumeInfo {
  String title;
  List<String>? authors;
  String? publisher;
  String publishedDate;
  String description;
  List<IndustryIdentifier>? industryIdentifiers;
  ReadingModes? readingModes;
  int? pageCount;
  PrintType? printType;
  List<String> categories;
  String maturityRating;
  bool? allowAnonLogging;
  String? contentVersion;
  PanelizationSummary? panelizationSummary;
  ImageLinks imageLinks;
  String language;
  String? previewLink;
  String? infoLink;
  String? canonicalVolumeLink;
  double? averageRating;
  num? ratingsCount;
  String? subtitle;

  VolumeInfo({
    required this.title,
    this.authors,
    this.publisher,
    required this.publishedDate,
    required this.description,
    this.industryIdentifiers,
     this.readingModes,
     this.pageCount,
     this.printType,
    required this.categories,
    required this.maturityRating,
     this.allowAnonLogging,
     this.contentVersion,
     this.panelizationSummary,
    required this.imageLinks,
    required this.language,
     this.previewLink,
     this.infoLink,
     this.canonicalVolumeLink,
     this.averageRating,
     this.ratingsCount,
    this.subtitle,
  });

}

class ImageLinks {
  String smallThumbnail;
  String thumbnail;

  ImageLinks({
    required this.smallThumbnail,
    required this.thumbnail,
  });

}

class IndustryIdentifier {
  Type type;
  String identifier;

  IndustryIdentifier({
    required this.type,
    required this.identifier,
  });

}

enum Type {
  OTHER
}





class PanelizationSummary {
  bool containsEpubBubbles;
  bool containsImageBubbles;

  PanelizationSummary({
    required this.containsEpubBubbles,
    required this.containsImageBubbles,
  });

}

enum PrintType {
  BOOK
}

class ReadingModes {
  bool text;
  bool image;

  ReadingModes({
    required this.text,
    required this.image,
  });

}
