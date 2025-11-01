class WordModel {
  final int id;
  final String word;
  final String phonetics;
  final String region;
  final String partOfSpeech;
  final String type;
  final String meaning;
  final String origin;
  final int status;
  final String? serial;
  final String? img;

  WordModel({
    required this.id,
    required this.word,
    required this.phonetics,
    required this.region,
    required this.partOfSpeech,
    required this.type,
    required this.meaning,
    required this.origin,
    required this.status,
    this.serial,
    this.img,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json["id"],
      word: json["word"],
      phonetics: json["phonetics"],
      region: json["region"],
      partOfSpeech: json["part_of_speech"],
      type: json["type"],
      meaning: json["meaning"],
      origin: json["origin"],
      status: json["status"],
      serial: json["serial"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "word": word,
      "phonetics": phonetics,
      "region": region,
      "part_of_speech": partOfSpeech,
      "type": type,
      "meaning": meaning,
      "origin": origin,
      "status": status,
      "serial": serial,
      "img": img,
    };
  }
}

class WordPreviewModel {
  final int id;
  final String word;
  final String phonetics;
  final String partOfSpeech;

  WordPreviewModel({
    required this.id,
    required this.word,
    required this.phonetics,
    required this.partOfSpeech,
  });

  factory WordPreviewModel.fromJson(Map<String, dynamic> json) {
    return WordPreviewModel(
      id: json["id"],
      word: json["word"],
      phonetics: json["phonetics"],
      partOfSpeech: json["part_of_speech"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "word": word,
      "phonetics": phonetics,
      "part_of_speech": partOfSpeech,
    };
  }
}

class PaginatedResult<T> {
  final int total;
  final List<T> items;
  final int currentPage;
  final int limit;
  final bool hasMore;

  PaginatedResult({
    required this.total,
    required this.items,
    required this.currentPage,
    required this.limit,
    required this.hasMore,
  });
}
