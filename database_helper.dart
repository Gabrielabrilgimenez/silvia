import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Obtener la ruta del directorio adecuado para almacenamiento de la base de datos
    String path;

    if (Platform.isAndroid || Platform.isIOS) {
      // Usar path_provider para móviles
      final directory = await getApplicationDocumentsDirectory();
      path = join(directory.path, 'my_database.db');
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Inicializar sqflite para plataformas de escritorio
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      // Usar el directorio actual en plataformas de escritorio
      path =
      'my_database.db'; // Esto almacenará la base de datos en el directorio de ejecución
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    // Abrir la base de datos y crear la tabla si no existe
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async{
        await db.execute(
            'CREATE TABLE texts(id INTEGER PRIMARY KEY AUTOINCREMENT, pregunta PREGUNTA, respuesta RESPUESTA, favorito FAVORITO)'
        );
        await db.execute(
            'CREATE TABLE favs(id INTEGER PRIMARY KEY AUTOINCREMENT, pregunta PREGUNTA, respuesta RESPUESTA, favorito FAVORITO)'
        );
      },
    );
  }


  Future<void> resetDatabase() async {
    final db = await database;

    // Elimina todas las tablas
    await db.execute('DROP TABLE IF EXISTS texts');

    // Crea las tablas nuevamente
    await db.execute(
        'CREATE TABLE texts(id INTEGER PRIMARY KEY AUTOINCREMENT, pregunta PREGUNTA, respuesta RESPUESTA, favorito FAVORITO)'
    );
  }

  Future<void> resetNoFavs() async {
    final db = await database;

    await db.execute('DELETE FROM texts WHERE favorito = 0');
  }

  // Metodo para insertar un texto en la base de datos
  Future<int> insertText(String pregunta, String respuesta, int favorito) async {
    final db = await database;
    return await db.insert(
        'texts', {'pregunta': pregunta, 'respuesta': respuesta, 'favorito': favorito});
  }

  Future<void> updateFavoriteStatus(int id, int favorito) async {
    // Actualizar solo el campo 'favorito' en la base de datos
    final db = await database;
    await db.update(
      'texts',
      {'favorito': favorito},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> resetFavoritos() async {
    // Actualizar solo el campo 'favorito' en la base de datos
    final db = await database;
    await db.update(
      'texts',
      {'favorito': 0},
    );
  }

  Future<bool> hayFavoritos() async {
    Database db = await instance.database;

    List<Map<String, dynamic>> result = await db.query(
      'texts',
      columns: ['favorito'],
      where: "favorito = ?",
      whereArgs: [1],
      limit: 1, // PARA OPTIMIZAR
    );

    // Si el resultado no está vacío, significa que existe al menos un elemento
    return result.isNotEmpty;
  }

  // Obtener todos los textos de la base de datos
  Future<List<Map<String, dynamic>>> getTexts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('texts');

    // Asegúrate de que los datos tengan la forma correcta
    return List.generate(maps.length, (i) {
      return {
        'id': maps[i]['id'],
        'pregunta': maps[i]['pregunta'],
        'respuesta': maps[i]['respuesta'],
        'favorito': maps[i]['favorito'],
      };
    });
  }
}