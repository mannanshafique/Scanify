import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Utility.dart';
import 'DBHelper.dart';
import 'Photo.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scanify',
      theme: ThemeData(primaryColor: Colors.blue, primarySwatch: Colors.blue),
      home: SaveImageDemoSQLite(),
    );
  }
}

class SaveImageDemoSQLite extends StatefulWidget {
  //
  SaveImageDemoSQLite() : super();

  final String title = "Flutter Save Image";

  @override
  _SaveImageDemoSQLiteState createState() => _SaveImageDemoSQLiteState();
}

class _SaveImageDemoSQLiteState extends State<SaveImageDemoSQLite> {
  //
  File imageFile;
  Image image;
  DBHelper dbHelper;
  List<Photo> images;

  @override
  void initState() {
    super.initState();
    images = [];
    dbHelper = DBHelper();
    refreshImages();
  }

  refreshImages() {
    dbHelper.getPhotos().then((imgs) {
      setState(() {
        images.clear();
        images.addAll(imgs);
      });
    });
  }

  pickImageFromGallery() {
    ImagePicker.pickImage(source: ImageSource.gallery).then((imgFile) async {
      File cropped = await ImageCropper.cropImage(
          sourcePath: imgFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.deepOrange,
              toolbarTitle: "Cropping",
              statusBarColor: Colors.deepOrange.shade900,
              backgroundColor: Colors.white));
      setState(() {
        imageFile = cropped;
      });
      String imgString = Utility.base64String(imageFile.readAsBytesSync());
      Photo photo = Photo(0, imgString);
      dbHelper.save(photo);
      refreshImages();
    });
  }

  gridView() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: images.map((photo) {
          return Utility.imageFromBase64String(photo.photo_name);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              pickImageFromGallery();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: gridView(),
            )
          ],
        ),
      ),
    );
  }
}

// import 'dart:io';

// import 'package:edge_detection/edge_detection.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Scanify',
//       theme: ThemeData(primaryColor: Colors.blue, primarySwatch: Colors.blue),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   //File _image;
//   String _image;
//   bool _loading = false;

//   // imagePickFromGallery() async {
//   //   var img = await ImagePicker.pickImage(source: ImageSource.gallery);
//   //   setState(() {
//   //     _image = img;
//   //   });
//   // }

//   // imagePickFromCamera() async {
//   //   var img = await ImagePicker.pickImage(source: ImageSource.camera);
//   //   setState(() {
//   //     _image = img;
//   //   });
//   // }

//   Future<void> initPlatformState() async {
//     String imagePath;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       imagePath = await EdgeDetection.detectEdge;
//     } on PlatformException {
//       imagePath = 'Failed to get cropped image path.';
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _image = imagePath;
//     });
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     initPlatformState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Scanify"),
//         centerTitle: true,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Center(
//             child: new Text('Cropped image path: $_image\n'),
//           ),
//           Row(
//             children: <Widget>[
//               //button("Gallery", initPlatformState),
//               //button("Camera", imagePickFromCamera),
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Widget button(String text, Function function) {
//     return MaterialButton(
//         elevation: 10.0,
//         child: Text(
//           text,
//           style: TextStyle(color: Colors.red),
//         ),
//         onPressed: function);
//   }
// }
