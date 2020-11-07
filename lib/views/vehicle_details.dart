import 'package:flutter/material.dart';
import 'package:fume/model/fuel_log.dart';
import 'package:fume/views/vehicle_details.dart';
import 'dart:async';
import 'package:fume/model/vehicle.dart';
import 'package:fume/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fume/widgets/CustomWidget.dart';
import 'package:fume/utils/theme_bloc.dart';
import 'package:fume/utils/utils.dart';

class VehicleDetail extends StatefulWidget {
  // final bool darkThemeEnabled;
  final Vehicle vehicle;
  VehicleDetail(this.vehicle);

  @override
  State<StatefulWidget> createState() {
    return VehicleDetailState();
  }
}

class VehicleDetailState extends State<VehicleDetail> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Utils utility = new Utils();
  List<FuelLog> logs;
  int count = 0;
  String _themeType;
  final homeScaffold = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // if (!widget.darkThemeEnabled) {
    //   _themeType = 'Light Theme';
    // } else {
    //   _themeType = 'Dark Theme';
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (logs == null) {
      logs = List<FuelLog>();
      updateListView();
    }

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            key: homeScaffold,
            appBar: AppBar(
                title: Column(
              children: [
                Text(widget.vehicle.name, style: TextStyle(fontSize: 25)),
                Text('Fuel Logs', style: TextStyle(fontSize: 12)),
              ],
            )), //AppBar
            body: Container(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: FutureBuilder(
                      future:
                          databaseHelper.getVehicleLogList(widget.vehicle.id),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Text("Loading");
                        } else {
                          if (snapshot.data.length as int < 1) {
                            return Center(
                              child: Text(
                                'No Vehicles',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                          return ListView.builder(
                              itemCount: snapshot.data.length as int,
                              itemBuilder:
                                  (BuildContext context, int position) {
                                return new GestureDetector(
                                    // onTap: () {
                                    // },
                                    child: Card(
                                  margin: EdgeInsets.all(1.0),
                                  elevation: 2.0,
                                  child: CustomWidget(
                                    title:
                                        snapshot.data[position].name as String,
                                    // sub1: snapshot.data[position].date,
                                    // sub2: snapshot.data[position].time,
                                    // status: snapshot.data[position].status,
                                    delete: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDeleteVehiclePrompt(
                                            snapshot.data[position] as FuelLog);
                                      },
                                    ),
                                    trailing: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ) //Card
                                    );
                              });
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
                tooltip: "Add Vehicle",
                child: Icon(Icons.add),
                onPressed: () {
                  updateListView();
                  showAddVehiclePrompt();
                }) //FloatingActionButton
            ));
  } //build()

  void showAddVehiclePrompt() async {
    FuelLog log;
    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          const textStyle = TextStyle(
            fontSize: 20,
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
          );
          return AlertDialog(
              title: const Text('Add a new vhicle'),
              content: Row(children: <Widget>[
                Expanded(
                  child: TextField(
                    // onChanged: (String value) {
                    //   setState(() {
                    //     log = FuelLog(log);
                    //   });
                    // },
                    autofocus: true,
                    decoration: const InputDecoration(
                        labelText: 'Vehicle Name',
                        hintText: 'eg. Honda CB400',
                        labelStyle: textStyle,
                        hintStyle: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Lato',
                            fontStyle: FontStyle.italic,
                            color: Colors.grey)),
                  ),
                )
              ]),
              actions: <Widget>[
                RawMaterialButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                RawMaterialButton(
                    onPressed: () {
                      save(log);
                      Navigator.pop(context);
                    },
                    child: const Text('Yeppers'))
              ]);
        });
  }

  void showDeleteVehiclePrompt(FuelLog log) async {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure, you want to delete this log?"),
            actions: <Widget>[
              RawMaterialButton(
                onPressed: () async {
                  await databaseHelper.deleteVehicle(log.id);
                  Navigator.pop(context);
                  updateListView();
                  utility.showSnackBar(
                      homeScaffold, 'Vehicle Deleted Successfully.');
                },
                child: Text("Yes"),
              ),
              RawMaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No"),
              )
            ],
          );
        });
  }

  void save(FuelLog log) async {
    int result;

    print(log);
    if (log != null) {
      if (log.id != null) {
        //Update Operation
        result = await databaseHelper.updateFuelLog(log);
      } else {
        //Insert Operation
        print('@else');
        result = await databaseHelper.insertFuelLog(log);
        print(result);
      }

      updateListView();

      if (result != 0) {
        utility.showAlertDialog(
            context, 'Status', 'Vehicle added successfully.');
      } else {
        utility.showAlertDialog(context, 'Status', 'Problem adding vehicle.');
      }
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();

    dbFuture.then((database) {
      Future<List<FuelLog>> vehicleListFuture =
          databaseHelper.getVehicleLogList(widget.vehicle.id);
      vehicleListFuture.then((logs) {
        print('logs');
        // print(logs[0].name);
        setState(() {
          this.logs = logs;
          this.count = logs.length;
        });
      });
    });
  } //updateListView()

  void delete(int id) async {
    await databaseHelper.deleteVehicle(id);
    updateListView();
    //Navigator.pop(context);
    utility.showSnackBar(homeScaffold, 'Vehicle Deleted Successfully');
  }
}
