import 'dart:async';

class Bloc {
  final _themeControllor = StreamController<bool>();
  void changeTheme(bool val) {
    _themeControllor.sink.add(val);
  }

  Stream<bool> get darkThemeEnabled => _themeControllor.stream;

  void dispose() {
    _themeControllor.close();
  }
}

final bloc = Bloc();
