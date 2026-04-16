import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_story_datasource.dart';
import 'package:n42_chat/src/data/repositories/story_repository_impl.dart';

class _MockMatrixStoryDataSource extends Mock
    implements MatrixStoryDataSource {}

class _MockPreferencesDataSource extends Mock
    implements PreferencesDataSource {}

void main() {
  late StoryRepositoryImpl repository;
  late _MockMatrixStoryDataSource mockStoryDataSource;
  late _MockPreferencesDataSource mockPreferencesDataSource;

  setUp(() {
    mockStoryDataSource = _MockMatrixStoryDataSource();
    mockPreferencesDataSource = _MockPreferencesDataSource();
    repository = StoryRepositoryImpl(
      mockStoryDataSource,
      mockPreferencesDataSource,
    );
  });

  test(
    'deleteStory falls back to deleting event id directly when local lookup misses',
    () async {
      when(
        () => mockStoryDataSource.getStories(),
      ).thenAnswer((_) async => const <Map<String, dynamic>>[]);
      when(
        () => mockStoryDataSource.deleteStory(r'$event:server'),
      ).thenAnswer((_) async {});

      await repository.deleteStory(r'$event:server');

      verify(() => mockStoryDataSource.deleteStory(r'$event:server')).called(1);
    },
  );
}
