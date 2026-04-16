/// Realistic mock data and images for Flutter UI development.
///
/// Initialize once before [runApp]:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Mokr.init();
///   runApp(const MyApp());
/// }
/// ```
///
/// Then access mock data anywhere — sync, no awaiting:
/// ```dart
/// final user = Mokr.user('profile_hero');
/// final post = Mokr.post('feed_0');
/// final img  = Mokr.image.meta('post_1', category: MokrCategory.food);
/// ```
library mokr;

export 'src/core/mokr_base.dart';
export 'src/data/models/cache_status.dart';
export 'src/data/models/mock_post.dart';
export 'src/data/models/mock_user.dart';
export 'src/data/models/mokr_image_meta.dart';
export 'src/images/image_namespace.dart' show MokrImageNamespace;
export 'src/images/mokr_image_provider.dart';
export 'src/namespaces/cache_namespace.dart' show MokrCache;
export 'src/namespaces/random_namespace.dart';
export 'src/namespaces/text_namespace.dart';
export 'src/slots/slot_namespace.dart';
export 'src/widgets/mokr_avatar.dart';
export 'src/widgets/mokr_feed_builder.dart';
export 'src/widgets/mokr_image.dart';
export 'src/widgets/mokr_post_builder.dart';
export 'src/widgets/mokr_post_card.dart';
export 'src/widgets/mokr_user_builder.dart';
export 'src/widgets/mokr_user_tile.dart';
