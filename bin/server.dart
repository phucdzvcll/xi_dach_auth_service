import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'db_controller.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..post("/createAccount", _createAccount)
  ..post("/signIn", _signIn);

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

final DBController dbController = DBController();

Future<Response> _createAccount(Request request) async {
  try {
    String content = await utf8.decodeStream(request.read());
    final json = jsonDecode(content);
    final String? userName = json['userName'];
    final String? password = json['password'];
    final message = await dbController.createAccount(userName, password);
    return Response.ok('$message\n');
  } catch (e) {
    return Response.badRequest(body: e is String ? e : "Something went wrong!");
  }
}

Future<Response> _signIn(Request request) async {
  try {
    String content = await utf8.decodeStream(request.read());
    final json = jsonDecode(content);
    final String? userName = json['userName'];
    final String? password = json['password'];
    final id = await dbController.signIn(userName, password);
    return Response.ok({"userName": userName, "ID": id});
  } catch (e) {
    return Response.badRequest(body: e is String ? e : "Something went wrong!");
  }
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse("8982");

  await dbController.init();

  final HttpServer server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
