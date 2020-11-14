import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fume/views/vehicle_details.dart';
import 'dart:async';
import 'package:fume/model/vehicle.dart';
import 'package:fume/utils/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
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
  final _picker = ImagePicker();

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
                                                  VehicleDetail(snapshot
                                                      .data[position])));
                                    },
                                    child: Card(
                                      child: Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Column(
                                            children: [
                                              ClipRect(
                                                child: imageFromBase64String(
                                                    snapshot.data[position]
                                                        .coverImage as String),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          snapshot
                                                              .data[position]
                                                              .name,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ), //Text
                                                      ],
                                                    ), //Column
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      showDeleteVehiclePrompt(
                                                          snapshot.data[
                                                                  position]
                                                              as Vehicle);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                    ),
                                                    onPressed: () {
                                                      showEditVehiclePrompt(
                                                          snapshot.data[
                                                                  position]
                                                              as Vehicle);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                    ));
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
                  showAddVehiclePrompt();
                }) //FloatingActionButton
            ));
  } //build()

  void showEditVehiclePrompt(Vehicle vehicle) async {
    final vehicleNameController = TextEditingController(text: vehicle.name);
    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          const textStyle = TextStyle(
            fontSize: 20,
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
          );
          return AlertDialog(
              title: const Text('Edit Vehicle'),
              content: Row(children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: vehicleNameController,
                    onChanged: (String value) {
                      vehicle.name = value;
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
                      print(vehicle.name);
                      save(vehicle);
                      Navigator.pop(context);
                    },
                    child: const Text('Yeppers'))
              ]);
        });
  }

  void showAddVehiclePrompt() async {
    Vehicle vehicle;
    String vehicleName;
    String coverImage;

    setCoverImage() async {
      coverImage = await _getImgFromGallery();
    }

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
              content: Column(children: <Widget>[
                ClipRect(
                    child: coverImage != null
                        ? coverImage
                        : Image(
                            image: AssetImage('../assets/placeholder.png'))),
                Expanded(
                  child: TextField(
                    onChanged: (String value) {
                      vehicleName = value;
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
                ),
                Expanded(
                  child: Container(
                    child: new Wrap(
                      children: <Widget>[
                        new ListTile(
                            leading: new Icon(Icons.photo_library),
                            title: new Text('Photo Library'),
                            onTap: () {
                              setCoverImage();
                            }),
                        new ListTile(
                          leading: new Icon(Icons.photo_camera),
                          title: new Text('Camera'),
                          onTap: () {
                            _getImgFromCamera();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ]),
              actions: <Widget>[
                RawMaterialButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                RawMaterialButton(
                    onPressed: () {
                      vehicle = Vehicle(vehicleName, coverImage);
                      save(vehicle);
                      Navigator.pop(context);
                    },
                    child: const Text('Yeppers'))
              ]);
        });
  }

  _getImgFromCamera() async {
    File image = (await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50)) as File;

    return image;
  }

  _getImgFromGallery() async {
    PickedFile pickedFile =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    File image = File(pickedFile.path);
    if (image != null) {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      return base64Image;
    }
    return null;
  }

  Image imageFromBase64String(String base64String) {
    if (base64String == null) return null;
    return Image.memory(base64Decode(base64String));
  }

  void showDeleteVehiclePrompt(Vehicle vehicle) async {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure, you want to delete ${vehicle.name}?"),
            actions: <Widget>[
              RawMaterialButton(
                onPressed: () {
                  delete(vehicle.id);
                  Navigator.pop(context);
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
        result = await databaseHelper.insertVehicle(vehicle);
      }

      updateListView();

      if (result != 0) {
        String message = vehicle.id != null ? 'edited' : 'added';
        utility.showAlertDialog(
            context, 'Status', 'Vehicle $message successfully.');
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
