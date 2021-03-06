import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fume/model/fuel_log.dart';
import 'package:intl/intl.dart';

import 'dart:async';
import 'package:fume/model/vehicle.dart';
import 'package:fume/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fume/widgets/CustomWidget.dart';
import 'package:fume/widgets/Timeline.dart';
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
              ),
            ), //AppBar
            body: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(children: <Widget>[
                  ClipRect(
                      child: imageFromBase64String(widget.vehicle.coverImage)),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: ListView(
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: FutureBuilder(
                              future: databaseHelper
                                  .getVehicleLogList(widget.vehicle.id),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.data == null) {
                                  return Text("Loading");
                                } else {
                                  if (snapshot.data.length as int < 1) {
                                    return Center(
                                      child: Text(
                                        'No Logs',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    );
                                  }
                                  return Timeline(
                                    children: List.generate(
                                      snapshot.data.length,
                                      (index) {
                                        return CustomWidget(
                                            title:
                                                ' ₱${snapshot.data[index].fuelCost.toString()}',
                                            sub1: snapshot.data[index].date,
                                            sub2:
                                                '${snapshot.data[index].fuelAmount.toString()} Liters',
                                            // status: snapshot.data[index].status,
                                            delete: IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                showDeleteLogPrompt(snapshot
                                                    .data[index] as FuelLog);
                                              },
                                            ),
                                            trailing: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ));
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ])
              ],
            ),

            // ),
            floatingActionButton: FloatingActionButton(
                tooltip: "Add Vehicle",
                child: Icon(Icons.add),
                onPressed: () {
                  showAddLogPrompt();
                }) //FloatingActionButton
            ));
  } //build()

  Image imageFromBase64String(String base64String) {
    print('base64');
    print(base64String);
    if (base64String == null) return null;
    return Image.memory(base64Decode(base64String));
  }

  void showAddLogPrompt() async {
    FuelLog log;
    double fuelAmount;
    double fuelCost;

    String logDate = DateFormat('MMM-dd-yyyy').format(DateTime.now());
    TextEditingController logDateController =
        TextEditingController(text: logDate);

    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          const textStyle = TextStyle(
            fontSize: 20,
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
          );
          return AlertDialog(
              title: const Text('Add a new fuel log'),
              content: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 35.0),
                    ),

                    // Text('Register Form', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),),

                    TextFormField(
                      // controller: etUsername,
                      decoration: InputDecoration(
                        labelText: 'Fuel Amount in Liters',
                        // hintText: 'Input Username',
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (double.tryParse(value) == null) {
                          return 'Invalid input';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (double.tryParse(value) != null) {
                          fuelAmount = double.parse(value);
                        }
                      },
                    ),
                    TextFormField(
                      // controller: etPassword,
                      decoration: InputDecoration(
                          // hintText: 'Input Password'
                          labelText: 'Fuel Cost'),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d*)'))
                      ],
                      validator: (value) {
                        if (double.tryParse(value) == null) {
                          return 'Invalid input';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (double.tryParse(value) != null) {
                          fuelCost = double.parse(value);
                        }
                      },
                    ),

                    TextFormField(
                      controller: logDateController,
                      decoration: InputDecoration(
                        labelText: "Date",
                      ),
                      onTap: () async {
                        DateTime date = DateTime(1900);
                        FocusScope.of(context).requestFocus(new FocusNode());

                        date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100));

                        logDateController.text =
                            DateFormat('MMM-dd-yyyy').format(date);
                        logDate = logDateController.text;
                      },
                      onChanged: (value) {
                        logDate = value;
                      },
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                RawMaterialButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                RawMaterialButton(
                    onPressed: () {
                      log = FuelLog(logDateController.text, fuelAmount,
                          fuelCost, widget.vehicle.id);
                      save(log);
                      Navigator.pop(context);
                    },
                    child: const Text('Yeppers'))
              ]);
        });
  }

  void showDeleteLogPrompt(FuelLog log) async {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure, you want to delete this log?"),
            actions: <Widget>[
              RawMaterialButton(
                onPressed: () async {
                  await databaseHelper.deleteVehicleFuelLog(log.id);
                  updateListView();
                  Navigator.pop(context);
                  utility.showSnackBar(
                      homeScaffold, 'Log Deleted Successfully.');
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
        utility.showAlertDialog(context, 'Status', 'Log added successfully.');
      } else {
        utility.showAlertDialog(context, 'Status', 'Problem adding log.');
      }
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();

    dbFuture.then((database) {
      Future<List<FuelLog>> logListFuture =
          databaseHelper.getVehicleLogList(widget.vehicle.id);
      logListFuture.then((logs) {
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
    await databaseHelper.deleteVehicleFuelLog(id);
    updateListView();
    //Navigator.pop(context);
    utility.showSnackBar(homeScaffold, 'Log Deleted Successfully');
  }
}
