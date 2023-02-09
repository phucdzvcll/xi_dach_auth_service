import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:uuid/uuid.dart';

class DBController {
  late MySqlConnection _connection;
  final _uuid = Uuid();

  Future<MySqlConnection> init() async {
    Map<String, String> envVars = Platform.environment;

    var sqlHost = envVars['MYSQL_HOSTS'] ?? 'localhost';
    var sqlPort = int.parse(envVars['MYSQL_PORT'] ?? '3306');
    var dbPassword = envVars['MYSQL_PASS'] ?? '1';
    var dbName = envVars['MYSQL_DB_NAME'] ?? 'mydb';
    var dbUser = envVars['MYSQL_USER'] ?? 'root';
    final settings = ConnectionSettings(
      port: sqlPort,
      password: dbPassword,
      db: dbName,
      user: dbUser,
      host: sqlHost,
    );
    _connection = await MySqlConnection.connect(settings);

    var script =
        'CREATE TABLE if not exists User (UserName varchar(255) NOT NULL Primary key, Password varchar(255) NOT NULL, ID varchar(255) , Active BOOLEAN );';
    await _connection.query(script);

    return _connection;
  }

  Future<String?> createAccount(String? userName, String? password) async {
    if (userName != null && password != null) {
      var scriptCheckExistUser = "Select ID from User where UserName = ? ;";
      final results = await _connection.query(scriptCheckExistUser, [userName]);
      if (results.isNotEmpty) {
        throw "User early exist";
      }

      var id = uuid();

      var scrip =
          "INSERT INTO  User (UserName, Password, ID, Active) VALUES  (? , ?, ?, ?);";
      await _connection.query(scrip, [userName, password, id, true]);
      return "Success";
    } else {
      return "user name or password invalid";
    }
  }

  Future<String> signIn(String? userName, String? password) async {
    if (userName != null && password != null) {
      var scrip = "Select ID from User where UserName = ? and Password = ? ;";
      final results = await _connection.query(scrip, [userName, password]);
      if (results.isNotEmpty) {
        return results.first[0];
      } else {
        throw "Login failed";
      }
    } else {
      throw "user name or password invalid";
    }
  }

  String uuid() {
    String id = _uuid.v4();

    return id;
  }
}
