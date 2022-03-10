// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:pinball/theme/theme.dart';
import 'package:pinball_theme/pinball_theme.dart';

import '../../helpers/helpers.dart';

void main() {
  late ThemeCubit themeCubit;

  setUp(() {
    themeCubit = MockThemeCubit();
    whenListen(
      themeCubit,
      const Stream<ThemeState>.empty(),
      initialState: const ThemeState.initial(),
    );
  });

  group('CharacterSelectionPage', () {
    testWidgets('renders CharacterSelectionView', (tester) async {
      await tester.pumpApp(
        CharacterSelectionPage(),
        themeCubit: themeCubit,
      );
      expect(find.byType(CharacterSelectionView), findsOneWidget);
    });

    testWidgets('route returns a valid navigation route', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push<void>(CharacterSelectionPage.route());
                },
                child: Text('Tap me'),
              );
            },
          ),
        ),
        themeCubit: themeCubit,
      );

      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      expect(find.byType(CharacterSelectionPage), findsOneWidget);
    });
  });

  group('CharacterSelectionView', () {
    testWidgets('renders correctly', (tester) async {
      const titleText = 'Choose your character!';
      await tester.pumpApp(
        CharacterSelectionView(),
        themeCubit: themeCubit,
      );

      expect(find.text(titleText), findsOneWidget);
      expect(find.byType(CharacterImageButton), findsNWidgets(4));
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('calls characterSelected when a character image is tapped',
        (tester) async {
      const sparkyButtonKey = Key('characterSelectionPage_sparkyButton');

      await tester.pumpApp(
        CharacterSelectionView(),
        themeCubit: themeCubit,
      );

      await tester.tap(find.byKey(sparkyButtonKey));

      verify(() => themeCubit.characterSelected(SparkyTheme())).called(1);
    });

    testWidgets('navigates to PinballGamePage when start is tapped',
        (tester) async {
      final navigator = MockNavigator();
      when(() => navigator.push<void>(any())).thenAnswer((_) async {});

      await tester.pumpApp(
        CharacterSelectionView(),
        themeCubit: themeCubit,
        navigator: navigator,
      );
      await tester.ensureVisible(find.byType(TextButton));
      await tester.tap(find.byType(TextButton));

      verify(() => navigator.push<void>(any())).called(1);
    });
  });

  testWidgets('CharacterImageButton renders correctly', (tester) async {
    await tester.pumpApp(
      CharacterImageButton(DashTheme()),
      themeCubit: themeCubit,
    );

    expect(find.byType(Image), findsOneWidget);
  });
}