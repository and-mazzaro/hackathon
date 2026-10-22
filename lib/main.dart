import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  runApp(
    // ProviderScope holds the state of every Riverpod provider in the app.
    ProviderScope(
      // Riverpod retries failed providers by default. Reading a broken save
      // again will not fix it, so we show the error screen instead.
      retry: (retryCount, error) => null,
      child: const EcoQuestApp(),
    ),
  );
}
