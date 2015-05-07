part of redstone.rethinkdb;

class RethinkServices<T> extends Table {
  final Rethinkdb r = new Rethinkdb();
  final String tableName;

  RethinkServices(String tableName):
    this.tableName = tableName,
    super(tableName);

  Connection get conn {
    var rConn = app.request.attributes.dbConn;;
    return rConn is RethinkConnection? rConn.conn: rConn;
  }
  Table get table => r.table(tableName);

  Insert insert(T record, [options]) => super.insert(encode(record), options);
}
