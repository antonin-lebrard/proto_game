// Copyright (c) 2015, Antonin Lebrard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library proto_game.example;

import 'dart:io';
import 'dart:async';

import 'package:proto_game/proto_game.dart';

class TestingIo extends LowLevelIo{
  void clear() {}
  Future<String> readLine() => new Future.value("");
  void removeChars(int nb) {}
  void writeLine(String line) {print(line);}
  void writeNewLine(String line) {}
  void writeString(String string) {}
  Future<String> presentChoices(List<String> choices) => new Future.value("");
}

main() {

  String json = new File('example/example.json').readAsStringSync();
  Game game = new GameDecoderJSON().readFromFormat(json, new TestingIo());

  Room start = game.player.plateau.rooms.firstWhere((Room elem) => elem.name_id == "start");
  Room test = game.player.plateau.rooms.firstWhere((Room elem) => elem.name_id == "test");
  Room test2 = game.player.plateau.rooms.firstWhere((Room elem) => elem.name_id == "test2");

  print(game.player.getFinalProperty("firstPropertyPlayer").getValue());
  print(game.player.getFinalProperty("firstPropertyPlayer").getValue());
  print(game.player.getFinalProperty("secondPropertyPlayer").getValue());

  new EventsManager().emitEvent(new MoveEvent(start, test));
  new EventsManager().emitEvent(new MoveEvent(start, test));
  new EventsManager().emitEvent(new MoveEvent(start, test2));

  new EventsManager().emitEvent(new MoveEvent(test, start));
  new EventsManager().emitEvent(new MoveEvent(test, test2));

  // true is -80
  new StoredOperation.fromString("globals.boolGl = (globals.numGl == 9)").applyOperation();
  StoredOperation so = new StoredOperation.fromString("globals.boolGl = -18 == -(globals.numGl + globals.numGl)");
  so.applyOperation();

  Text t = new Text.fromString(r"(if:globals.boolGl==true)[true](else:)[false], value of boolGl is ${globals.boolGl}");
  print(t.getWholeText());

  // meaningless line just to put breakpoint
  var x = 0;

  while(true) {
    print("You are in the room: ${game.player.plateau.currentRoom.displayName}");
    String line = stdin.readLineSync();
    String command = line.substring(0, line.indexOf(' '));
    if (command == "move"){
      String arg = line.substring(line.indexOf(' ') + 1, line.length);
      if (arg == "n" || arg == "north")
        game.player.plateau.move(Direction.NORTH);
      if (arg == "s" || arg == "south")
        game.player.plateau.move(Direction.SOUTH);
    }
  }
}