import 'package:material_ui/material_ui.dart';

import '../assets/assets.gen.dart';

/// The app icon (the same "SR" artwork as the launcher icon), already rounded.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Solaris Record',
    child: Assets.images.appIcon.image(
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
    ),
  );
}
