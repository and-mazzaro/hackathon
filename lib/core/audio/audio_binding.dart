import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/game_controller.dart';
import 'audio_service.dart';

/// Connects the [AudioService] to the rest of the app, once, at the top:
///
/// - the saved sound settings are applied as soon as they load and every
///   time they change (no restart needed);
/// - loops pause when the app goes to the background and come back when
///   it returns. Music only resumes if it was playing and is not muted;
///   short sounds are never replayed later.
class AudioBinding extends ConsumerStatefulWidget {
  const AudioBinding({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AudioBinding> createState() => _AudioBindingState();
}

class _AudioBindingState extends ConsumerState<AudioBinding> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => ref.read(audioServiceProvider).setForeground(false),
      onShow: () => ref.read(audioServiceProvider).setForeground(true),
    );
    ref.listenManual(
      gameControllerProvider.select((game) => game.value?.audio),
      (previous, audio) {
        if (audio != null) ref.read(audioServiceProvider).applySettings(audio);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
