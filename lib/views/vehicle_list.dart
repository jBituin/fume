import 'package:flutter/material.dart';
import 'package:fume/views/vehicle_details.dart';
import 'dart:async';
import 'package:fume/model/vehicle.dart';
import 'package:fume/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fume/widgets/CustomWidget.dart';
import 'package:fume/utils/utils.dart';

class VehicleList extends StatefulWidget {
  final bool darkThemeEnabled;
  VehicleList(this.darkThemeEnabled);

  @override
  State<StatefulWidget> createState() {
    return VehicleListState();
  }
}

class VehicleListState extends State<VehicleList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Utils utility = new Utils();
  List<Vehicle> vehicleList;
  int count = 0;
  String _themeType;
  final homeScaffold = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    if (!widget.darkThemeEnabled) {
      _themeType = 'Light Theme';
    } else {
      _themeType = 'Dark Theme';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (vehicleList == null) {
      vehicleList = List<Vehicle>();
      updateListView();
    }

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            key: homeScaffold,
            appBar: AppBar(
                title: Text(
              "Mileage Tracker",
              style: TextStyle(fontSize: 25),
            )), //AppBar
            body: Container(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: FutureBuilder(
                      future: databaseHelper.getVehicleList(),
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
                                    onTap: () {
                                      print('hehee');
                                      Navigator.push(
                                        context, 
                                        MaterialPageRoute(
                                          builder: (context) =>  
                                            VehicleDetail(snapshot.data[position])
                                        )
                                      );
                                    },
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
                                            snapshot.data[position] as Vehicle);
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
    Vehicle vehicle;
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
                    onChanged: (String value) {
                      setState(() {
                        vehicle = Vehicle(value);
                      });
                    },
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
                      save(vehicle);
                      Navigator.pop(context);
                    },
                    child: const Text('Yeppers'))
              ]);
        });
  }

  void showDeleteVehiclePrompt(Vehicle vehicle) async {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure, you want to delete ${vehicle.name}?"),
            actions: <Widget>[
              RawMaterialButton(
                onPressed: () async {
                  await databaseHelper.deleteVehicle(vehicle.id);
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

  void save(Vehicle vehicle) async {
    int result;

    print(vehicle);
    if (vehicle.name != null) {
      if (vehicle.id != null) {
        //Update Operation
        result = await databaseHelper.updateVehicle(vehicle);
      } else {
        //Insert Operation
        print('@else');
        result = await databaseHelper.insertVehicle(vehicle);
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
      Future<List<Vehicle>> vehicleListFuture = databaseHelper.getVehicleList();
      vehicleListFuture.then((vehicleList) {
        print('vehicleList');
        // print(vehicleList[0].name);
        setState(() {
          this.vehicleList = vehicleList;
          this.count = vehicleList.length;
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
