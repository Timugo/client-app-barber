import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:timugo/src/models/place.dart';
import 'package:dio/dio.dart';
import 'package:timugo/src/providers/user.dart';

//Widgets
import 'package:timugo/src/widgets/divider_with_text.dart';
import 'package:timugo/src/widgets/formDirection.dart';

class NewTripLocationView extends StatefulWidget {
  @override
  _NewTripLocationViewState createState() => _NewTripLocationViewState();
}

class _NewTripLocationViewState extends State<NewTripLocationView> {
  TextEditingController _searchController = new TextEditingController();
  Timer _throttle;
  String _heading;
  List<Place> _placesList;
  final List<Place> _suggestedList = [];
  
  @override
  void initState() {
    super.initState();
    _heading = "Busquedas";
    _placesList = _suggestedList;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (_throttle?.isActive ?? false) _throttle.cancel();
    _throttle = Timer(
      const Duration(milliseconds: 500), () {
        getLocationResults(_searchController.text);
      }
    );
  }

  void getLocationResults(String input) async {
    if (input.isEmpty) {
      setState(() {
        _heading = "Busquedas";
      });
      return;
    }
    String busq = input.replaceAll(new RegExp(r'[^\w\s]+'),'');
    print(busq);
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String apiKey= 'AIzaSyDsPifARDpIqrgAS8TBQtyI7baFlXh3Lu4';
    String request = '$baseURL?input=$busq&language=es&location=3.4372201,-76.5224991&radius=500&key=$apiKey';
    Response response = await Dio().get(request);
    final predictions = response.data['predictions'];
    List<Place> _displayResults = [];

    

    for (var i = 0; i < predictions.length; i++) {
      String name = predictions[i]['description'];
      double averageBudget = 200.0;
      _displayResults.add(Place(name, averageBudget));
    }

    setState(() {
      _heading = "Resultados";
      _placesList = _displayResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      appBar: AppBar(
        elevation: 0,
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back,
            color: Colors.red,
            size: 35,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white24,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ListTile(
              title:Text('Ingresa tu dirección ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
              subtitle:Text('ej: calle 23 # 70-81 barrio .. '),
            ),
            Container(
              padding: const EdgeInsets.all(30.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: new DividerWithText(
                dividerText: _heading,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _placesList.length,
                itemBuilder: (BuildContext context, int index) =>
                    buildPlaceCard(context, index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPlaceCard(BuildContext context, int index) {
    return Hero(
      tag: "SelectedTrip-${_placesList[index].name}",
      transitionOnUserGestures: true,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Card(
            
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding (
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child:ListTile(
                                  trailing: IconButton(
                                    icon: Icon(Icons.arrow_right),
                                    onPressed: () async {
                                      String address = _placesList[index].name;
                                      _getAddressFromLatLng(address);
                                      Future.delayed(const Duration(seconds: 4), () {
                                        setState(() {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FormDirections(address: address)
                                            ),
                                          );
                                        });
                                      });
                                    }
                                  ,), 
                                  title:Text(_placesList[index].name,style:(TextStyle(color: Colors.black,fontWeight: FontWeight.w500)),),
                                  leading: Icon(Icons.place),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ]
                  ),
                 

      
              onTap: (){
                String address = _placesList[index].name;
                _getAddressFromLatLng(address);
              }
            ),
          ),
        ),
      ),
    );
  }
  _getAddressFromLatLng(String address) async {
    final userInfo = Provider.of<UserInfo>(context);
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    try {
      List<Placemark> placemark = await geolocator.placemarkFromAddress(address);
      Placemark place = placemark[0];
      setState(() {
        userInfo.loca=place.position;
      });
    } catch (e) {
      print(e);
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FormDirections(address: address,position: userInfo.loca,)),
        );
      });
    });
  }
}
