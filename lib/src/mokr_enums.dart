/// Image category for [MokrImage], [MokrAvatar], and URL methods.
///
/// With Unsplash (opt-in), category maps to real keyword searches.
/// With Picsum (default), category varies the seed for visual differentiation.
enum MokrCategory {
  /// Portraits and face photos. Default for avatars.
  face,

  /// Landscapes and outdoor scenery.
  nature,

  /// Travel destinations and cityscapes.
  travel,

  /// Food, meals, and culinary photography.
  food,

  /// Fashion and style photography.
  fashion,

  /// Fitness, sport, and exercise.
  fitness,

  /// Art and creative photography.
  art,

  /// Technology, computers, and devices.
  technology,

  /// Office, workspace, and business.
  office,

  // ignore: constant_identifier_names
  /// Abstract textures and patterns. (Trailing _ avoids Dart keyword conflict.)
  abstract_,

  /// Products and lifestyle photography.
  product,

  /// Interiors and home decor.
  interior,

  /// Architecture and buildings.
  architecture,

  /// Cars and automotive photography.
  automotive,

  /// Pets and animals.
  pets,
}

extension MokrCategoryKeyword on MokrCategory {
  /// The keyword used for URL construction and API queries.
  /// Strips the trailing underscore from [abstract_].
  String get keyword {
    switch (this) {
      case MokrCategory.abstract_:
        return 'abstract';
      default:
        return name;
    }
  }

  /// Multi-keyword string for Unsplash query (comma-separated).
  String get unsplashQuery {
    switch (this) {
      case MokrCategory.face:
        return 'face,portrait';
      case MokrCategory.nature:
        return 'nature,landscape';
      case MokrCategory.travel:
        return 'travel,city';
      case MokrCategory.food:
        return 'food,meal';
      case MokrCategory.fashion:
        return 'fashion,style';
      case MokrCategory.fitness:
        return 'fitness,sport';
      case MokrCategory.art:
        return 'art,creative';
      case MokrCategory.technology:
        return 'technology,computer';
      case MokrCategory.office:
        return 'office,workspace';
      case MokrCategory.abstract_:
        return 'abstract,texture';
      case MokrCategory.product:
        return 'product,lifestyle';
      case MokrCategory.interior:
        return 'interior,room';
      case MokrCategory.architecture:
        return 'architecture,building';
      case MokrCategory.automotive:
        return 'car,automotive';
      case MokrCategory.pets:
        return 'pets,animals';
    }
  }
}

/// Shape of [MokrAvatar].
enum MokrShape {
  /// Circular avatar (default).
  circle,

  /// Rounded rectangle avatar.
  rounded,

  /// Square avatar.
  square,
}
