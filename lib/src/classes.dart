part of redstone.rethinkdb;

class RethinkDbManager extends DatabaseManager<ManagedConnection<Connection>> {

  Rdb _pool;

  RethinkDbManager(String host, String database, {int port: 28015, String auth: "", int poolSize: 3}) {
    _pool = new Rdb(database, port, host, auth, poolSize);
  }

  @override
  void closeConnection(RethinkConnection connection, {error}) {
    var invalidConn = error is RqlDriverError;
    _pool.releaseConnection(
        connection,
        markAsInvalid: invalidConn);
  }

  @override
  Future<RethinkConnection> getConnection() async {
    ManagedConnection<Connection> mConn = await _pool.getConnection();
    return new RethinkConnection(mConn.connId, mConn.conn);
  }
}

class RethinkConnection extends ManagedConnection<Connection> {

  RethinkConnection(int connId, Connection conn) : super (connId, conn);
}