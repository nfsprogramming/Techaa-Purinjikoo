import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';
import '../datasources/initial_content.dart';

class FlashcardRepository extends Notifier<List<Flashcard>> {
  @override
  List<Flashcard> build() {
    return InitialContent.getFlashcards();
  }

  void setMastery(String id, MasteryLevel level) {
    state = [
      for (final card in state)
        if (card.id == id) card.copyWith(mastery: level) else card,
    ];
  }

  void resetAll() {
    state = [
      for (final card in state) card.copyWith(mastery: MasteryLevel.none),
    ];
  }
}

final flashcardsProvider = NotifierProvider<FlashcardRepository, List<Flashcard>>(FlashcardRepository.new);
