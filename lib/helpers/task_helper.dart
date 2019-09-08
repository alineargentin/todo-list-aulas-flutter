import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/models/task.dart';

class TaskHelper {
  static final TaskHelper _instance =
      TaskHelper.internal(); // executa o construtor interno

  factory TaskHelper() => _instance;

  TaskHelper.internal();

  Database _db; // banco de dados interno

// manipulação onde o tempo nao é na hora - demanda tempo indicando que é assincrono
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb(); //await aguardando o inicio do banco de dados
      return _db;
    }
  }

// metodos de criação do banco de dados - getDatabasesPath caminho android ou ios
  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "todo_list.db");

//metodo q abre o banco de dados
    return openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE task("
          "id INTEGER PRIMARY KEY, "
          "title TEXT, "
          "description TEXT, "
          "isDone INTEGER, "
          "priority INTEGER)");
    });
  }
// metodo que conta
  Future<int> getCount() async {
    Database database = await db;
    //retorna o primeiro valor passando uma query
    return Sqflite.firstIntValue(
      // consulta que demora colocar o await - retorno futuro
        await database.rawQuery("SELECT COUNT(*) FROM task")); 
  }
//fechar a base de dados
  Future close() async {
    Database database = await db;
    database.close();
  }
//insert
  Future<Task> save(Task task) async {
    Database database = await db;
    task.id = await database.insert('task', task.toMap());
    return task;
  }
//array de argumentos
  Future<Task> getById(int id) async {
    Database database = await db;
    List<Map> maps = await database.query('task',
        columns: ['id', 'title', 'description', 'isDone', 'priority'],
        where: 'id = ?',
        whereArgs: [id]);

    if (maps.length > 0) {
      return Task.fromMap(maps.first);
    } else {
      return null;
    }
  }
//deletar
  Future<int> delete(int id) async {
    Database database = await db;
    return await database.delete('task', where: 'id = ?', whereArgs: [id]);
  }
//excluir todas
  Future<int> deleteAll() async {
    Database database = await db;
    return await database.rawDelete("DELETE * from task");
  }
//atualizar 
  Future<int> update(Task task) async {
    Database database = await db;
    return await database
        .update('task', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }
//
  Future<List<Task>> getAll() async {
    Database database = await db;
    List listMap = await database.rawQuery("SELECT * FROM task ORDER BY priority ASC, isDone DESC");
    List<Task> stuffList = listMap.map((x) => Task.fromMap(x)).toList();
    return stuffList;
  }
}
