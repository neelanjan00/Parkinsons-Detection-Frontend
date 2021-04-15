import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(MyAppTheme());
    });
}

class MyAppTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return(
      MaterialApp(
        title: "Parkinson's AI",
        theme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
            fontFamily: 'PT Sans',
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: MyApp(),
      )
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return (SplashScreen(
      seconds: 2,
      navigateAfterSeconds: HomePage(),
      title: Text(
        "Parkinson's AI",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27.0),
      ),
      image: Image(
        image: AssetImage("assets/brain.png"),
      ),
      backgroundColor: Colors.pink[50],
      loaderColor: Colors.pink[50],
      photoSize: 100.0,
    ));
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  Widget buildCardTestSelector(String title, String image, String description, var colorOverlay) {
    return (GestureDetector(
      onTap: () {
        if (title == "Spiral Test")
          Navigator.push(
            this.context,
            MaterialPageRoute(
              builder: (context) => SpiralAndWaveTest(
                "https://parkinsonsai.herokuapp.com/spiral",
                "assets/spirals.jpg",
              ),
            ),
          );
        else
          Navigator.push(
            this.context,
            MaterialPageRoute(
              builder: (context) => SpiralAndWaveTest(
                "https://parkinsonsai.herokuapp.com/wave",
                "assets/waves.jpg",
              ),
            ),
          );
      },
      child: Container(
        width: MediaQuery.of(this.context).size.width * 0.85,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.pink[100],
              blurRadius: 4,
              offset: Offset(2, 2),
            )
          ],
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(colorOverlay, BlendMode.overlay)
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.arrow_forward),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return (Center(
      child: Scaffold(
        backgroundColor: Colors.pink[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              buildCardTestSelector(
                "Spiral Test", 
                "assets/spirals.jpg", 
                "Draw a single thread concentric spiral with a pencil on a white paper and upload its image.",
                Colors.white10
              ),
              SizedBox(height: 40),
              buildCardTestSelector(
                "Wave Test",
                "assets/waves.jpg",
                "Draw a sine wave or a zig-zag pattern with a pencil on a white paper and upload its image.",
                Colors.white70
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class SpiralAndWaveTest extends StatefulWidget {
  final String postPath, background;
  SpiralAndWaveTest(this.postPath, this.background);

  @override
  _SpiralAndWaveTestState createState() => _SpiralAndWaveTestState();
}

class _SpiralAndWaveTestState extends State<SpiralAndWaveTest> {
  File _image;
  bool isImageShowing = false;
  bool isImagePosting = false;
  bool isPredictedLabelAvailable = false;
  String predictedLabel;
  final picker = ImagePicker();

  Future getCameraImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile.path);
      isImageShowing = true;
    });
  }

  Future getGalleryImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
      isImageShowing = true;
    });
  }

  Widget buildImageSelector() {
    return (
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: getCameraImage,
            child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.pink[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.pink[200],
                  blurRadius: 4,
                  offset: Offset(2, 2),
                )
              ],
            ),
            child: SizedBox(
              width: 210,
              child: Row(
                children: <Widget>[
                  Icon(Icons.camera_alt),
                  SizedBox(width: 10),
                  Text("Select Image from Camera", style: TextStyle(fontSize: 15),)
                ],
              ),
            ),
          ),
          ),
          SizedBox(height: 40),
          GestureDetector(
            onTap: getGalleryImage,
            child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.pink[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.pink[200],
                  blurRadius: 4,
                  offset: Offset(2, 2),
                )
              ],
            ),
            child: SizedBox(
              width: 210,
              child: Row(
                children: <Widget>[
                  Icon(Icons.image),
                  SizedBox(width: 10),
                  Text("Select Image from Gallery", style: TextStyle(fontSize: 15),)
                ],
              ),
            ),
          ),
          )
        ],
      )
    );
  }

  Widget buildImageSubmitAndResultDisplay() {
    return (Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FractionallySizedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: Image.file(_image),
          ),
          widthFactor: 0.74,
        ),
        SizedBox(height: 30),
        isPredictedLabelAvailable == true
            ? Text(predictedLabel, style: TextStyle(fontSize: 22),)
            : RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 13),
              child: Text(
                "Submit", 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17
                ),
              ),
              color: Colors.pink[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () => postImageToServer(_image),
            ),
      ],
    ));
  }

  Widget buildProgressIndicator() {
    return (Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Please Wait",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 15),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[100]),
          ),
        ],
      ),
    ));
  }

  void postImageToServer(File image) async {
    setState(() {
      isImagePosting = true;
      isImageShowing = false;
    });
    var stream = new http.ByteStream(Stream.castFrom(image.openRead()));
    var length = await image.length();
    var uri = Uri.parse(widget.postPath);

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('InputImg', stream, length,
        filename: basename(image.path));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response);

    response.stream.transform(utf8.decoder).listen((value) {
      setState(() {
        isImagePosting = false;
        isImageShowing = true;
        predictedLabel = value;
        isPredictedLabelAvailable = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.background), 
          fit: BoxFit.cover, 
        ),
      ),
      child: Scaffold(
        backgroundColor: widget.background == "assets/waves.jpg" ? Colors.white70 : Colors.white24,
        body: Center(
            child: isImagePosting == true
                ? buildProgressIndicator()
                : isImageShowing == true
                    ? buildImageSubmitAndResultDisplay()
                    : buildImageSelector()),
      ),
    );
  }
}
