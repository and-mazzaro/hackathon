import '../../domain/models/pet_state.dart';
import '../../domain/rules/pet_rules.dart';
import '../../l10n/app_localizations.dart';

/// Italian names for pet stages and moods (UI layer only).
extension PetStageLabels on PetStage {
  String label(AppLocalizations l10n) => switch (this) {
        PetStage.egg => l10n.petStageEgg,
        PetStage.baby => l10n.petStageBaby,
        PetStage.young => l10n.petStageYoung,
        PetStage.adult => l10n.petStageAdult,
      };
}

extension PetMoodLabels on PetMood {
  String label(AppLocalizations l10n) => switch (this) {
        PetMood.happy => l10n.petMoodHappy,
        PetMood.ok => l10n.petMoodOk,
        PetMood.sad => l10n.petMoodSad,
      };
}

/// The pet's display name ("Uovo misterioso" before hatching).
String petDisplayName(PetState pet, AppLocalizations l10n) =>
    pet.stage == PetStage.egg ? l10n.petEggName : (pet.name ?? defaultPetName);

/// What screen readers say about the pet: "Laiqua, Cucciolo, Di buon umore".
String petSemanticLabel(PetState pet, AppLocalizations l10n) =>
    l10n.petSemantics(
      petDisplayName(pet, l10n),
      pet.stage.label(l10n),
      moodOf(pet).label(l10n),
    );
