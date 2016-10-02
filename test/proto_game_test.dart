// Copyright (c) 2015, Antonin Lebrard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library proto_game.test;

import 'dart:async';
import 'dart:io';
import 'package:proto_game/proto_game.dart';
import 'package:proto_game/src/condition/condition_entryPoint.dart';
import 'package:test/test.dart';

class TestingIo extends LowLevelIo{
  void clear() {}
  Future<String> readLine() => new Future.value("");
  void removeChars(int nb) {}
  void writeLine(String line) {}
  void writeNewLine(String line) {}
  void writeString(String string) {}
  Future<String> presentChoices(List<String> choices) => new Future.value("");
}

void main() {

  group("decoding", (){

    String json = new File('example/example.json').readAsStringSync();
    Game game = new GameDecoderJSON().readFromFormat(json, new TestingIo());

    Room start = game.player.plateau.rooms.firstWhere((Room elem) => elem.name_id == "start");
    Room test1 = game.player.plateau.rooms.firstWhere((Room elem) => elem.name_id == "test");
    Room test2 = game.player.plateau.rooms.firstWhere((Room elem) => elem.name_id == "test2");

    List<CustomizableEventConsumer> consumers = game.consumers.toList();

    test('decoding rooms', () {
      expect(start, isNot(null));
      expect(start.name_id, equals("start"));
      expect(start.description, equals("the starting room"));
      expect(start.displayName, equals("Start"));
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
      expect(game.player.inventory.first.name_id, equals("bag"));
      expect(game.player.properties.length, equals(2));
      expect(game.player.properties, contains("firstPropertyPlayer"));
      expect(game.player.properties, contains("secondPropertyPlayer"));
    });
    test('decoding objects', (){
      expect(game.player.inventory.length, equals(1));
      expect(game.player.inventory.first.name_id, equals("bag"));
      expect(game.player.inventory.first, same(game.getObjectById("bag")));
      expect(game.player.inventory.first, new isInstanceOf<WearableGameObject>());
      expect(game.player.inventory.first.description, equals("placeholder bag \ndescription"));
      expect(start.objects.length, equals(1));
      expect(start.objects.first.name_id, equals("object1"));
      expect(start.objects.first.displayName, equals("nameObject1"));
      expect(start.objects.first.description, equals("object1 \ndescription"));
      expect(start.objects.first, new isInstanceOf<ConsumableGameObject>());
      expect(test1.objects.length, equals(1));
      expect(test1.objects.first.name_id, equals("object2"));
      expect(test1.objects.first.displayName, equals("nameObject2"));
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
      expect(start.npcs.first.name_id, equals("npc1"));
      expect(start.npcs.first, same(game.getNpcById("npc1")));
      expect(start.npcs.first.properties, contains("npcProp1"));
      expect(start.npcs.first.properties, contains("npcProp2"));
      expect(start.npcs.first.getProperty("npcProp1").getValue(), equals(0));
      expect(start.npcs.first.getProperty("npcProp1").getType(), equals(int));
      expect(start.npcs.first.getProperty("npcProp2").getValue(), equals("nothing"));
      expect(start.npcs.first.getProperty("npcProp2").getType(), equals(String));
      expect(start.npcs.first.inventory.length, equals(1));
      expect(start.npcs.first.inventory.first, same(game.getObjectById("bag")));
      expect(start.npcs.first.interactions.length, equals(2));
      expect(start.npcs.first.interactions.first.actionName, equals("talk"));
      expect(start.npcs.first.interactions.last.actionName, equals("talk"));
      expect(start.npcs.first.interactions.first.conditions.length, equals(1));
      expect(start.npcs.first.interactions.first.operations.length, equals(1));
      expect(start.npcs.first.interactions.last.conditions.length, equals(1));
      expect(start.npcs.first.interactions.first.text, equals("Hello You !"));
      expect(start.npcs.first.interactions.last.text, equals("Welcome !"));
    });
    test('decoding interactionChoices', (){
      expect(game.interactionChoicesStorage.length, equals(3));
      InteractionChoice interactionChoice = game.getInteractionChoiceById('choices1');
      expect(interactionChoice, isNotNull);
      expect(interactionChoice.id, equals('choices1'));
      expect(interactionChoice.choices.length, equals(3));
      expect(interactionChoice.choices.first.name, equals('choice1'));
      expect(interactionChoice.choices.first.text, equals('choice1'));
      expect(interactionChoice.choices.first.operations.length, equals(2));
      expect(interactionChoice.choices.last.name, equals('Cancel'));
      interactionChoice = game.getInteractionChoiceById('choices2');
      expect(interactionChoice, isNotNull);
      expect(interactionChoice.choices.length, equals(1));
    });
  });

  group("fonctional testing", (){
    test("operation/condition", (){
      String json = '''
      {
        "game": {
          "globals": [
            {"name": "numGl", "type": "num", "value": 0 },
            {"name": "stringGl", "type": "string", "value": "test" },
            {"name": "boolGl", "type": "bool", "value": true }
          ]
        }
      }
      ''';
      Game game = new GameDecoderJSON().readFromFormat(json, new TestingIo());
      GlobalVariable numGl = game.globals.firstWhere((GlobalVariable g) => g.name == "numGl");
      GlobalVariable strGl = game.globals.firstWhere((GlobalVariable g) => g.name == "stringGl");
      GlobalVariable boolGl = game.globals.firstWhere((GlobalVariable g) => g.name == "boolGl");

      new StoredOperation.fromString("globals.numGl = 1 + 1").applyOperation();
      expect(numGl.getValue(), equals(2));

      new StoredOperation.fromString("globals.numGl += 1").applyOperation();
      expect(numGl.getValue(), equals(3));

      new StoredOperation.fromString("globals.numGl -= 1").applyOperation();
      expect(numGl.getValue(), equals(2));

      new StoredOperation.fromString("globals.numGl = 1 - 1").applyOperation();
      expect(numGl.getValue(), equals(0));

      new StoredOperation.fromString("globals.numGl = 9 / 3").applyOperation();
      expect(numGl.getValue(), equals(3));

      new StoredOperation.fromString("globals.numGl /= 3").applyOperation();
      expect(numGl.getValue(), equals(1));

      new StoredOperation.fromString("globals.numGl = 3 * 3").applyOperation();
      expect(numGl.getValue(), equals(9));

      new StoredOperation.fromString("globals.numGl *= 2").applyOperation();
      expect(numGl.getValue(), equals(18));

      new StoredOperation.fromString("globals.numGl = 8 % 3").applyOperation();
      expect(numGl.getValue(), equals(2));

      new StoredOperation.fromString("globals.numGl %= 2").applyOperation();
      expect(numGl.getValue(), equals(0));

      new StoredOperation.fromString("globals.numGl = true ? 3 : 8").applyOperation();
      expect(numGl.getValue(), equals(3));

      new StoredOperation.fromString("globals.numGl = false ? 3 : 8").applyOperation();
      expect(numGl.getValue(), equals(8));

      new StoredOperation.fromString("globals.boolGl = globals.numGl < 9").applyOperation();
      expect(boolGl.getValue(), isTrue);

      new StoredOperation.fromString("globals.boolGl = globals.numGl < 8").applyOperation();
      expect(boolGl.getValue(), isFalse);

      new StoredOperation.fromString("globals.boolGl = globals.numGl <= 8").applyOperation();
      expect(boolGl.getValue(), isTrue);

      new StoredOperation.fromString("globals.boolGl = globals.numGl <= 7").applyOperation();
      expect(boolGl.getValue(), isFalse);

      new StoredOperation.fromString("globals.boolGl = globals.numGl > 7").applyOperation();
      expect(boolGl.getValue(), isTrue);

      new StoredOperation.fromString("globals.boolGl = globals.numGl > 8").applyOperation();
      expect(boolGl.getValue(), isFalse);

      new StoredOperation.fromString("globals.boolGl = globals.numGl >= 8").applyOperation();
      expect(boolGl.getValue(), isTrue);

      new StoredOperation.fromString("globals.boolGl = globals.numGl >= 9").applyOperation();
      expect(boolGl.getValue(), isFalse);

      new StoredOperation.fromString("globals.boolGl = globals.numGl == 8").applyOperation();
      expect(boolGl.getValue(), isTrue);

      new StoredOperation.fromString("globals.boolGl = globals.numGl == 9").applyOperation();
      expect(boolGl.getValue(), isFalse);
    });
  });
}
