import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewNewPdf extends StatefulWidget {
  final String pdfUrl;

  const ViewNewPdf({this.pdfUrl});

  @override
  _ViewNewPdfState createState() => _ViewNewPdfState();
}

class _ViewNewPdfState extends State<ViewNewPdf> {

  PdfViewerController _pdfViewerController;
  String uri = "";

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    uri = widget.pdfUrl;
    setState(() {

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('PDF'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_up,
              color: Colors.white,
            ),
            onPressed: () {
              _pdfViewerController.previousPage();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onPressed: () {
              _pdfViewerController.nextPage();
            },
          )
        ],
      ),
      body: SfPdfViewer.network(
        '$uri',
        controller: _pdfViewerController,
      ),
    );
  }
}
