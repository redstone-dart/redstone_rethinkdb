part of redstone.rethinkdb;

app.RedstonePlugin rethinkPlugin(RethinkDbManager db, {String pattern: r'/.*'}) {

  return (app.Manager manager) {

    if (db == null)
      return;

    manager.addInterceptor(new app.Interceptor.conf(pattern), "database connection manager", (injector) async {

      RethinkConnection conn = await db.getConnection();
      app.request.attributes["dbConn"] = conn.conn;

      app.chain.next(() {
        db.closeConnection(conn, error: app.chain.error);
      });

    });
  };
}