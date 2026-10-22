import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_service.dart';
import 'sound_id.dart';

/// Plays a looping [sound] only while [child] is really on screen.
///
/// Tabs stay alive in the background and full-screen pages cover them, so
/// "built" does not mean "visible". Flutter switches tickers off for hidden
/// tabs and covered pages ([TickerMode]); that is the signal used here.
class AmbienceLoop extends ConsumerStatefulWidget {
  const AmbienceLoop({super.key, required this.sound, required this.child})
      : assert(sound == SoundId.ambienceSea || sound == SoundId.musicMain);

  final SoundId sound;
  final Widget child;

  @override
  ConsumerState<AmbienceLoop> createState() => _AmbienceLoopState();
}

class _AmbienceLoopState extends ConsumerState<AmbienceLoop> {
  late final AudioService _audio = ref.read(audioServiceProvider);
  bool? _visible;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible == _visible) return;
    _visible = visible;
    if (visible) {
      _audio.startLoop(widget.sound);
    } else {
      _audio.stopLoop(widget.sound.channel);
    }
  }

  @override
  void dispose() {
    _audio.stopLoop(widget.sound.channel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
