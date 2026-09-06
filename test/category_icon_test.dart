// Network-free unit tests for the program-category classification chain:
//   getCategory (lib/utils.dart) -> ProgramItem.classification
//   -> getImageForCategory (icon) and is*() predicates (lib/models/ProgramItem.dart)
//
// These lock the contract that the icon matcher and the is*() predicates are
// keyed to getCategory's output vocabulary, so a program rendered from fresh
// (network) data and one rendered from cache both resolve to the same category
// icon and gate. Run: flutter test test/category_icon_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tvcubana/models/ProgramItem.dart';
import 'package:tvcubana/utils.dart';

IconData iconFor(ProgramItem pitem) =>
    (getImageForCategory(pitem) as Icon).icon;

ProgramItem pitemFor(
        String title, String description, String descriptionLong) =>
    ProgramItem(
        'id',
        description,
        descriptionLong,
        '60',
        '2021-03-13',
        '2021-03-13',
        '2021-03-13',
        '20:00',
        '21:00',
        title,
        [getCategory('$title $description $descriptionLong')]);

void main() {
  group('getCategory classifies representative program descriptions', () {
    test('movie description -> filme', () {
      expect(getCategory('Cine Especial Película Cubana'), 'filme');
    });
    test('news description -> noticias', () {
      expect(getCategory('Noticiero de la noche'), 'noticias');
    });
    test('sports description -> deporte', () {
      expect(getCategory('Programa deportivo de beisbol'), 'deporte');
    });
    test('music description -> musical', () {
      expect(getCategory('Concierto de música cubana'), 'musical');
    });
    test('documentary description -> documental', () {
      expect(getCategory('Documental de la naturaleza'), 'documental');
    });
    test('education description -> educativo', () {
      expect(getCategory('Teleclase de matemática de 8vo grado'), 'educativo');
    });
  });

  group(
      'a ProgramItem built like the fresh path renders the category icon '
      'and satisfies the matching is*() predicate', () {
    test('movie -> movie icon and isMovie()', () {
      final p = pitemFor(
          'Cine Especial', 'Programa de cine', 'Película cubana de la semana');
      expect(iconFor(p), Icons.movie);
      expect(p.isMovie(), isTrue);
    });
    test('news -> mic icon and isNews()', () {
      final p = pitemFor('Noticiero de la noche', 'Noticiero',
          'Resumen de las noticias del dia');
      expect(iconFor(p), Icons.mic);
      expect(p.isNews(), isTrue);
    });
    test('sports -> accessibility icon and isSports()', () {
      final p =
          pitemFor('Programa deportivo', 'Deportes', 'Beisbol serie nacional');
      expect(iconFor(p), Icons.accessibility);
      expect(p.isSports(), isTrue);
    });
    test('music -> music_video icon and isMusic()', () {
      final p =
          pitemFor('Concierto de musica', 'Concierto', 'Música cubana en vivo');
      expect(iconFor(p), Icons.music_video);
      expect(p.isMusic(), isTrue);
    });
    test('documentary -> videocam icon and isDocumental()', () {
      final p = pitemFor(
          'Documental naturaleza', 'Documental', 'Ciencia de lo absurdo');
      expect(iconFor(p), Icons.videocam);
      expect(p.isDocumental(), isTrue);
    });
    test('education -> school icon and isEducation()', () {
      final p = pitemFor('Teleclase matematica', 'Programa educativo',
          'Matemática de 8vo grado');
      expect(iconFor(p), Icons.school);
      expect(p.isEducation(), isTrue);
    });
  });

  test('an unknown category renders the default live_tv icon', () {
    final p = ProgramItem('', '', '', '', '', '', '', '', '', '', ['---']);
    expect(iconFor(p), Icons.live_tv);
  });
}
