// ignore_for_file: cascade_invocations

import 'package:bloc_test/bloc_test.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinball/game/game.dart';
import 'package:pinball_audio/pinball_audio.dart';
import 'package:pinball_components/pinball_components.dart';
import 'package:pinball_flame/pinball_flame.dart';

import '../../helpers/helpers.dart';

class _TestBodyComponent extends BodyComponent {
  @override
  Body createBody() => world.createBody(BodyDef());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final assets = [
    Assets.images.score.fiveThousand.keyName,
    Assets.images.score.twentyThousand.keyName,
    Assets.images.score.twoHundredThousand.keyName,
    Assets.images.score.oneMillion.keyName,
  ];

  group('ScoringBehavior', () {
    group('beginContact', () {
      late GameBloc bloc;
      late PinballAudio audio;
      late Ball ball;
      late BodyComponent parent;

      setUp(() {
        audio = MockPinballAudio();

        ball = MockBall();
        final ballBody = MockBody();
        when(() => ball.body).thenReturn(ballBody);
        when(() => ballBody.position).thenReturn(Vector2.all(4));

        parent = _TestBodyComponent();
      });

      final flameBlocTester = FlameBlocTester<EmptyPinballTestGame, GameBloc>(
        gameBuilder: () => EmptyPinballTestGame(
          audio: audio,
        ),
        blocBuilder: () {
          bloc = MockGameBloc();
          const state = GameState(
            score: 0,
            multiplier: 1,
            rounds: 3,
            bonusHistory: [],
          );
          whenListen(bloc, Stream.value(state), initialState: state);
          return bloc;
        },
        assets: assets,
      );

      flameBlocTester.testGameWidget(
        'emits Scored event with points',
        setUp: (game, tester) async {
          const points = Points.oneMillion;
          final scoringBehavior = ScoringBehavior(points: points);
          await parent.add(scoringBehavior);
          final canvas = ZCanvasComponent(children: [parent]);
          await game.ensureAdd(canvas);

          scoringBehavior.beginContact(ball, MockContact());

          verify(
            () => bloc.add(
              Scored(points: points.value),
            ),
          ).called(1);
        },
      );

      flameBlocTester.testGameWidget(
        'plays score sound',
        setUp: (game, tester) async {
          final scoringBehavior = ScoringBehavior(points: Points.oneMillion);
          await parent.add(scoringBehavior);
          final canvas = ZCanvasComponent(children: [parent]);
          await game.ensureAdd(canvas);

          scoringBehavior.beginContact(ball, MockContact());

          verify(audio.score).called(1);
        },
      );

      flameBlocTester.testGameWidget(
        "adds a ScoreComponent at Ball's position with points",
        setUp: (game, tester) async {
          const points = Points.oneMillion;
          final scoringBehavior = ScoringBehavior(points: points);
          await parent.add(scoringBehavior);
          final canvas = ZCanvasComponent(children: [parent]);
          await game.ensureAdd(canvas);

          scoringBehavior.beginContact(ball, MockContact());
          await game.ready();

          final scoreText = game.descendants().whereType<ScoreComponent>();
          expect(scoreText.length, equals(1));
          expect(
            scoreText.first.points,
            equals(points),
          );
          expect(
            scoreText.first.position,
            equals(ball.body.position),
          );
        },
      );
    });
  });
}