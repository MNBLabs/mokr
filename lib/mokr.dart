/// Realistic mock data and images for Flutter UI development.
///
/// This is the only file you need to import:
/// ```dart
/// import 'package:mokr/mokr.dart';
/// ```
///
/// ## Quick Start
///
/// ```dart
/// void main() async {
///   await Mokr.init();
///   runApp(MyApp());
/// }
///
/// // In your widget:
/// Text(Mokr.user('profile_hero').name)
/// MokrAvatar(seed: 'profile_hero', size: 48)
/// MokrPostCard(slot: 'feed_card_0')
/// ```
///
/// ## The Four Modes
///
/// | Mode | Usage | Behaviour |
/// |---|---|---|
/// | Deterministic | `Mokr.user('seed')` | Same result always |
/// | Slot | `Mokr.randomUser(slot: 'card_1')` | Random once, then stable |
/// | Pinned slot | `Mokr.randomUser(slot: 'hero', pin: true)` | Stable, survives clearAll |
/// | Fresh random | `Mokr.randomUser()` | Different every call |
///
/// See [Mokr.init] for setup and the README for the graduation flow.
library mokr;

export 'src/data/models/mock_post.dart';
export 'src/data/models/mock_user.dart';
export 'src/images/mokr_image_provider.dart';
export 'src/mokr_enums.dart';
export 'src/mokr_public.dart';
export 'src/widgets/mokr_avatar.dart';
export 'src/widgets/mokr_image.dart';
export 'src/widgets/mokr_post_card.dart';
export 'src/widgets/mokr_user_tile.dart';
// MokrShimmer is intentionally NOT exported — internal only.
