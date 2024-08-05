import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Home> {
  final _record = Record();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final TextEditingController _controller = TextEditingController();

  Timer? _timer;
  int _time = 0;
  bool _isrecording = true;
  String? _audioPath;

  @override
  void initState() {
    requestPermission();
    super.initState();
  }

  requestPermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        _time++;
      });
    });
  }

  Future<void> _start() async {
    try {
      if (await _record.hasPermission()) {
        Directory? _dir;

        if (Platform.isIOS) {
          _dir = await getApplicationDocumentsDirectory();
        } else {
          _dir = Directory('/storage/emulated/0/Download/');
          if (!await _dir.exists())
            _dir = (await getExternalStorageDirectory());
        }
        await _record.start(path: '${_dir?.path}${_controller.text}.m4a');
      }
    } catch (e) {
      log(e.toString() as num);
    }
  }

  Future<void> _stop() async {
    final path = await _record.stop();
    _audioPath = path;
    if (_audioPath?.isNotEmpty ?? false) {
      log((path ?? "") as num);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _record.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 500,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    icon: Image.asset("images/logo.png"),
                    onPressed: () {
                      if (_isrecording) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 150,
                                    width: 350,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(20),
                                          height: 50,
                                          child: Material(
                                            child: TextField(
                                              controller: _controller,
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              decoration: const InputDecoration(
                                                  isDense: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                      EdgeInsets.all(12)),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 80,
                                            color: Colors.blue,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            if (_controller.text.isNotEmpty) {
                                              _start();
                                              _startTimer();
                                              setState(() {
                                                _isrecording = false;
                                              });
                                            }
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 80,
                                            color: Colors.blue,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              "Save",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            });
                      } else {
                        _stop();
                        _timer?.cancel();
                        setState(() {
                          _isrecording = true;
                          _time = 0;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
