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

  Insert insertType(T record, {options}) {
    return insert(encode(record), options);
  }

  Future insertNow(T record, {options, global_optargs})
    => insertType(record, options: options).run(conn, global_optargs);

  Future<T> getNow (String id, {global_optargs}) async
  {
    var record = await get(id).run(conn, global_optargs);
    return record != null? encode(record): null;
  }

  Update updateTyped (String id, T record, {options})
    => get(id).update(encode(record), options);

  Future updateNow (String id, T record, {options, global_optargs})
    => updateTyped(id, record, options: options).run(conn, global_optargs);

  Future deleteNow (String id, {options, global_optargs})
    => get(id).delete(options).run(conn, global_optargs);

}
