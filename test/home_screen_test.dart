import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/data/save/save_repository.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/player_progress.dart';
// GameState is still used by _FailingRepository below.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('Home shows the saved level, XP and balances', (tester) async {
    final saved = onboardedState().copyWith(
      progress: const PlayerProgress(totalXp: 260, coins: 1250, tickets: 4),
    );
    await pumpEcoQuestApp(tester,
        repository: InMemorySaveRepository(saved));

    expect(find.text('Livello 3'), findsOneWidget);
    expect(find.text('10/200'), findsOneWidget);
    expect(find.text('1.250'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('the debug reward button updates Home and the save',
      (tester) async {
    final repository = InMemorySaveRepository(onboardedState());
    await pumpEcoQuestApp(tester, repository: repository);

    final button = find.text('Ricompensa di prova (solo debug)');
    await scrollTo(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(repository.saved!.progress.coins, 15);
    expect(repository.saved!.progress.totalXp, 30);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.text('30/100'), findsOneWidget);
  });

  testWidgets('a broken save shows the error with both choices',
      (tester) async {
    await pumpEcoQuestApp(tester,
        repository: _FailingRepository(const SaveCorruptedException('test')));

    expect(find.text('Non riesco a leggere i tuoi progressi'), findsOneWidget);
    expect(find.text('Riprova'), findsOneWidget);
    expect(find.text('Ricomincia da capo'), findsOneWidget);

    await tester.tap(find.text('Ricomincia da capo'));
    await tester.pumpAndSettle();
    // A fresh game starts with onboarding.
    expect(find.text('Ti diamo il benvenuto in EcoQuest!'), findsOneWidget);
  });

  testWidgets('a save from a newer app cannot be overwritten from the UI',
      (tester) async {
    await pumpEcoQuestApp(tester,
        repository: _FailingRepository(const SaveFromNewerAppException(9)));

    expect(find.textContaining('versione più recente'), findsOneWidget);
    expect(find.text('Ricomincia da capo'), findsNothing);
  });
}

class _FailingRepository implements SaveRepository {
  _FailingRepository(this.error);

  final SaveException error;
  GameState? saved;

  @override
  Future<GameState?> load() async => throw error;

  @override
  Future<void> save(GameState state) async => saved = state;
}
