import 'package:flutter_test/flutter_test.dart';
import 'package:tvcubana/models/ProgramItem.dart';
import 'package:tvcubana/utils.dart';

void main() {
  group('getTheCurrentAndNextProgram', () {
    test('should return the correct program when time is in HH:mm format', () {
      final pitems = [
        ProgramItem(
          dateStart: '2023-10-27',
          timeStart: '10:00',
          dateEnd: '2023-10-27',
          timeEnd: '11:00',
          title: 'Program 1',
          classification: [],
        ),
        ProgramItem(
          dateStart: '2023-10-27',
          timeStart: '11:00',
          dateEnd: '2023-10-27',
          timeEnd: '12:00',
          title: 'Program 2',
          classification: [],
        ),
      ];

      final now = DateTime.parse('2023-10-27 10:30:00');
      final result = getTheCurrentAndNextProgram(pitems, now);
      expect(result[0]?.title, 'Program 1');
      expect(result[1]?.title, 'Program 2');
    });

    test('should return the correct program at midnight', () {
      final pitems = [
        ProgramItem(
          dateStart: '2023-10-27',
          timeStart: '23:00:00',
          dateEnd: '2023-10-28',
          timeEnd: '01:00:00',
          title: 'Late Night Program',
          classification: [],
        ),
        ProgramItem(
          dateStart: '2023-10-28',
          timeStart: '01:00:00',
          dateEnd: '2023-10-28',
          timeEnd: '02:00:00',
          title: 'Early Morning Program',
          classification: [],
        ),
      ];

      // Time is 00:30 on the 28th
      final now = DateTime.parse('2023-10-28 00:30:00');
      final result = getTheCurrentAndNextProgram(pitems, now);
      expect(result[0]?.title, 'Late Night Program');
      expect(result[1]?.title, 'Early Morning Program');
    });

    test('should return null when no program is currently running', () {
      final pitems = [
        ProgramItem(
          dateStart: '2023-10-27',
          timeStart: '10:00:00',
          dateEnd: '2023-10-27',
          timeEnd: '11:00:00',
          title: 'Program 1',
          classification: [],
        ),
      ];

      final now = DateTime.parse('2023-10-27 12:00:00');
      final result = getTheCurrentAndNextProgram(pitems, now);
      expect(result[0], isNull);
      expect(result[1], isNull);
    });

    test('should return next program even if current is last of the day', () {
      final pitems = [
        ProgramItem(
          dateStart: '2023-10-27',
          timeStart: '23:00',
          dateEnd: '2023-10-27',
          timeEnd: '23:59',
          title: 'Last Program',
          classification: [],
        ),
        ProgramItem(
          dateStart: '2023-10-28',
          timeStart: '00:00',
          dateEnd: '2023-10-28',
          timeEnd: '01:00',
          title: 'First Program of Next Day',
          classification: [],
        ),
      ];

      final now = DateTime.parse('2023-10-27 23:30:00');
      final result = getTheCurrentAndNextProgram(pitems, now);
      expect(result[0]?.title, 'Last Program');
      expect(result[1]?.title, 'First Program of Next Day');
    });
  });
}
