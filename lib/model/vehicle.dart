import 'package:fume/model/fuel_log.dart';

class Vehicle {
  Vehicle(this._name);

  int _id;
  String _name;
  double _odometer;
  List<FuelLog> _fuelLogs = [];

  set odometer(double o) => _odometer = o;

  void addFuelLog(FuelLog log) {
    _fuelLogs.add(log);
  }

  List<FuelLog> get fuelLogs => _fuelLogs;
  double get odometer => _odometer;
  String get name => _name;
  int get id => _id;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) map['id'] = _id;
    map['name'] = _name;

    return map;
  }

  Vehicle.fromMapObject(Map<String, dynamic> map) {
    _id = map['id'] as int;
    _name = map['name'] as String;
  }
}
