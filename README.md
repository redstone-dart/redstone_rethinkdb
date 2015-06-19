# Redstone RethinkDb Plugin
## Basic
### Setup 1
Use `rethinkPlugin` instead of `getMapperPlugin` to get a `Connection` injected to your routes.
```dart
import 'package:redstone/server.dart' as app;
import 'package:rethinkdb_driver/rethinkdb_driver.dart';
import 'package:redstone_rethinkdb/redstone_rethinkdb.dart';

final Rethinkdb r = new Rethinkdb();

main () {
  RethinkDbManager manager = new RethinkDbManager("someHost", "someDatabase");
  app.addPlugin(rethinkPlugin(manager));
  
  ...
}
```
### Useage 1
By convention in Rethinkdb the connection is named `conn` and in Redstone is named `dbConn`, therefore you should specify `"dbConn"` inside `@app.Attr` and set the name of the variable to `conn`.
```dart
@app.Route ('/someRoute')
someRoute (@app.Attr("dbConn") Connection conn) async {
 var result = await r
   .table ('someTable')
   //build your query as you like
   .run(conn);
   
 ...
}
```
### Setup 2
You can also use the normal `getMapperPlugin`, but you will instead get injected a `RethinkConnection`.
```dart
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:rethinkdb_driver/rethinkdb_driver.dart';
import 'package:redstone_rethinkdb/redstone_rethinkdb.dart';

final Rethinkdb r = new Rethinkdb();

main () {
  RethinkDbManager manager = new RethinkDbManager("someHost", "someDatabase");
  app.addPlugin(getMapperPlugin(manager));
  
  ...
}
```
### Useage 2
You can tap into the `dbConn` attribute without naming it in `Attr` (be sure to name the variable ``dbConn`) but you have to access the `Connection` through `dbConn.conn`.
```dart
@app.Route ('/someRoute')
someRoute (@app.Attr() RethinkConnection dbConn) async {
 var result = await r
   .table ('someTable')
   //build your query as you like
   .run(dbConn.conn);
 ...
}
```
## ConfigRethink
You can use a `ConfigRethink` instance to setup you database (and maybe handle changes in the future).
```dart
var config = new ConfigRethink(
    host: "192.168.59.103",
    port: 28015,
    database: "app",
    tables: [
      new TableConfig("users",
        secondaryIndexes: ["password"]),
      new TableConfig("comments",
        secondaryIndexes: ["userId"])
    ]
);
await setupRethink(config);
var dbManager = new RethinkDbManager.fromCongif(config);
```
The `table` property lets you specify your tables and secondary indexes within them and the `setupRethink` function with create these if they don't exist.
You can also create a `RethinkDbManager` from the config using the named constructor `fromConfig` as shown above.

## RethinkServices
Use `RethinkServices<T>` extends `Table` and lets you better structure your code and avoid error when repetively specifying the same table. It also
includes some helper methods for basic CRUD operations; usually methods like `get` or `insert` but end int `Typed` or `Now`.

`RethinkServices` also includes a default field `RethinkDb r` so you dont have to create an instance yourself. The name
 of the current table can be accessed at `tableName`, and intance of the super class can be accessed at `table`. Here is
 an example of basic crude
 
 ```dart
 @app.Group('/users')
 @Encode()
 class ServiciosUsuario extends RethinkServices<User> {
   ServiciosUsuario() : super('users');
 
   @app.Route('/:id')
   Future<User> GET (String id) async {
     User user = await getNow(id);
     if (user == null)
       throw new app.ErrorResponse (404, {"error": "User not found"});
 
     return decode(user, User);
   }
 
 
   @app.Route('/:id', methods: const[app.PUT])
   Future<User> PUT (String id, @Decode(from: const[app.JSON, app.FORM]) User delta) async {
     delta.id = null;
 
     Map resp = await updateNow(id, delta);
 
     if (resp['replaced'] == 0)
       throw new app.ErrorResponse (304, {"error": "User not in database"});
 
     return GET(id);
   }
 
   @app.Route('/:id', methods: const[app.DELETE])
   Future<Map> DELETE (String id) async {
 
     Map resp = await deleteNow(id);
     if (resp['deleted'] == 0)
       throw new app.ErrorResponse (501, {"error": "User not in database"});
 
     return {"id": id};
   }
 
   @app.DefaultRoute (methods: const [app.POST])
   @Encode()
   Future<User> POST (@Decode() User user) async {
 
     var resp = await insertNow(user);
     user.id = resp["generated_keys"].first;
 
     return user;
   }
 }
 ```
 where `User` is
 ```dart
 class User {
   @Field() String id;
   @Field() String firstname;
   @Field() String lastname;
 }
 ```
