// Copyright (c) 2015, Antonin Lebrard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library proto_game.test;

import 'dart:io';
import 'package:proto_game/proto_game.dart';
import 'package:proto_game/src/condition/condition_entryPoint.dart';
import 'package:test/test.dart';

class TestingIo extends LowLevelIo{
  void clear() {}
  String readLine() => "";
  void removeChars(int nb) {}
  void writeLine(String line) {}
  void writeNewLine(String line) {}
  void writeString(String string) {}
}

void main() {

  group("decoding", (){

    Game game;
    Room start;
    Room test1;
    Room test2;

    List<CustomizableEventConsumer> consumers;

    setUp(() {
      String json = new File('example/example.json').readAsStringSync();
      game = new GameDecoderJSON().readFromFormat(json, new TestingIo());

      start = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Start");
      test1 = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Test");
      test2 = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Test2");

      consumers = game.consumers.toList();
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
      expect(start.nextRooms[Direction.EAST] == test2, isTrue);
      expect(game.player.plateau.currentRoom == start, isTrue);
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
      expect(game.player.properties.keys.contains("secondPropertyPlayer"), isTrue);
    });
    test('decoding objects', (){
      expect(game.player.inventory.length == 1, isTrue);
      expect(game.player.inventory.first.name == "Bag", isTrue);
      expect(game.player.inventory.first.runtimeType == WearableGameObject, isTrue);
      expect(game.player.inventory.first.description == "placeholder bag \n description", isTrue);
      expect(start.objects.length == 1, isTrue);
      expect(start.objects.first.name == "object1", isTrue);
      expect(start.objects.first.description == "object1 \n description", isTrue);
      expect(start.objects.first.runtimeType == ConsumableGameObject, isTrue);
      expect(test1.objects.length == 1, isTrue);
      expect(test1.objects.first.name == "object2", isTrue);
      expect(test1.objects.first.description == "object2 \n description", isTrue);
      expect(test1.objects.first.runtimeType == BaseGameObject, isTrue);
    });
    test('decoding events', (){
      expect(consumers.first.listenTo == MoveEvent, isTrue);
      expect(consumers.first.stopEvent, isTrue);
      expect(consumers.first.anyConditions, isFalse);
      expect(consumers.first.conditions.length == 2, isTrue);
      expect(consumers.first.operations.length == 2, isTrue);
      expect(consumers[1].listenTo == MoveEvent, isTrue);
      expect(consumers[1].stopEvent, isFalse);
      expect(consumers[1].anyConditions, isFalse);
      expect(consumers[1].conditions.length == 1, isTrue);
      expect(consumers[1].operations.length == 3, isTrue);
    });
    test('decoding conditions', (){
      expect(consumers.first.conditions.first.eventType == MoveEvent, isTrue);
      expect(consumers.first.conditions.first.operations.first == Operation.EQUALS_TO, isTrue);
      expect(consumers.first.conditions.first.operations.first.isAssign, isFalse);
      expect(consumers.first.conditions.first.operations.first.isCondition, isTrue);
      expect(consumers.first.conditions.first.operations.first.isOperand, isFalse);
      expect(consumers.first.conditions.first.variables.first.runtimeType == ExpectedEventVariable, isTrue);
      ExpectedEventVariable v = consumers.first.conditions.first.variables.first;
      expect(v.name == "from", isTrue);
      expect(v.expectedType == Room, isTrue);
      expect(consumers.first.conditions.first.variables.toList()[1].runtimeType == TempVariable, isTrue);
      TempVariable t = consumers.first.conditions.first.variables.toList()[1];
      expect(t.getType() == Room, isTrue);
      expect(t.getValue() == start, isTrue);
      expect(consumers.first.conditions.toList()[1].operations.first == Operation.EQUALS_TO, isTrue);
      expect(consumers.first.conditions.toList()[1].operations.first.isAssign, isFalse);
      expect(consumers.first.conditions.toList()[1].operations.first.isCondition, isTrue);
      expect(consumers.first.conditions.toList()[1].operations.first.isOperand, isFalse);
      expect(consumers.first.conditions.toList()[1].variables.first.runtimeType == ExpectedEventVariable, isTrue);
      v = consumers.first.conditions.toList()[1].variables.first;
      expect(v.name == "to", isTrue);
      expect(v.expectedType == Room, isTrue);
      expect(consumers.first.conditions.first.variables.toList()[1].runtimeType == TempVariable, isTrue);
      t = consumers.first.conditions.toList()[1].variables.toList()[1];
      expect(t.getType() == Room, isTrue);
      expect(t.getValue() == test1, isTrue);
    });
    test('decoding operations', (){
      expect(consumers.first.operations.first.operations.first == Operation.PLUS_ASSIGN, isTrue);
      expect(consumers.first.operations.first.operations.first.isAssign, isTrue);
      expect(consumers.first.operations.first.operations.first.isCondition, isFalse);
      expect(consumers.first.operations.first.operations.first.isOperand, isFalse);
      expect(consumers.first.operations.first.variables.first == game.globals.firstWhere((g)=>g.name=="numGl"), isTrue);
      expect(consumers.first.operations.first.variables.toList()[1].runtimeType.toString() == "TempVariable<num>", isTrue);
      TempVariable t = consumers.first.operations.first.variables.toList()[1];
      expect(t.getValue() == 10, isTrue);
      expect(t.getType() == int, isTrue);
      expect(consumers.first.operations.toList()[1].operations.first == Operation.ASSIGN, isTrue);
      expect(consumers.first.operations.toList()[1].operations.first.isAssign, isTrue);
      expect(consumers.first.operations.toList()[1].operations.first.isCondition, isFalse);
      expect(consumers.first.operations.toList()[1].operations.first.isOperand, isFalse);
      expect(consumers.first.operations.toList()[1].variables.first == game.globals.firstWhere((g)=>g.name=="stringGl"), isTrue);
      expect(consumers.first.operations.toList()[1].variables.toList()[1].runtimeType.toString() == "TempVariable<String>", isTrue);
      t = consumers.first.operations.toList()[1].variables.toList()[1];
      expect(t.getValue() == "applying event consumer effect", isTrue);
      expect(t.getType() == String, isTrue);
    });
  });
}
