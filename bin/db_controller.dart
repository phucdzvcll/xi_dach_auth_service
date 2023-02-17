import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:uuid/uuid.dart';

class DBController {
  final _uuid = Uuid();

  Future<void> init() async {
    ConnectionSettings settings = _getSetting();
    final connection = await MySqlConnection.connect(settings);

    var script =
        'CREATE TABLE if not exists User (UserName varchar(255) NOT NULL Primary key, Password varchar(255) NOT NULL , ID varchar(255) , Active BOOLEAN );';
    await connection.query(script);

    var script2 =
        'CREATE TABLE if not exists Point (id varchar(255) NOT NULL Primary key, P int NOT NULL );';
    await connection.query(script2);
    await connection.close();
  }

  ConnectionSettings _getSetting() {
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
    return settings;
  }

  Future<String?> createAccount(String? userName, String? password) async {
    if (userName != null && password != null) {
      final connection = await MySqlConnection.connect(_getSetting());
      var scriptCheckExistUser = "Select ID from User where UserName = ? ;";
      final results = await connection.query(scriptCheckExistUser, [userName]);
      if (results.isNotEmpty) {
        throw "User early exist";
      }

      var id = uuid();

      var scrip =
          "INSERT INTO  User (UserName, Password, ID, Active) VALUES  (? , ?, ?, ?);";
      await connection.query(scrip, [userName, password, id, true]);
      await connection.close();
      return "Success";
    } else {
      return "user name or password invalid";
    }
  }

  Future<String> signIn(String? userName, String? password) async {
    if (userName != null && password != null) {
      final connection = await MySqlConnection.connect(_getSetting());
      var scrip = "Select ID from User where UserName = ? and Password = ? ;";
      final results = await connection.query(scrip, [userName, password]);
      if (results.isNotEmpty) {
        await connection.close();
        return results.first[0];
      } else {
        await connection.close();
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
