import 'dart:typed_data';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class AssetView extends StatefulWidget {
  final int _index;
  final Asset _asset;

  AssetView(
    this._index,
    this._asset, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AssetState(this._index, this._asset);
}

class AssetState extends State<AssetView> {
  AssetState(_index, _asset);

  @override
  void initState() {
    super.initState();
    //clearMemoryImageCache();
  }

  @override
  void dispose() {
    super.dispose();
    // clearMemoryImageCache();
    // imageCache.clear();
  }

  Future<Uint8List> convertImage(asset) async {
    Uint8List a2;
    await asset.getByteData(quality: 100).then((val) {
      a2 = val.buffer.asUint8List();
    });
    return a2;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: convertImage(widget._asset), // a Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //ImageCache().clear();
            return ExtendedImage.memory(
              snapshot.data,
              clearMemoryCacheIfFailed: true,
              enableMemoryCache: false,
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Container();
        });
  }
}
