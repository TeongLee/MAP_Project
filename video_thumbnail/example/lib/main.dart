/* import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DemoHome(),
    );
  }
}

class ThumbnailRequest {
  final String video;
  final String thumbnailPath;
  final ImageFormat imageFormat;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;

  const ThumbnailRequest(
      {this.video,
      this.thumbnailPath,
      this.imageFormat,
      this.maxHeight,
      this.maxWidth,
      this.timeMs,
      this.quality});
}

class ThumbnailResult {
  final Image image;
  final int dataSize;
  final int height;
  final int width;
  const ThumbnailResult({this.image, this.dataSize, this.height, this.width});
}

Future<ThumbnailResult> genThumbnail(ThumbnailRequest r) async {
  //WidgetsFlutterBinding.ensureInitialized();
  Uint8List bytes;
  final Completer<ThumbnailResult> completer = Completer();
  if (r.thumbnailPath != null) {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: r.video,
        headers: {
          "USERHEADER1": "user defined header1",
          "USERHEADER2": "user defined header2",
        },
        thumbnailPath: r.thumbnailPath,
        imageFormat: r.imageFormat,
        maxHeight: r.maxHeight,
        maxWidth: r.maxWidth,
        timeMs: r.timeMs,
        quality: r.quality);

    print("thumbnail file is located: $thumbnailPath");

    final file = File(thumbnailPath);
    bytes = file.readAsBytesSync();
  } else {
    bytes = await VideoThumbnail.thumbnailData(
        video: r.video,
        headers: {
          "USERHEADER1": "user defined header1",
          "USERHEADER2": "user defined header2",
        },
        imageFormat: r.imageFormat,
        maxHeight: r.maxHeight,
        maxWidth: r.maxWidth,
        timeMs: r.timeMs,
        quality: r.quality);
  }

  int _imageDataSize = bytes.length;
  print("image size: $_imageDataSize");

  final _image = Image.memory(bytes);
  _image.image
      .resolve(ImageConfiguration())
      .addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(ThumbnailResult(
      image: _image,
      dataSize: _imageDataSize,
      height: info.image.height,
      width: info.image.width,
    ));
  }));
  return completer.future;
}

class GenThumbnailImage extends StatefulWidget {
  final ThumbnailRequest thumbnailRequest;

  const GenThumbnailImage({Key key, this.thumbnailRequest}) : super(key: key);

  @override
  _GenThumbnailImageState createState() => _GenThumbnailImageState();
}

class _GenThumbnailImageState extends State<GenThumbnailImage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThumbnailResult>(
      future: genThumbnail(widget.thumbnailRequest),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final _image = snapshot.data.image;
          final _width = snapshot.data.width;
          final _height = snapshot.data.height;
          final _dataSize = snapshot.data.dataSize;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                    "Image ${widget.thumbnailRequest.thumbnailPath == null ? 'data size' : 'file size'}: $_dataSize, width:$_width, height:$_height"),
              ),
              Container(
                color: Colors.grey,
                height: 1.0,
              ),
              _image,
            ],
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.red,
            child: Text(
              "Error:\n${snapshot.error.toString()}",
            ),
          );
        } else {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                    "Generating the thumbnail for: ${widget.thumbnailRequest.video}..."),
                SizedBox(
                  height: 10.0,
                ),
                CircularProgressIndicator(),
              ]);
        }
      },
    );
  }
}

class ImageInFile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class DemoHome extends StatefulWidget {
  @override
  _DemoHomeState createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  final _editNode = FocusNode();
  final _video = TextEditingController(
      text:
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4");
  ImageFormat _format = ImageFormat.JPEG;
  int _quality = 50;
  int _sizeH = 0;
  int _sizeW = 0;
  int _timeMs = 0;

  GenThumbnailImage _futreImage;

  String _tempDir;

  @override
  void initState() {
    super.initState();
    getTemporaryDirectory().then((d) => _tempDir = d.path);
  }

  @override
  Widget build(BuildContext context) {
    final _settings = <Widget>[
      Slider(
        value: _sizeH * 1.0,
        onChanged: (v) => setState(() {
          _editNode.unfocus();
          _sizeH = v.toInt();
        }),
        max: 256.0,
        divisions: 256,
        label: "$_sizeH",
      ),
      Center(
        child: (_sizeH == 0)
            ? const Text(
                "Original of the video's height or scaled by the source aspect ratio")
            : Text("Max height: $_sizeH(px)"),
      ),
      Slider(
        value: _sizeW * 1.0,
        onChanged: (v) => setState(() {
          _editNode.unfocus();
          _sizeW = v.toInt();
        }),
        max: 256.0,
        divisions: 256,
        label: "$_sizeW",
      ),
      Center(
        child: (_sizeW == 0)
            ? const Text(
                "Original of the video's width or scaled by source aspect ratio")
            : Text("Max width: $_sizeW(px)"),
      ),
      Slider(
        value: _timeMs * 1.0,
        onChanged: (v) => setState(() {
          _editNode.unfocus();
          _timeMs = v.toInt();
        }),
        max: 10.0 * 1000,
        divisions: 1000,
        label: "$_timeMs",
      ),
      Center(
        child: (_timeMs == 0)
            ? const Text("The beginning of the video")
            : Text("The closest frame at $_timeMs(ms) of the video"),
      ),
      Slider(
        value: _quality * 1.0,
        onChanged: (v) => setState(() {
          _editNode.unfocus();
          _quality = v.toInt();
        }),
        max: 100.0,
        divisions: 100,
        label: "$_quality",
      ),
      Center(child: Text("Quality: $_quality")),
      Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 10.0, 2.0, 8.0),
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            isDense: true,
            labelText: "Thumbnail Format",
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Radio<ImageFormat>(
                      groupValue: _format,
                      value: ImageFormat.JPEG,
                      onChanged: (v) => setState(() {
                        _format = v;
                        _editNode.unfocus();
                      }),
                    ),
                    const Text("JPEG"),
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Radio<ImageFormat>(
                      groupValue: _format,
                      value: ImageFormat.PNG,
                      onChanged: (v) => setState(() {
                        _format = v;
                        _editNode.unfocus();
                      }),
                    ),
                    const Text("PNG"),
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Radio<ImageFormat>(
                      groupValue: _format,
                      value: ImageFormat.WEBP,
                      onChanged: (v) => setState(() {
                        _format = v;
                        _editNode.unfocus();
                      }),
                    ),
                    const Text("WebP"),
                  ]),
            ],
          ),
        ),
      )
    ];
    return Scaffold(
        appBar: AppBar(
          title: const Text('Thumbnail Plugin example'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 10.0, 2.0, 8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  isDense: true,
                  labelText: "Video URI",
                ),
                maxLines: null,
                controller: _video,
                focusNode: _editNode,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  _editNode.unfocus();
                },
              ),
            ),
            for (var i in _settings) i,
            Expanded(
              child: Container(
                color: Colors.grey[300],
                child: Scrollbar(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      (_futreImage != null) ? _futreImage : SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              AppBar(
                title: const Text("Settings"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              for (var i in _settings) i,
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () async {
                File video =
                    await ImagePicker.pickVideo(source: ImageSource.camera);
                setState(() {
                  _video.text = video.path;
                });
              },
              child: Icon(Icons.videocam),
              tooltip: "Capture a video",
            ),
            const SizedBox(
              width: 5.0,
            ),
            FloatingActionButton(
              onPressed: () async {
                File video =
                    await ImagePicker.pickVideo(source: ImageSource.gallery);
                setState(() {
                  _video.text = video?.path;
                });
              },
              child: Icon(Icons.local_movies),
              tooltip: "Pick a video",
            ),
            const SizedBox(
              width: 20.0,
            ),
            FloatingActionButton(
              tooltip: "Generate a data of thumbnail",
              onPressed: () async {
                setState(() {
                  _futreImage = GenThumbnailImage(
                      thumbnailRequest: ThumbnailRequest(
                          video: _video.text,
                          thumbnailPath: null,
                          imageFormat: _format,
                          maxHeight: _sizeH,
                          maxWidth: _sizeW,
                          timeMs: _timeMs,
                          quality: _quality));
                });
              },
              child: const Text("Data"),
            ),
            const SizedBox(
              width: 5.0,
            ),
            FloatingActionButton(
              tooltip: "Generate a file of thumbnail",
              onPressed: () async {
                setState(() {
                  _futreImage = GenThumbnailImage(
                      thumbnailRequest: ThumbnailRequest(
                          video: _video.text,
                          thumbnailPath: _tempDir,
                          imageFormat: _format,
                          maxHeight: _sizeH,
                          maxWidth: _sizeW,
                          timeMs: _timeMs,
                          quality: _quality));
                });
              },
              child: const Text("File"),
            ),
          ],
        ));
  }
}
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DemoHome(),
    );
  }
}

///
/// 定义一个请求结构体（启用空安全）
///
class ThumbnailRequest {
  final String video; // 必须传入视频地址
  final String? thumbnailPath; // 可选保存路径
  final ImageFormat? imageFormat; 
  final int? maxHeight;
  final int? maxWidth;
  final int? timeMs;
  final int? quality;

  const ThumbnailRequest({
    required this.video,
    this.thumbnailPath,
    this.imageFormat,
    this.maxHeight,
    this.maxWidth,
    this.timeMs,
    this.quality,
  });
}

///
/// 生成缩略图后的结果
///
class ThumbnailResult {
  final Image image;
  final int dataSize;
  final int height;
  final int width;

  const ThumbnailResult({
    required this.image,
    required this.dataSize,
    required this.height,
    required this.width,
  });
}

///
/// 生成缩略图的核心逻辑
///

Future<ThumbnailResult> genThumbnail(ThumbnailRequest r) async {
  // Will hold either the file bytes or the in-memory bytes
  Uint8List bytes;

  // Generate thumbnail into a file if a path was provided...
  if (r.thumbnailPath != null) {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: r.video,
      headers: {
        "USERHEADER1": "user defined header1",
        "USERHEADER2": "user defined header2",
      },
      thumbnailPath: r.thumbnailPath!,               // non-null here
      imageFormat: r.imageFormat ?? ImageFormat.JPEG,
      maxHeight: r.maxHeight ?? 0,                    // unwrap to int
      maxWidth:  r.maxWidth  ?? 0,
      timeMs:    r.timeMs    ?? 0,
      quality:   r.quality   ?? 50,
    );

    if (thumbnailPath == null) {
      throw Exception("生成缩略图文件失败，thumbnailPath == null");
    }

    bytes = await File(thumbnailPath).readAsBytes();
    debugPrint("thumbnail file is located: $thumbnailPath");
  } 
  // ...otherwise return raw bytes
  else {
    final data = await VideoThumbnail.thumbnailData(
      video: r.video,
      headers: {
        "USERHEADER1": "user defined header1",
        "USERHEADER2": "user defined header2",
      },
      imageFormat: r.imageFormat ?? ImageFormat.JPEG,
      maxHeight: r.maxHeight ?? 0,
      maxWidth:  r.maxWidth  ?? 0,
      timeMs:    r.timeMs    ?? 0,
      quality:   r.quality   ?? 50,
    );

    if (data == null) {
      throw Exception("生成缩略图二进制数据失败，bytes == null");
    }
    bytes = data;
  }

  // At this point `bytes` is guaranteed non-null
  final imageDataSize = bytes.length;
  debugPrint("image size: $imageDataSize bytes");

  // Build the Image widget
  final imageWidget = Image.memory(bytes);

  // Use a Completer to grab width/height once decoded
  final completer = Completer<ThumbnailResult>();
  imageWidget.image
      .resolve(const ImageConfiguration())
      .addListener(ImageStreamListener((info, _) {
    completer.complete(ThumbnailResult(
      image: imageWidget,
      dataSize: imageDataSize,
      height: info.image.height,
      width: info.image.width,
    ));
  }));

  return completer.future;
}


///
/// 生成缩略图的 Widget，使用 FutureBuilder 来异步显示
///
class GenThumbnailImage extends StatefulWidget {
  final ThumbnailRequest thumbnailRequest;

  const GenThumbnailImage({Key? key, required this.thumbnailRequest})
      : super(key: key);

  @override
  State<GenThumbnailImage> createState() => _GenThumbnailImageState();
}

class _GenThumbnailImageState extends State<GenThumbnailImage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThumbnailResult>(
      future: genThumbnail(widget.thumbnailRequest),
      builder: (BuildContext context, AsyncSnapshot<ThumbnailResult> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("正在生成缩略图..."),
              SizedBox(height: 10.0),
              CircularProgressIndicator(),
            ],
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.red,
            child: Text("Error:\n${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          final width = data.width;
          final height = data.height;
          final dataSize = data.dataSize;
          final isFileMode = (widget.thumbnailRequest.thumbnailPath != null);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Image ${isFileMode ? 'file size' : 'data size'}: "
                "$dataSize bytes, width:$width, height:$height",
              ),
              const Divider(color: Colors.grey),
              data.image,
            ],
          );
        } else {
          // 不太可能到这儿，理论上上面分支都覆盖了
          return const SizedBox();
        }
      },
    );
  }
}

class DemoHome extends StatefulWidget {
  const DemoHome({Key? key}) : super(key: key);

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  final _editNode = FocusNode();
  final _videoCtrl = TextEditingController(
    text: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
  );

  ImageFormat _format = ImageFormat.JPEG;
  int _quality = 50;
  int _sizeH = 0;
  int _sizeW = 0;
  int _timeMs = 0;

  GenThumbnailImage? _futureImage;
  String? _tempDir;

  @override
  void initState() {
    super.initState();
    _initTempDir();
  }

  Future<void> _initTempDir() async {
    final dir = await getTemporaryDirectory();
    setState(() {
      _tempDir = dir.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsWidgets = <Widget>[
      // 选择最大高度
      Slider(
        value: _sizeH.toDouble(),
        onChanged: (v) {
          setState(() {
            _editNode.unfocus();
            _sizeH = v.toInt();
          });
        },
        max: 256.0,
        divisions: 256,
        label: "$_sizeH",
      ),
      Center(
        child: (_sizeH == 0)
            ? const Text("原视频高度或按源视频宽高比进行缩放")
            : Text("Max height: $_sizeH(px)"),
      ),
      // 选择最大宽度
      Slider(
        value: _sizeW.toDouble(),
        onChanged: (v) {
          setState(() {
            _editNode.unfocus();
            _sizeW = v.toInt();
          });
        },
        max: 256.0,
        divisions: 256,
        label: "$_sizeW",
      ),
      Center(
        child: (_sizeW == 0)
            ? const Text("原视频宽度或按源视频宽高比进行缩放")
            : Text("Max width: $_sizeW(px)"),
      ),
      // 选择时间点
      Slider(
        value: _timeMs.toDouble(),
        onChanged: (v) {
          setState(() {
            _editNode.unfocus();
            _timeMs = v.toInt();
          });
        },
        max: 10.0 * 1000,
        divisions: 1000,
        label: "$_timeMs",
      ),
      Center(
        child: (_timeMs == 0)
            ? const Text("视频开始处")
            : Text("在 $_timeMs(ms) 处取最近的一帧"),
      ),
      // 选择质量
      Slider(
        value: _quality.toDouble(),
        onChanged: (v) {
          setState(() {
            _editNode.unfocus();
            _quality = v.toInt();
          });
        },
        max: 100.0,
        divisions: 100,
        label: "$_quality",
      ),
      Center(child: Text("Quality: $_quality")),
      // 选择输出格式
      Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 10.0, 2.0, 8.0),
        child: InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            isDense: true,
            labelText: "Thumbnail Format",
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Radio<ImageFormat>(
                    groupValue: _format,
                    value: ImageFormat.JPEG,
                    onChanged: (v) {
                      setState(() {
                        _format = v ?? ImageFormat.JPEG;
                        _editNode.unfocus();
                      });
                    },
                  ),
                  const Text("JPEG"),
                ],
              ),
              Row(
                children: <Widget>[
                  Radio<ImageFormat>(
                    groupValue: _format,
                    value: ImageFormat.PNG,
                    onChanged: (v) {
                      setState(() {
                        _format = v ?? ImageFormat.JPEG;
                        _editNode.unfocus();
                      });
                    },
                  ),
                  const Text("PNG"),
                ],
              ),
              Row(
                children: <Widget>[
                  Radio<ImageFormat>(
                    groupValue: _format,
                    value: ImageFormat.WEBP,
                    onChanged: (v) {
                      setState(() {
                        _format = v ?? ImageFormat.JPEG;
                        _editNode.unfocus();
                      });
                    },
                  ),
                  const Text("WebP"),
                ],
              ),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thumbnail Plugin Example'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              title: const Text("Settings"),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: settingsWidgets,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          // 视频 URI
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 10.0, 2.0, 8.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                isDense: true,
                labelText: "Video URI",
              ),
              maxLines: null,
              controller: _videoCtrl,
              focusNode: _editNode,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                _editNode.unfocus();
              },
            ),
          ),
          // 参数设置
          ...settingsWidgets,
          // 生成结果显示
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    if (_futureImage != null) _futureImage!,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // 拍摄视频
          FloatingActionButton(
            heroTag: "btnCamera",
            onPressed: () async {
              final picker = ImagePicker();
              final XFile? pickedVideo = await picker.pickVideo(
                source: ImageSource.camera,
              );
              if (pickedVideo != null) {
                setState(() {
                  _videoCtrl.text = pickedVideo.path;
                });
              }
            },
            tooltip: "Capture a video",
            child: const Icon(Icons.videocam),
          ),
          const SizedBox(width: 5.0),
          // 从相册选择视频
          FloatingActionButton(
            heroTag: "btnGallery",
            onPressed: () async {
              final picker = ImagePicker();
              final XFile? pickedVideo = await picker.pickVideo(
                source: ImageSource.gallery,
              );
              if (pickedVideo != null) {
                setState(() {
                  _videoCtrl.text = pickedVideo.path;
                });
              }
            },
            tooltip: "Pick a video",
            child: const Icon(Icons.local_movies),
          ),
          const SizedBox(width: 20.0),
          // 生成内存数据
          FloatingActionButton(
            heroTag: "btnData",
            tooltip: "Generate a data thumbnail",
            onPressed: () async {
              setState(() {
                _futureImage = GenThumbnailImage(
                  thumbnailRequest: ThumbnailRequest(
                    video: _videoCtrl.text,
                    thumbnailPath: null, // 不指定文件路径 => 直接返回数据
                    imageFormat: _format,
                    maxHeight: _sizeH == 0 ? null : _sizeH,
                    maxWidth: _sizeW == 0 ? null : _sizeW,
                    timeMs: _timeMs == 0 ? null : _timeMs,
                    quality: _quality,
                  ),
                );
              });
            },
            child: const Text("Data"),
          ),
          const SizedBox(width: 5.0),
          // 生成文件
          FloatingActionButton(
            heroTag: "btnFile",
            tooltip: "Generate a file thumbnail",
            onPressed: () async {
              if (_tempDir == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("临时目录还没准备好，请稍后重试。"),
                  ),
                );
                return;
              }
              setState(() {
                _futureImage = GenThumbnailImage(
                  thumbnailRequest: ThumbnailRequest(
                    video: _videoCtrl.text,
                    thumbnailPath: _tempDir, // 指定文件保存目录
                    imageFormat: _format,
                    maxHeight: _sizeH == 0 ? null : _sizeH,
                    maxWidth: _sizeW == 0 ? null : _sizeW,
                    timeMs: _timeMs == 0 ? null : _timeMs,
                    quality: _quality,
                  ),
                );
              });
            },
            child: const Text("File"),
          ),
        ],
      ),
    );
  }
}
