import 'package:flutter/material.dart';

import 'routing/router.dart';
import 'theme/app_theme.dart';

class LumaApp extends StatelessWidget {
  const LumaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Luma',
    debugShowCheckedModeBanner: false,
    theme: appTheme,
    routerConfig: router,
  );
}
