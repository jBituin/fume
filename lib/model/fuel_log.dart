class FuelLog {
  FuelLog(this._distanceTravelled, this._fuelDate);

  int _id;
  double _distanceTravelled;
  String _fuelDate;

  double get distanceTravelled => _distanceTravelled;
  String get fuelDate => _fuelDate;
  int get id => _id;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if(id != null) map['id'] = _id;
    map['distance_travelled'] = _distanceTravelled;
    map['date'] = _fuelDate;
    
    return map;
  }

  FuelLog.fromMapObject(Map<String, dynamic> map) {
    _id = map['id'] as int;
    _distanceTravelled = map['distance_travelled'] as double;
    _fuelDate = map['date'] as String;
  }
}
