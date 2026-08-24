import 'package:flutter_test/flutter_test.dart';
import 'package:techaa_purinjikoo_app/data/datasources/initial_content.dart';

void main() {
  group('Web Content Parity Audit Tests', () {
    test('verifies all 150 topics from web dataset are loaded', () {
      final topics = InitialContent.getTopics();
      expect(topics.length, equals(150), reason: 'Expected 150 topics matching web topics.js');

      // Verify IDs are unique
      final ids = topics.map((t) => t.id).toSet();
      expect(ids.length, equals(150), reason: 'All topic IDs must be unique');

      // Check first level topics
      expect(topics.any((t) => t.id == 'internet'), isTrue);
      expect(topics.any((t) => t.id == 'http-vs-https'), isTrue);
      expect(topics.any((t) => t.id == 'cookies-cache'), isTrue);

      // Verify all 7 levels are represented
      final levels = topics.map((t) => t.level).toSet();
      expect(levels, containsAll([1, 2, 3, 4, 5, 6, 7]));
    });

    test('verifies all 7 roadmap modules match web structure', () {
      final roadmap = InitialContent.getRoadmapNodes();
      expect(roadmap.length, equals(7));

      expect(roadmap[0].title, contains('Internet Basics'));
      expect(roadmap[1].title, contains('Web Development'));
      expect(roadmap[2].title, contains('Database Systems'));
      expect(roadmap[3].title, contains('Cloud Architecture'));
      expect(roadmap[4].title, contains('Modern DevTools'));
      expect(roadmap[5].title, contains('Cyber Security'));
      expect(roadmap[6].title, contains('AI & Innovation'));
    });

    test('verifies all 50 dictionary terms from web dataset are loaded', () {
      final terms = InitialContent.getDictionaryTerms();
      expect(terms.length, equals(50), reason: 'Expected 50 dictionary items matching web topics.js');

      expect(terms.any((t) => t.term == 'Frontend'), isTrue);
      expect(terms.any((t) => t.term == 'Backend'), isTrue);
      expect(terms.any((t) => t.term == 'API'), isTrue);
    });

    test('verifies quizzes have valid options and valid correctIndex bounds', () {
      final topics = InitialContent.getTopics();
      int quizCount = 0;
      for (final t in topics) {
        for (final q in t.quiz) {
          quizCount++;
          expect(q.options.isNotEmpty, isTrue, reason: 'Quiz in ${t.id} must have options');
          expect(q.correctIndex, greaterThanOrEqualTo(0));
          expect(q.correctIndex, lessThan(q.options.length), reason: 'correctIndex must be within options range for ${t.id}');
        }
      }
      expect(quizCount, greaterThanOrEqualTo(100));
    });

    test('verifies flashcards are generated from verified topics', () {
      final cards = InitialContent.getFlashcards();
      expect(cards.isNotEmpty, isTrue);
      expect(cards.length, greaterThanOrEqualTo(20));
      for (final card in cards) {
        expect(card.term.isNotEmpty, isTrue);
        expect(card.definition.isNotEmpty, isTrue);
      }
    });
  });
}
