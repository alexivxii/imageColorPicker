// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
//
// List<CameraDescription> cameras;
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   cameras = await availableCameras();
//   runApp(CameraApp());
// }
//
// class CameraApp extends StatefulWidget {
//   @override
//   _CameraAppState createState() => _CameraAppState();
// }
//
// class _CameraAppState extends State<CameraApp> {
//   CameraController controller;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = CameraController(cameras[0], ResolutionPreset.max);
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     });
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
//
//
//   ///actual User Interface
//   @override
//   Widget build(BuildContext context) {
//
//     // Size _screenSize = MediaQuery.of(context).size;
//
//     if (!controller.value.isInitialized) {
//       return Container();
//     }
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Stack(
//         alignment: Alignment.center,
//           children: [
//             Positioned.fill(
//               child: new AspectRatio(
//                   aspectRatio: controller.value.aspectRatio,
//                   child: new CameraPreview(controller)),
//             ),
//             Positioned(
//               child: new GestureDetector(
//                 onTap: () {
//                   print("aaaa");
//                 },
//                 child: const Icon(
//                   Icons.close,
//                   color: Colors.grey,
//                   size: 30.0,
//                 ),
//               ),
//               top: 30.0,
//               right: 10.0,
//             ),
//           ],
//         ),
//     );
//   }
// }

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  String displayHex = "aaa";
  String displayColor = "0xffffffff";

  img.Image photo;

  void setImageBytes(imageBytes) {
    print("setImageBytes");
    List<int> values = imageBytes.buffer.asUint8List();
    photo = null;
    photo = img.decodeImage(values);
  }

  // image lib uses uses KML color format, convert #AABBGGRR to regular #AARRGGBB
  int abgrToArgb(int argbColor) {
    print("abgrToArgb");
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

  // FUNCTION

  Future<Color> _getColor(String path) async {
    print("_getColor");

    // data =
    //       (await NetworkAssetBundle(
    //           Uri.parse(coverData)).load(coverData))
    //           .buffer
    //           .asUint8List();

    File image = File(path);
    await image.readAsBytes().then((value){
     final Uint8List data = Uint8List.fromList(value);

     print("setImageBytes....");
     setImageBytes(data);

//FractionalOffset(1.0, 0.0); //represents the top right of the [Size].
      double px = 240.0;
      double py = 360.0;
      print("asta e pixelu ${photo.getPixel(px.toInt(), py.toInt())}");
      int pixel32 = photo.getPixel(px.toInt(), py.toInt());
      int hex = abgrToArgb(pixel32);
      print("asta e pixelu hex");
      print(hex.toRadixString(16));
      // print("asta e pixelu hex ${photo.getPixel(px.toInt(), py.toInt()).toRadixString(16)}");
      int a = photo.height;
      int b = photo.width;
      print("Height is: $a and width is $b");

      // int pixel32 = photo.getPixelSafe(1,0 );
      // // int pixel32 = photo.getPixelSafe(b/2,a/2);
      // int hex = abgrToArgb(pixel32);
      // print("Value of int: $hex ");
      // print("value in hex: ${hex.toRadixString(16)}");

      setState(() {
        displayHex = hex.toRadixString(16);
        displayColor = displayHex.replaceAll('ff', '0xff');
      });

      return Color(hex);

    });
    // final ByteData bytes = image.toByteData();
    // final Uint8List data = bytes.buffer.asUint8List();

//     print("setImageBytes....");
//     setImageBytes(data);
//
// //FractionalOffset(1.0, 0.0); //represents the top right of the [Size].
//     double px = 1.0;
//     double py = 0.0;
//
//     int pixel32 = photo.getPixelSafe(px.toInt(), py.toInt());
//     int hex = abgrToArgb(pixel32);
//     print("Value of int: $hex ");
//
//     return Color(hex);
  }






  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              alignment: Alignment.center,
              children: [
              Positioned.fill(
              child: new AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: new CameraPreview(_controller)),
            ),
            Positioned(
              top:30,
              left: 20,
                child: Text(displayHex, style: TextStyle(color: Color(int.parse(displayColor))),),
            ),
            Positioned(
              child: new GestureDetector(
                onTap: () {
                  print("aaaa");
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.grey,
                  size: 30.0,
                ),
              ),
              top: MediaQuery.of(context).size.height/3.1,
              right: MediaQuery.of(context).size.width/2,
            ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            // If the picture was taken, display it on a new screen.
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => DisplayPictureScreen(
            //       // Pass the automatically generated path to
            //       // the DisplayPictureScreen widget.
            //       imagePath: image?.path,
            //     ),
            //   ),
            // );

            _getColor(image?.path);

          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
