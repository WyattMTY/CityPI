import 'package:flutter/material.dart';
import 'package:flutter_appmaps/MakerInformation.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as lc;



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'CityCop'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
const DEFAULT_LOCATION = LatLng(25.756550, -100.271187);
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  LatLng position = DEFAULT_LOCATION;
  MapType mapType = MapType.normal;
  BitmapDescriptor icon;
  bool isShowInfo=false;
  LatLng latLngOnLongPress;
  bool isChangeTrafic=false;
  lc.Location location;
  bool myLocationEnabled=false;
  bool myLocationButtonEnabled=false;
  LatLng currentLocation = DEFAULT_LOCATION;
  GoogleMapController controller;
  Set<Marker>markers =Set<Marker>();
  @override
  void initState() {
    getIcons();
    requestPerm();
  }
  getLocation()async{
    var currentLocation =await location.getLocation();
    updateLocation(currentLocation);
  }
  updateLocation(currentLocation){
    if(currentLocation!=null){

    }else{
      setState(() {
        this.currentLocation=LatLng(currentLocation.latitude, currentLocation.longitude);
        this.controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: this.currentLocation,zoom: 17)
        ));
        createMarkers();
      });
    }
  }
  locationChanged(){
    location.onLocationChanged.listen((lc.LocationData cLoc) {
      if(cLoc!=null)
        updateLocation(currentLocation);
    });
  }
  requestPerm()async {
    Map<Permission, PermissionStatus>statuses =
    await [Permission.locationAlways].request();

    var status = statuses[Permission.locationAlways];
    if(status==PermissionStatus.denied){
      requestPerm();
    }else{
      enableGPS();
    }
  }
  enableGPS() async{
    location = lc.Location();
    bool serviceStatusResult = await location.requestService();

    if(!serviceStatusResult){
      enableGPS();
    }else{
      updateStatus();
      getLocation();
      locationChanged();
    }
  }
  updateStatus(){
    setState(() {
      myLocationEnabled=true;
      myLocationButtonEnabled=true;
    });
  }
  getIcons() async{
    var icon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 10), "img/11761.png");
    setState(() {
      this.icon = icon;
    });
  }
  onTapMap(LatLng latLng){
    print("onTapMap ${latLng}");
  }
  onLongPressMap(LatLng latLng){
    latLngOnLongPress=latLng;
    showPopMenu();
  }
  showPopMenu() async{
    String selected=await showMenu(context: context,
        position: RelativeRect.fromLTRB(200, 200, 250, 250),
        items: [
          PopupMenuItem(
            child: Text("Que hay aqui"),
            value: "Que hay",
          ),
          PopupMenuItem(
            child: Text("Ir a"),
            value: "Ir",
          ),
          PopupMenuItem(
            child: Text("Mostrar Trafico"),
            value: "trafico",
          ),
        ],
      elevation: 8.0
    );
    if(selected!=null)
      getValue(selected);
  }
  getValue(value){
    if(value=="Que hay")
      print("Ubicacion $latLngOnLongPress");
    if(value=="trafico")
      setState((){this.isChangeTrafic=!this.isChangeTrafic;});
  }
  createMarkers(){
    markers.add(Marker(
        markerId: MarkerId("MarkerCurrent"),
        position: currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        onTap: ()=>setState((){this.isShowInfo=!this.isShowInfo;})
    ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(children: [
          GoogleMap(
            compassEnabled: false,
            mapToolbarEnabled: false,
            trafficEnabled: this.isChangeTrafic,
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 11
            ),
            myLocationEnabled: myLocationEnabled,
            myLocationButtonEnabled: myLocationButtonEnabled,
            onTap: onTapMap,
            onLongPress: onLongPressMap,
            mapType: mapType,
            zoomControlsEnabled: false,
            markers: markers,
          ),
        SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          elevation: 9.0,
          children: [
            SpeedDialChild(
              label: "NORMAL",
              child: Icon(Icons.room),
              onTap: ()=>setState(()=>mapType=MapType.normal)
            ),
            SpeedDialChild(
                label: "SATELLITE",
                child: Icon(Icons.satellite),
                onTap: ()=>setState(()=>mapType=MapType.satellite)
            ),
            SpeedDialChild(
                label: "HYBRID",
                child: Icon(Icons.compare),
                onTap: ()=>setState(()=>mapType=MapType.hybrid)
            ),
            SpeedDialChild(
                label: "TERRAIN",
                child: Icon(Icons.terrain),
                onTap: ()=>setState(()=>mapType=MapType.terrain)
            ),
          ],
        ),
        Visibility(visible:this.isShowInfo,child: MakerInformation("Mi Ubicacion",this.currentLocation,"img/codi.jpg")),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
