// Copyright (c) 2015, Antonin Lebrard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library proto_game.test;

import 'dart:io';
import 'package:proto_game/proto_game.dart';
import 'package:test/test.dart';

void main() {
  group('Conditions Parsings', () {

    Game game;
    Room start;
    Room test1;
    Room test2;

    setUp(() {
      String json = new File('example/example.json').readAsStringSync();
      game = new GameDecoderJSON().readFromFormat(json);

      start = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Start");
      test1 = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Test");
      test2 = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Test2");
    });

    test('qsffqsf', () {
      expect(true, isTrue);
    });
  });
}
