import 'package:redstone/server.dart' as app;
import 'package:rethinkdb_driver/rethinkdb_driver.dart';
import 'package:rethinkdb_driver/rethinkdb_pool.dart';
import 'package:redstone_mapper/database.dart';
import 'package:connection_pool/connection_pool.dart';
import 'dart:async';

class RethinkDbManager extends DatabaseManager<Connection>{

  Rdb _pool;

  RethinkDbManager(String host, int port, String database, {String auth, int poolSize: 3}) {
    _pool = new Rdb(database, port, host, auth, poolSize);
  }

  @override
  void closeConnection(ManagedConnection<Connection> connection, {error}) {
    var invalidConn = error is RqlDriverError;
    _pool.releaseConnection(
        connection,
        markAsInvalid: invalidConn);
  }

  @override
  Future<ManagedConnection<Connection>> getConnection() async {
    return _pool.getConnection();
  }
}