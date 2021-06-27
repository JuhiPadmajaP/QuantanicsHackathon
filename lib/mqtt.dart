import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';

class User {
  int switchNumber;
  int value;

  User(this.switchNumber, this.value);

  factory User.fromJson(dynamic json) {
    return User(json['switch Number'] as int, json['value'] as int);
  }

  @override
  String toString() {
    return '{ ${this.switchNumber}, ${this.value} }';
  }
}

Future<MqttClient> connect() async {
  MqttServerClient client =
      MqttServerClient.withPort('165.22.208.52', 'fluttermqtt', 1883);
  client.logging(on: true);
  client.onConnected = onConnected;
  client.onDisconnected = onDisconnected;

  client.onSubscribeFail = onSubscribeFail;

  final connMess = MqttConnectMessage()
      .withClientIdentifier("fluttermqtt")
      .authenticateAs("quantanics", "quantanics")
      .keepAliveFor(60)
      .withWillTopic('willtopic')
      .withWillMessage('My Will message')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMess;
  try {
    print('Connecting');
    await client.connect();
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }

  if (client.connectionStatus.state == MqttConnectionState.connected) {
    print('client connected');
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Received message:$payload from topic: ${c[0].topic}>');
    });

    client.published.listen((MqttPublishMessage message) {
      print('published');
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      print(
          'Published message: $payload to topic: ${message.variableHeader.topicName}');
      User user = User.fromJson(jsonDecode(payload));
      print(user);
    });
  } else {
    print(
        'client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    exit(-1);
  }
  client.subscribe("esp32/sw1/status", MqttQos.atLeastOnce);
  return client;
}

void onConnected() {
  print('Connected');
}

void onDisconnected() {
  print('Disconnected');
}

void onSubscribeFail(String topic) {
  print('Failed to subscribe topic: $topic');
}

void onUnsubscribed(String topic) {
  print('Unsubscribed topic: $topic');
}

void pong() {
  print('Ping response client callback invoked');
}
