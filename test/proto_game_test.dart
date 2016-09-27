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

    String json = new File('example/example.json').readAsStringSync();
    Game game = new GameDecoderJSON().readFromFormat(json, new TestingIo());

    Room start = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Start");
    Room test1 = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Test");
    Room test2 = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Test2");

    List<CustomizableEventConsumer> consumers = game.consumers.toList();

    test('decoding rooms', () {
      expect(start, isNot(null));
      expect(start.id, equals("start".hashCode));
      expect(start.description, equals("the starting room"));
      expect(start.name, equals("Start"));
      expect(start.objects.length, equals(1));
      expect(start.npcs.length, equals(1));
      expect(start.nextRooms.length, equals(2));
      expect(start.nextRooms, contains(Direction.NORTH));
      expect(start.nextRooms, contains(Direction.EAST));
      expect(start.nextRooms[Direction.NORTH], same(test1));
      expect(start.nextRooms[Direction.EAST], same(test2));
      expect(game.player.plateau.currentRoom, same(start));
    });
    test('decoding globals', (){
      expect(game.globals.length == 3, isTrue);
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "numGl").getType(), equals(int));
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "numGl").getValue(), equals(0));
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "stringGl").getType(), equals(String));
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "stringGl").getValue(), equals("test"));
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "boolGl").getType(), equals(bool));
      expect(game.globals.firstWhere((GlobalVariable g) => g.name == "boolGl").getValue(), isTrue);
    });
    test('decoding player', (){
      expect(game.player.name, equals("Sicile"));
      expect(game.player.inventory.length, equals(1));
      expect(game.player.inventory.first.name, equals("Bag"));
      expect(game.player.properties.length, equals(2));
      expect(game.player.properties, contains("firstPropertyPlayer"));
      expect(game.player.properties, contains("secondPropertyPlayer"));
    });
    test('decoding objects', (){
      expect(game.player.inventory.length, equals(1));
      expect(game.player.inventory.first.name, equals("Bag"));
      expect(game.player.inventory.first, same(game.getObjectByName("Bag")));
      expect(game.player.inventory.first, new isInstanceOf<WearableGameObject>());
      expect(game.player.inventory.first.description, equals("placeholder bag \ndescription"));
      expect(start.objects.length, equals(1));
      expect(start.objects.first.name, equals("object1"));
      expect(start.objects.first.description, equals("object1 \ndescription"));
      expect(start.objects.first, new isInstanceOf<ConsumableGameObject>());
      expect(test1.objects.length, equals(1));
      expect(test1.objects.first.name, equals("object2"));
      expect(test1.objects.first.description, equals("object2 \ndescription"));
      expect(test1.objects.first, new isInstanceOf<BaseGameObject>());
    });
    test('decoding events', (){
      expect(consumers.first.listenTo, equals(MoveEvent));
      expect(consumers.first.stopEvent, isTrue);
      expect(consumers.first.anyConditions, isFalse);
      expect(consumers.first.conditions.length, equals(2));
      expect(consumers.first.operations.length, equals(2));
      expect(consumers[1].listenTo, equals(MoveEvent));
      expect(consumers[1].stopEvent, isFalse);
      expect(consumers[1].anyConditions, isFalse);
      expect(consumers[1].conditions.length, equals(1));
      expect(consumers[1].operations.length, equals(3));
    });
    test('decoding conditions', (){
      expect(consumers.first.conditions.first.eventType, equals(MoveEvent));
      expect(consumers.first.conditions.first.operations.first, equals(Operation.EQUALS_TO));
      expect(consumers.first.conditions.first.operations.first.isAssign, isFalse);
      expect(consumers.first.conditions.first.operations.first.isCondition, isTrue);
      expect(consumers.first.conditions.first.operations.first.isOperand, isFalse);
      expect(consumers.first.conditions.first.variables.first, new isInstanceOf<ExpectedEventVariable>());
      ExpectedEventVariable v = consumers.first.conditions.first.variables.first;
      expect(v.name, equals("from"));
      expect(v.expectedType, equals(Room));
      expect(consumers.first.conditions.first.variables.toList()[1], new isInstanceOf<TempVariable>());
      TempVariable t = consumers.first.conditions.first.variables.toList()[1];
      expect(t.getType(), equals(Room));
      expect(t.getValue(), same(start));
      expect(consumers.first.conditions.toList()[1].operations.first, equals(Operation.EQUALS_TO));
      expect(consumers.first.conditions.toList()[1].operations.first.isAssign, isFalse);
      expect(consumers.first.conditions.toList()[1].operations.first.isCondition, isTrue);
      expect(consumers.first.conditions.toList()[1].operations.first.isOperand, isFalse);
      expect(consumers.first.conditions.toList()[1].variables.first, new isInstanceOf<ExpectedEventVariable>());
      v = consumers.first.conditions.toList()[1].variables.first;
      expect(v.name, equals("to"));
      expect(v.expectedType, equals(Room));
      expect(consumers.first.conditions.first.variables.toList()[1], new isInstanceOf<TempVariable>());
      t = consumers.first.conditions.toList()[1].variables.toList()[1];
      expect(t.getType(), equals(Room));
      expect(t.getValue(), same(test1));
    });
    test('decoding operations', (){
      expect(consumers.first.operations.first.operations.first, equals(Operation.PLUS_ASSIGN));
      expect(consumers.first.operations.first.operations.first.isAssign, isTrue);
      expect(consumers.first.operations.first.operations.first.isCondition, isFalse);
      expect(consumers.first.operations.first.operations.first.isOperand, isFalse);
      expect(consumers.first.operations.first.variables.first, same(game.globals.firstWhere((g)=>g.name=="numGl")));
      expect(consumers.first.operations.first.variables.toList()[1], new isInstanceOf<TempVariable<num>>());
      TempVariable t = consumers.first.operations.first.variables.toList()[1];
      expect(t.getValue(), equals(10));
      expect(t.getType(), equals(int));
      expect(consumers.first.operations.toList()[1].operations.first, equals(Operation.ASSIGN));
      expect(consumers.first.operations.toList()[1].operations.first.isAssign, isTrue);
      expect(consumers.first.operations.toList()[1].operations.first.isCondition, isFalse);
      expect(consumers.first.operations.toList()[1].operations.first.isOperand, isFalse);
      expect(consumers.first.operations.toList()[1].variables.first, same(game.globals.firstWhere((g)=>g.name=="stringGl")));
      expect(consumers.first.operations.toList()[1].variables.toList()[1], new isInstanceOf<TempVariable<String>>());
      t = consumers.first.operations.toList()[1].variables.toList()[1];
      expect(t.getValue(), equals("applying event consumer effect"));
      expect(t.getType(), equals(String));
    });
    test('decoding npcs', (){
      expect(start.npcs.length, equals(1));
      expect(start.npcs.first.name, equals("npc1"));
      expect(start.npcs.first, same(game.getNpcByName("npc1")));
      expect(start.npcs.first.properties, contains("npcProp1"));
      expect(start.npcs.first.properties, contains("npcProp2"));
      expect(start.npcs.first.getProperty("npcProp1").getValue(), equals(0));
      expect(start.npcs.first.getProperty("npcProp1").getType(), equals(int));
      expect(start.npcs.first.getProperty("npcProp2").getValue(), equals("nothing"));
      expect(start.npcs.first.getProperty("npcProp2").getType(), equals(String));
      expect(start.npcs.first.inventory.length, equals(1));
      expect(start.npcs.first.inventory.first, same(game.getObjectByName("Bag")));
      expect(start.npcs.first.interactions.length, equals(2));
      expect(start.npcs.first.interactions.first.actionName, equals("talk"));
      expect(start.npcs.first.interactions.last.actionName, equals("talk"));
      expect(start.npcs.first.interactions.first.conditions.length, equals(1));
      expect(start.npcs.first.interactions.first.operations.length, equals(1));
      expect(start.npcs.first.interactions.last.conditions.length, equals(1));
      expect(start.npcs.first.interactions.first.text, equals("Hello You !"));
      expect(start.npcs.first.interactions.last.text, equals("Welcome !"));
    });
  });
}
