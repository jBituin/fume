class FuelLog {
  FuelLog(this._date, this._fuelAmount, this._fuelCost, this._vehicleId);

  int _id;
  int _vehicleId;
  double _distanceTravelled;
  double _fuelAmount;
  double _fuelCost;
  String _date;

  int get id => _id;
  int get vehicleId => _vehicleId;
  double get distanceTravelled => _distanceTravelled;
  double get fuelAmount => _fuelAmount;
  double get fuelCost => _fuelCost;
  String get date => _date;

  set distanceTravelled(value) => _distanceTravelled = value;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) map['id'] = _id;
    map['distance_travelled'] = _distanceTravelled;
    map['date'] = _date;
    map['fuel_amount'] = _fuelAmount;
    map['fuel_cost'] = _fuelCost;
    map['vehicle_id'] = _vehicleId;

    return map;
  }

  FuelLog.fromMapObject(Map<String, dynamic> map) {
    _id = map['id'] as int;
    _vehicleId = map['vehicle_id'] as int;
    _distanceTravelled = map['distance_travelled'] as double;
    _fuelAmount = map['fuel_amount'] as double;
    _fuelCost = map['fuel_cost'] as double;
    _date = map['date'] as String;
  }
}
