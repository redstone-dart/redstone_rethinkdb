part of redstone.rethinkdb;

class RethinkServices<T> extends Table {
  final Rethinkdb r = new Rethinkdb();
  final String tableName;
  InjectableRethinkConnection _injectableConnection;
  Connection _conn;

  RethinkServices(String tableName):
  this.tableName = tableName,
  super(tableName) {
    _injectableConnection = new InjectableRethinkConnection();
  }

  RethinkServices.fromConnection(String tableName, Connection _conn):
  this._conn = _conn,
  this.tableName = tableName,
  super(tableName);

  RethinkServices.fromInjectableConnection(String tableName, InjectableRethinkConnection this._injectableConnection):
  this.tableName = tableName,
  super(tableName);

  Connection get conn
  =>_conn != null? _conn: _injectableConnection.conn;

  Table get table => r.table(tableName);

  Insert insertType(T record, {options}) {
    return insert(encode(record), options);
  }

  Future<Map> insertNow(T record, {options, global_optargs}) async {
    return insertType(record, options: options).run(conn, global_optargs);
  }

  Future<T> getNow (String id, {global_optargs}) async
  {
    var record = await get(id).run(conn, global_optargs);
    return record != null? decode(record, T): null;
  }

  Update updateTyped (String id, T record, {options})
  => get(id).update(encode(record), options);

  Future updateNow (String id, T record, {options, global_optargs})
  => updateTyped(id, record, options: options).run(conn, global_optargs);

  Future deleteNow (String id, {options, global_optargs})
  => get(id).delete(options).run(conn, global_optargs);

  Future<T> findOne (condition) async {
    var map = await filter(condition).limit(1).nth(0).run(conn);
    return map != null? decode(map, T): null;
  }

  pull (RqlQuery query, String field, RqlQuery condition)
  => query.update({
    field: r.row(field).filter(condition.not())
  });

  push (RqlQuery query, String field, value)
  => query.update({
    field: r.row(field).append(value)
  });
}
