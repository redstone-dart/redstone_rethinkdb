part of redstone.rethinkdb;

app.RedstonePlugin rethinkPlugin(RethinkDbManager db, {String pattern: r'/.*'}) {

  return (app.Manager manager) {

    if (db == null)
      return;

    manager.addInterceptor(new app.Interceptor(pattern), "database connection manager", (injector, route) async {

      RethinkConnection conn = await db.getConnection();
      app.request.attributes["dbConn"] = conn.conn;

      await app.chain.next();
      db.closeConnection(conn, error: app.chain.error);
    });
  };
}

setupRethink(ConfigRethink config) async {
  Rethinkdb r = new Rethinkdb();
  Connection conn = await r.connect(host: config.host, db: config.database, port: config.port);

  if (!await r.dbList().contains(config.database).run(conn)) {
    await r.dbCreate(config.database).run(conn);
    print('Created db: ${config.database}');
  }

  List tables = await r.db(config.database).tableList().run(conn);
  for (var tableConfig in config.tables) {
    if (!tables.contains(tableConfig.name)) {
      await r.tableCreate(tableConfig.name).run(conn);
      print('Created table: ${tableConfig.name}');
    }

    var table = r.table(tableConfig.name);
    for (var index in tableConfig.secondaryIndexes) {
      List<String> indexes = await table.indexList().run(conn);
      if (! indexes.contains(index)) {
        await table.indexCreate(index).run(conn);
        print('Created index $index on table: ${tableConfig.name}');
      }
    }
  }

  conn.close();
}