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
      expect(game.player.wearing.length, equals(1));
      expect(game.player.wearing.first.name_id, equals("bag"));
      expect(game.player.properties.length, equals(2));
      expect(game.player.properties, contains("firstPropertyPlayer"));
      expect(game.player.properties, contains("secondPropertyPlayer"));
    });
    test('decoding objects', (){
      expect(game.player.wearing.length, equals(1));
      expect(game.player.wearing.first.name_id, equals("bag"));
      expect(game.player.wearing.first, same(game.getObjectById("bag")));
      expect(game.player.wearing.first, new isInstanceOf<WearableGameObject>());
      expect(game.player.wearing.first.description, equals("placeholder bag \ndescription"));
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
      expect(consumers.first.conditions.first.wholeCondition[1], equals(Operation.EQUALS_TO));
      expect(consumers.first.conditions.first.wholeCondition[1].isAssign, isFalse);
      expect(consumers.first.conditions.first.wholeCondition[1].isCondition, isTrue);
      expect(consumers.first.conditions.first.wholeCondition[1].isOperand, isFalse);
      expect(consumers.first.conditions.first.wholeCondition.first, new isInstanceOf<ExpectedEventVariable>());
      ExpectedEventVariable v = consumers.first.conditions.first.wholeCondition.first;
      expect(v.nameParts[0], equals("from"));
      expect(v.expectedType, equals(Room));
      expect(consumers.first.conditions.first.wholeCondition[2], new isInstanceOf<TempVariable>());
      TempVariable t = consumers.first.conditions.first.wholeCondition[2];
      expect(t.getType(), equals(Room));
      expect(t.getValue(), same(start));
      expect(consumers.first.conditions[1].wholeCondition[1], equals(Operation.EQUALS_TO));
      expect(consumers.first.conditions[1].wholeCondition[1].isAssign, isFalse);
      expect(consumers.first.conditions[1].wholeCondition[1].isCondition, isTrue);
      expect(consumers.first.conditions[1].wholeCondition[1].isOperand, isFalse);
      expect(consumers.first.conditions[1].wholeCondition.first, new isInstanceOf<ExpectedEventVariable>());
      v = consumers.first.conditions[1].wholeCondition.first;
      expect(v.nameParts[0], equals("to"));
      expect(v.expectedType, equals(Room));
      expect(consumers.first.conditions[1].wholeCondition[2], new isInstanceOf<TempVariable>());
      t = consumers.first.conditions[1].wholeCondition[2];
      expect(t.getType(), equals(Room));
      expect(t.getValue(), same(test1));
    });
    test('decoding operations', (){
      expect(consumers.first.operations.first.wholeOperation[1], equals(Operation.PLUS_ASSIGN));
      expect(consumers.first.operations.first.wholeOperation[1].isAssign, isTrue);
      expect(consumers.first.operations.first.wholeOperation[1].isCondition, isFalse);
      expect(consumers.first.operations.first.wholeOperation[1].isOperand, isFalse);
      expect(consumers.first.operations.first.wholeOperation.first, same(game.globals.firstWhere((g)=>g.name=="numGl")));
      expect(consumers.first.operations.first.wholeOperation[2], new isInstanceOf<TempVariable<num>>());
      TempVariable t = consumers.first.operations.first.wholeOperation[2];
      expect(t.getValue(), equals(10));
      expect(t.getType(), equals(int));
      expect(consumers.first.operations[1].wholeOperation[1], equals(Operation.ASSIGN));
      expect(consumers.first.operations[1].wholeOperation[1].isAssign, isTrue);
      expect(consumers.first.operations[1].wholeOperation[1].isCondition, isFalse);
      expect(consumers.first.operations[1].wholeOperation[1].isOperand, isFalse);
      expect(consumers.first.operations[1].wholeOperation.first, same(game.globals.firstWhere((g)=>g.name=="stringGl")));
      expect(consumers.first.operations[1].wholeOperation[2], new isInstanceOf<TempVariable<String>>());
      t = consumers.first.operations[1].wholeOperation[2];
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
      expect(start.npcs.first.interactions.first.text.getWholeText(), equals("Hello You !"));
      expect(start.npcs.first.interactions.last.text.getWholeText(), equals("Welcome !"));
    });
    test('decoding interactionChoices', (){
      expect(game.interactionChoicesStorage.length, equals(3));
      InteractionChoice interactionChoice = game.getInteractionChoiceById('choices1');
      expect(interactionChoice, isNotNull);
      expect(interactionChoice.id, equals('choices1'));
      expect(interactionChoice.choices.length, equals(3));
      expect(interactionChoice.choices.first.name, equals('choice1'));
      expect(interactionChoice.choices.first.text.getWholeText(), equals('choice1'));
      expect(interactionChoice.choices.first.operations.length, equals(2));
      expect(interactionChoice.choices.last.name, equals('Cancel'));
      interactionChoice = game.getInteractionChoiceById('choices2');
      expect(interactionChoice, isNotNull);
      expect(interactionChoice.choices.length, equals(1));
    });
  });

  group("fonctional testing", (){
    test("operation/condition with spaces", (){
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

      new StoredOperation.fromString("globals.boolGl = (globals.numGl == 9)").applyOperation();
      expect(boolGl.getValue(), isFalse);

    });

    test("operation/condition without spaces", (){
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

      new StoredOperation.fromString("globals.numGl=1+1").applyOperation();
      expect(numGl.getValue(), equals(2));

      new StoredOperation.fromString("globals.numGl+=1").applyOperation();
      expect(numGl.getValue(), equals(3));

      new StoredOperation.fromString("globals.numGl-=1").applyOperation();
      expect(numGl.getValue(), equals(2));

      new StoredOperation.fromString("globals.numGl=1-1").applyOperation();
      expect(numGl.getValue(), equals(0));

      new StoredOperation.fromString("globals.numGl=9/3").applyOperation();
      expect(numGl.getValue(), equals(3));

      new StoredOperation.fromString("globals.numGl/=3").applyOperation();
      expect(numGl.getValue(), equals(1));

      new StoredOperation.fromString("globals.numGl=3*3").applyOperation();
      expect(numGl.getValue(), equals(9));

      new StoredOperation.fromString("globals.numGl*=2").applyOperation();
      expect(numGl.getValue(), equals(18));

      new StoredOperation.fromString("globals.numGl=8%3").applyOperation();
      expect(numGl.getValue(), equals(2));

      new StoredOperation.fromString("globals.numGl%=2").applyOperation();
      expect(numGl.getValue(), equals(0));

      new StoredOperation.fromString("globals.numGl=true?3:8").applyOperation();
      expect(numGl.getValue(), equals(3));

      new StoredOperation.fromString("globals.numGl=false?3:8").applyOperation();
      expect(numGl.getValue(), equals(8));

      new StoredOperation.fromString("globals.boolGl=globals.numGl<9").applyOperation();
      expect(boolGl.getValue(), isTrue);

      new StoredOperation.fromString("globals.boolGl=globals.numGl<8").applyOperation();
      expect(boolGl.getValue(), isFalse);

      new StoredOperation.fromString("globals.boolGl=globals.numGl<=8").applyOperation();
      expect(boolGl.getValue(), isTrue);

      new StoredOperation.fromString("globals.boolGl=globals.numGl<=7").applyOperation();
      expect(boolGl.getValue(), isFalse);

      new StoredOperation.fromString("globals.boolGl=globals.numGl>7").applyOperation();
      expect(boolGl.getValue(), isTrue);

      new StoredOperation.fromString("globals.boolGl=globals.numGl>8").applyOperation();
      expect(boolGl.getValue(), isFalse);

      new StoredOperation.fromString("globals.boolGl=globals.numGl>=8").applyOperation();
      expect(boolGl.getValue(), isTrue);

      new StoredOperation.fromString("globals.boolGl=globals.numGl>=9").applyOperation();
      expect(boolGl.getValue(), isFalse);

      new StoredOperation.fromString("globals.boolGl=globals.numGl==8").applyOperation();
      expect(boolGl.getValue(), isTrue);

      new StoredOperation.fromString("globals.boolGl=globals.numGl==9").applyOperation();
      expect(boolGl.getValue(), isFalse);

      new StoredOperation.fromString("globals.numGl+=-1")..applyOperation()..applyOperation();
      expect(numGl.getValue(), equals(6));

      // globals.numGl = - 6 + 6;
      new StoredOperation.fromString("globals.numGl=-globals.numGl+globals.numGl").applyOperation();
      expect(numGl.getValue(), equals(0));

      new StoredOperation.fromString("globals.numGl=9").applyOperation();
      expect(numGl.getValue(), equals(9));

      new StoredOperation.fromString("globals.boolGl = -18 == -(globals.numGl + globals.numGl)").applyOperation();
      expect(boolGl.getValue(), equals(true));

      new StoredOperation.fromString("globals.boolGl = globals.boolGl ? (globals.boolGl ? true : false) : false").applyOperation();
      expect(boolGl.getValue(), equals(true));

    });

    test("text", (){

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

      Text t = new Text.fromString("(if:globals.boolGl==true)[boolGl is true]\\n(else:)[boolGl is false]");
      expect(t.getWholeText(), equals("boolGl is true\\n"));

      t = new Text.fromString(r"stringGl is equal to ${globals.stringGl}");
      expect(t.getWholeText(), equals("stringGl is equal to test"));

      t = new Text.fromString(r"(if:globals.boolGl==true)[(if:globals.stringGl=='test')[(if:true==true)[true], test], boolGl is true](else:)[(if:true == true)[true], boolGl is false]");
      expect(t.getWholeText(), equals("true, test, boolGl is true"));

      t = new Text.fromString(r"(if:globals.boolGl==false)[(if:globals.stringGl=='test')[(if:true==true)[true], test], boolGl is true](else:)[(if:true == true)[true], boolGl is false]");
      expect(t.getWholeText(), equals("true, boolGl is false"));

    });

    test("expected variable resolving", (){

      String json = '''
      {
        "game": {
          "rooms": [
            {
              "id": "start", "name": "Start",
              "direction": {
                "north": "test"
              },
              "properties": [
                {"name": "numStart", "type": "num", "value": 0 },
                {"name": "boolStart", "type": "bool", "value": true }
              ]
            },
            {
              "id": "test", "name": "Test",
              "direction": {
                "south": "start"
              },
              "properties": [
                {"name": "stringTest", "type": "string", "value": "test" }
              ]
            }
          ],
          "events": [
            { "listenTo": "move",
              "stopEvent": true,
              "conditions": [
                "param.from.numStart == 0",
                "param.to.stringTest == 'test'",
                "param.from.boolStart == true"
              ],
              "apply": [
                "rooms.start.numStart = 1"
              ],
              "text": "this direction is blocked"
            }
          ]
        }
      }
      ''';

      Game game = new GameDecoderJSON().readFromFormat(json, new TestingIo());

      Room start = game.player.plateau.rooms.firstWhere((Room elem) => elem.name_id == "start");
      Room test = game.player.plateau.rooms.firstWhere((Room elem) => elem.name_id == "test");

      new EventsManager().emitEvent(new MoveEvent(start, test));
      expect(start.properties["numStart"].getValue(), equals(1));

    });
  });
}
