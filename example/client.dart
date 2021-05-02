import 'dart:isolate';

import 'package:rt0s_mqtt/rt0s_mqtt.dart';
import 'package:args/args.dart';
import 'dart:io';

void cli(SendPort sendPort) {
  while (true) {
    sendPort.send(stdin.readLineSync());
  }
}

main(List<String> args) async {
  var parser = ArgParser();
  parser.addOption('id', defaultsTo: "test");
  parser.addOption('host', defaultsTo: "mqtt.rt0s.com");
  var opts = parser.parse(args);
  print(["MQTTapi Example", opts['id'], opts['host']]);
  MQTTapi mq = new MQTTapi(
    id: opts['id'],
    descr: "test",
    host: opts['host'],
    user: "eila",
    pw: "zilakka",
    ping: 20,
  );

  mq.registerAPI("pingg", "pingg", [], (Map<String, dynamic> args) {
    print(["API REQ:", args]);
    return {"oujee": "pumg"};
  });

  mq.connect();
  ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(cli, receivePort.sendPort);
  receivePort.listen((data) async {
    List<String> args = data.split(" ");
    if (args.length > 1) {
      var target = args.removeAt(0);
      Map<String, dynamic> obj = {
        "args": args,
      };
      var ret = await mq.req(target, obj);
      print(["reply: ", ret['reply']]);
    } else
      print("??");
  });
}
