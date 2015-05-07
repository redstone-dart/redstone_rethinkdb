# Redstone RethinkDb Plugin
## Basic
### Setup 1
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

```dart
@app.Route ('/someRoute')
someRoute (@app.Attr("dbConn") RethinkConnection rConn) async {
 var result = await r
   .table ('someTable')
   //build your query as you like
   .run(rConn.conn);
 ...
}
```
## Advanced
