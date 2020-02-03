import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String assetPDFPath = "";

  @override
  void initState() {
    super.initState();

    getFileFromAsset("assets/mypdf.pdf").then((f) {
      setState(() {
        assetPDFPath = f.path;
        print(assetPDFPath);
      });
    });
  }

  Future<File> getFileFromAsset(String asset) async {
    try {
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mypdf.pdf");

      File assetFile = await file.writeAsBytes(bytes);
      return assetFile;
    }
    catch (e) {
      throw Exception("Error opening the magzine");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
           backgroundColor: Colors.blue,
          title: Text("UET Science Society Magazine"),
        ),
        body: Center(
          child: Builder(
            builder: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  color: Colors.blue,
                  child: Text("Read Now"),
                  onPressed: () {
                    if (assetPDFPath != null){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) =>
                             PdfViewPage(path: assetPDFPath)));
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PdfViewPage extends StatefulWidget {
  final String path;

  const PdfViewPage({Key key, this.path}) : super(key: key);
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  bool pdfReady = false;
  int _totalPages=0;
  int _currentPage = 0;
  PDFViewController _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Magazine 2019"),
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            autoSpacing: true,
            enableSwipe: true,
            pageSnap: true,
            swipeHorizontal: true,
            nightMode: false,
            onError: (e) {
              print(e);
            },
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages;
              pdfReady = true;
              });
            },
            onViewCreated: (PDFViewController vc) {
              _pdfViewController = vc;
            },
            onPageChanged: (int page, int total) {
              setState(() {});
            },
            onPageError: (page,e) {},
          ),


          !pdfReady
             ?Center(
                child: CircularProgressIndicator(),
              )
            :Offstage()
       ],
     ),
     floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _currentPage > 0
            ?FloatingActionButton.extended(
              backgroundColor: Colors.deepPurpleAccent,
              label: Text("Page ${_currentPage-1}"),
              onPressed: () {
                _currentPage -=1;
                _pdfViewController.setPage(_currentPage);
              },
            )
            :Offstage(),
            
          _currentPage < _totalPages
              ? FloatingActionButton.extended(
                backgroundColor: Colors.deepPurpleAccent,
                label: Text("Page ${_currentPage+1}"),
                onPressed: () {
                  _currentPage +=1;
                  _pdfViewController.setPage(_currentPage);
              },
            )
            :Offstage(),
          ],
        ),
    );
  }
}