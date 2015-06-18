part of redstone.rethinkdb;

class RethinkDbManager extends DatabaseManager<ManagedConnection<Connection>> {
  Rdb _pool;

  RethinkDbManager(String host, String database,
                   {int port: 28015, String auth: "", int poolSize: 15}) {
    _pool = new Rdb(database, port, host, auth, poolSize);
  }

  RethinkDbManager.fromCongif(ConfigRethink config) : this(
      config.host, config.database,
      port: config.port, auth: config.auth, poolSize: 15);

  @override
  void closeConnection(RethinkConnection connection, {error}) {
    var invalidConn = error is RqlDriverError;
    _pool.releaseConnection(connection, markAsInvalid: invalidConn);
  }

  @override
  Future<RethinkConnection> getConnection() async {
    ManagedConnection<Connection> mConn = await _pool.getConnection();
    return new RethinkConnection(mConn.connId, mConn.conn);
  }
}

class RethinkConnection extends ManagedConnection<Connection> {
  RethinkConnection(int connId, Connection conn) : super(connId, conn);
}

class InjectableRethinkConnection implements RethinkConnection {
  Connection _conn;

  InjectableRethinkConnection();
  InjectableRethinkConnection.fromConnection(this._conn);

  final int connId = 0;

  Connection get conn {
    if (_conn != null) return _conn;

    var rConn = app.request.attributes.dbConn;
    return rConn is RethinkConnection ? rConn.conn : rConn;
  }
}

class ConfigRethink {
  final String host;
  final String database;
  final String auth;
  final List<TableConfig> tables;
  final int port;

  ConfigRethink({this.host: 'localhost', this.database: 'test', this.auth: '',
                this.tables: const [], this.port: 28015});
}

class TableConfig {
  final String name;
  final List<String> secondaryIndexes;

  TableConfig (this.name, {this.secondaryIndexes: const []});
}
