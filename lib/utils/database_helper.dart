import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fume/model/vehicle.dart';
import 'package:fume/model/fuel_log.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //Singleton DatabaseHelper
  static Database _database; //Singleton Database

  // Vehicle table
  String vehicleTable = 'vehicle';
  String columnVehicleId = 'id';
  String columnVehicleName = 'name';

  // Fuel logs table
  String logTable = "fuel_log";
  String columnLogVehicleId = 'vehicle_id';
  String columnLogId = "id";
  String columnLogDate = 'date';
  String columnLogFuelAmount = 'fuel_amount';
  String columnLogFuelCost = 'fuel_cost';
  String columnLogTravelled = 'distance_travelled';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //Get the directory path for both Android and iOS to store Database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "vehicle.db";

    //Open/Create the database at the given path
    var database = await openDatabase(path, version: 1, onCreate: _createDb);

    return database;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $vehicleTable ($columnVehicleId INTEGER PRIMARY KEY AUTOINCREMENT, $columnVehicleName TEXT)');
    await db.execute(
        'CREATE TABLE $logTable ($columnLogId INTEGER PRIMARY KEY AUTOINCREMENT, $columnLogVehicleId INTEGER, $columnLogTravelled REAL, $columnLogFuelAmount REAL, $columnLogFuelCost REAL, $columnLogDate TEXT)');
  }

  //Fetch Operation: Get all Vehicle objects from database
  Future<List<Map<String, dynamic>>> getVehicleMapList() async {
    final Database db = await database;
    var result = db.query(vehicleTable, orderBy: '$columnVehicleName');
    return result;
  }

  //Fetch Operation: Get all logs of a vehicle
  Future<List<Map<String, dynamic>>> getVehicleFuelLogMapList(
      int vehicleId) async {
    final Database db = await database;
    var result = db.rawQuery(
        'SELECT * FROM $logTable WHERE $columnLogVehicleId=$vehicleId ORDER BY $columnLogDate');
    // var result = db.query(logTable, log.)
    return result;
  }

  //Insert Operation: Insert a Vehicle object to database
  Future<int> insertVehicle(Vehicle vehicle) async {
    final Database db = await database;
    print(db);
    var result = await db.insert(vehicleTable, vehicle.toMap());
    return result;
  }

  Future<int> insertFuelLog(FuelLog fuelLog) async {
    final Database db = await database;
    var result = await db.insert(logTable, fuelLog.toMap());
    return result;
  }

  //Update Operation: Update a Vehicle object and save it to database
  Future<int> updateVehicle(Vehicle vehicle) async {
    final Database db = await database;
    var result = await db.update(vehicleTable, vehicle.toMap(),
        where: '$columnVehicleId = ?', whereArgs: [vehicle.id]);
    return result;
  }

  //Update operation: Update a log
  Future<int> updateFuelLog(FuelLog fuelLog) async {
    final Database db = await database;
    var result = await db.update(logTable, fuelLog.toMap(),
        // ignore: always_specify_types
        where: '$columnLogId = ? ',
        whereArgs: [fuelLog.id]);
    return result;
  }

  //Delete Operation: Delete a Vehicle object from database
  Future<int> deleteVehicle(int id) async {
    final Database db = await database;
    int result = await db
        .rawDelete('DELETE FROM $vehicleTable WHERE $columnVehicleId=$id');
    return result;
  }

  //Delete operation: Delete a Fuel log
  Future<int> deleteVehicleFuelLog(int id) async {
    final Database db = await database;
    int result =
        await db.rawDelete('DELETE FROM $logTable WHERE $columnLogId=$id');
    return result;
  }

  //Get no. of Vehicle objects in database
  Future<int> getVehicleCount() async {
    final Database db = await database;
    List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT COUNT (*) FROM $vehicleTable');
    int count = Sqflite.firstIntValue(result);
    return count;
  }

  //Get no. of FuelLog objects in database
  Future<int> getFuelLogCount() async {
    final Database db = await database;
    List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT COUNT (*) FROM $logTable');
    int count = Sqflite.firstIntValue(result);
    return count;
  }

  //Get no. of FuelLog of a vehicle
  Future<int> getVehicleLogCount(int vehicleId) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT (*) FROM $logTable WHERE $columnLogVehicleId=$vehicleId');
    int count = Sqflite.firstIntValue(result);
    return count;
  }

  Future<List<Vehicle>> getVehicleList() async {
    final vehicleMapList =
        await getVehicleMapList(); //Get Map List from database
    int count = vehicleMapList.length;

    List<Vehicle> vehicleList = List<Vehicle>();
    //For loop to create Vehicle List from a Map List
    for (int i = 0; i < count; i++) {
      vehicleList.add(Vehicle.fromMapObject(vehicleMapList[i]));
    }
    return vehicleList;
  }

  Future<List<FuelLog>> getVehicleLogList(int vehicleId) async {
    final vehicleLogMapList = await getVehicleFuelLogMapList(vehicleId);
    int count = vehicleLogMapList.length;

    List<FuelLog> logList = List<FuelLog>();

    for (int i = 0; i < count; i++) {
      logList.add(FuelLog.fromMapObject(vehicleLogMapList[i]));
    }

    return logList;
  }
}
