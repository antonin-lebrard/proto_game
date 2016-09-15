// Copyright (c) 2015, Antonin Lebrard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library proto_game.test;

import 'dart:io';
import 'package:proto_game/proto_game.dart';
import 'package:test/test.dart';

void main() {

  group("decoding", (){

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

    test('decoding rooms', () {
      expect(start != null, isTrue);
      expect(start.id == "start".hashCode, isTrue);
      expect(start.description == "the starting room", isTrue);
      expect(start.name == "Start", isTrue);
      expect(start.objects.length == 1, isTrue);
      expect(start.nextRooms.length == 2, isTrue);
      expect(start.nextRooms.containsKey(Direction.NORTH), isTrue);
      expect(start.nextRooms.containsKey(Direction.EAST), isTrue);
      expect(start.nextRooms[Direction.NORTH] == test1, isTrue);
    });
    test('decoding globals', (){
      expect(game.globals.length == 3, isTrue);
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "numGl").getType() == num, isTrue);
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "numGl").getValue() == 0, isTrue);
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "stringGl").getType() == String, isTrue);
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "stringGl").getValue() == "test", isTrue);
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "boolGl").getType() == bool, isTrue);
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "boolGl").getValue() == true, isTrue);
    });
    test('decoding player', (){
      expect(game.player.name == "Sicile", isTrue);
      expect(game.player.inventory.length == 1, isTrue);
      expect(game.player.inventory.first.name == "Bag", isTrue);
      expect(game.player.properties.length == 2, isTrue);
      expect(game.player.properties.keys.contains("firstPropertyPlayer"), isTrue);
    });
  });
}
