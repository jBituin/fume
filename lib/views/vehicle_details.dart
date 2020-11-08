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
                  Text('Expense Logs', style: TextStyle(fontSize: 12)),
                ],
              ),
              // bottom: TabBar(tabs: [
              //   Tab(
              //     icon: Icon(Icons.format_list_numbered_rtl),
              //   ),
              //   Tab(
              //     icon: Icon(Icons.build_circle),
              //   )
              // ]),
            ), //AppBar
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
                                'No Logs',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                          return Timeline(
                            children:
                                List.generate(snapshot.data.length, (index) {
                              return CustomWidget(
                                  title: snapshot.data[index].id.toString(),
                                  sub1: snapshot.data[index].date,
                                  sub2: snapshot.data[index].fuelAmount
                                      .toString(),
                                  // status: snapshot.data[index].status,
                                  delete: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showDeleteLogPrompt(
                                          snapshot.data[index] as FuelLog);
                                    },
                                  ),
                                  trailing: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ));
                            })

                            // Container(height: 100, color: Colors.amber),
                            // Container(height: 50, color: Colors.amber),
                            // Container(height: 200, color: Colors.amber),
                            // Container(height: 100, color: Colors.amber),
                            ,
                          );
                          // return ListView.builder(
                          //   itemCount: snapshot.data.length as int,
                          //   itemBuilder: (BuildContext context, int position) {
                          //     return new GestureDetector(
                          //         // onTap: () {
                          //         // },
                          //         child: Card(
                          //       margin: EdgeInsets.all(1.0),
                          //       elevation: 2.0,
                          //       child: CustomWidget(
                          //         title: snapshot.data[position].id.toString(),
                          //         sub1: snapshot.data[position].date,
                          //         sub2: snapshot.data[position].fuelAmount
                          //             .toString(),
                          //         // status: snapshot.data[position].status,
                          //         delete: IconButton(
                          //           icon: Icon(
                          //             Icons.delete,
                          //             color: Colors.red,
                          //           ),
                          //           onPressed: () {
                          //             showDeleteLogPrompt(
                          //                 snapshot.data[position] as FuelLog);
                          //           },
                          //         ),
                          //         trailing: Icon(
                          //           Icons.edit,
                          //           color: Colors.blue,
                          //         ),
                          //       ),
                          //     ) //Card
                          //         );
                          //   },
                          // );
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
                  showAddLogPrompt();
                }) //FloatingActionButton
            ));
  } //build()

  void showAddLogPrompt() async {
    FuelLog log;
    double fuelAmount;
    double fuelCost;

    String logDate = DateFormat('MMM-dd-yyyy').format(DateTime.now());
    TextEditingController logDateController =
        TextEditingController(text: logDate);

    print('hehehe');
    print(logDateController);

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
                      log = FuelLog(
                          logDate, fuelAmount, fuelCost, widget.vehicle.id);
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
                  await databaseHelper.deleteVehicle(log.id);
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
