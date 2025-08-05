import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'child.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('camp_registry.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE children (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL UNIQUE,
        age INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY(child_id) REFERENCES children(id)
      )
    ''');
  }

  // CRUD for children

Future<int> insertChild(Child child) async {
  final db = await instance.database;
  
  // перевірка на дублікат 
  final existingChild = await getChildByFullName(child.fullName);
  if (existingChild != null) {
    return -1; 
  }
  // якщо немає - додаємо
  try {
    return await db.insert(
      'children',
      child.toMap(),
    );
  } catch (e) {
    if (e is DatabaseException && e.isUniqueConstraintError()) {
      return -1; // якщо дублікат все ж стався
    }
    return -2; // інша помилка бази даних
  }
}
  Future<bool> isChildAlreadyPresentToday(int childId, String date) async {
    final db = await instance.database;
    final result = await db.query(
      'attendance',
      where: 'child_id = ? AND date = ?',
      whereArgs: [childId, date],
    );
    return result.isNotEmpty;
  }

Future<Child?> getChildByFullName(String fullName) async {
  final db = await instance.database;
  // нормалізація ПІБ для порівняння
  final normalizedInput = _normalizeFullName(fullName);
  
  // отримуємо всіх дітей І ПОРІВНЮЄМО НА СТОРОНІ Dart, а не SQLite
  final allChildren = await db.query('children');
  
  // співпадіння 
  for (var childMap in allChildren) {
    final dbFullName = childMap['full_name'] as String;
    final normalizedDb = _normalizeFullName(dbFullName);
    
    if (normalizedInput == normalizedDb) {
      return Child.fromMap(childMap);
    }
  }
  
  return null;
}

// для нормалізації ПІБ - SQLite некоректно працює з українськими літерами
// метод LOWER не працює з кирилицею
String _normalizeFullName(String fullName) {
  String normalized = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');

  normalized = normalized.toLowerCase();
  
  // прибираємо всі додаткові пробіли
  normalized = normalized.split(' ')
      .where((part) => part.isNotEmpty)
      .join(' ');
  
  return normalized;
}

  // Future<List<Child>> getChildren() async {
  //   final db = await instance.database;
  //   final result = await db.query('children', orderBy: 'age ASC');
  //   return result.map((map) => Child.fromMap(map)).toList();
  // }

  Future<List<Child>> getChildrenByDate(String date) async {
    final db = await instance.database;
    final result = await db.rawQuery(
    '''
    SELECT children.* FROM children
    INNER JOIN attendance ON children.id = attendance.child_id
    WHERE attendance.date = ?
    ORDER BY children.age ASC
    ''',
      [date],
    );
    return result.map((map) => Child.fromMap(map)).toList();
  }

  // отримати всі унікальні дати відвідувань (для історії)
  Future<List<String>> getAvailableDates() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT date FROM attendance ORDER BY date DESC',
    );
    return result.map((row) => row['date'] as String).toList();
  }

  // Отримати кількість дітей на конкретну дату
  // Future<int> getChildrenCountByDate(String date) async {
  //   final db = await instance.database;
  //   final result = await db.rawQuery(
  //     '''
  //     SELECT COUNT(*) as count FROM attendance
  //     WHERE date = ?
  //     ''',
  //     [date],
  //   );
  //   return Sqflite.firstIntValue(result) ?? 0;
  // }

  Future<int> updateChild(Child child) async {
    final db = await instance.database;
    return await db.update(
      'children',
      child.toMap(),
      where: 'id = ?',
      whereArgs: [child.id],
    );
  }

  // Future<int> deleteChild(int id) async {
  //   final db = await instance.database;
  //   // Видаляємо всі відвідування цієї дитини
  //   await db.delete('attendance', where: 'child_id = ?', whereArgs: [id]);
  //   // Видаляємо саму дитину
  //   return await db.delete('children', where: 'id = ?', whereArgs: [id]);
  // }

  Future<int> deleteAttendance(int childId, String date) async {
    final db = await instance.database;
    return await db.delete(
      'attendance',
      where: 'child_id = ? AND date = ?',
      whereArgs: [childId, date],
    );
  }
  // CRUD for attendance

  Future<int> insertAttendance(int childId, String date) async {
    final db = await instance.database;
    return await db.insert('attendance', {'child_id': childId, 'date': date});
  }

  // Future<List<Map<String, dynamic>>> getAttendanceByDate(String date) async {
  //   final db = await instance.database;
  //   return await db.query('attendance', where: 'date = ?', whereArgs: [date]);
  // }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
