import 'dart:io';

import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/loading_page.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlaySafe extends StatefulWidget {
  final String url;
  final String? title;
  final bool play;
  final String dataType;//数据源类型，本地local，网络net
  const VideoPlaySafe(this.url,{this.title,this.play=true,this.dataType="local",super.key});

  @override
  State<VideoPlaySafe> createState() => _VideoPlaySafeState();
}

class _VideoPlaySafeState extends State<VideoPlaySafe> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  Load load = Load.loading;
  @override
  void initState() {
    super.initState();
    if(widget.dataType=="net"){
      videoPlayerController=VideoPlayerController.networkUrl(Uri.parse(widget.url));
    }else{
      videoPlayerController=VideoPlayerController.file(File(widget.url));
    }
    initChewie();
  }
  Future<void> initChewie() async {
    await videoPlayerController!.initialize();
    chewieController=ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      looping: true,
        //是否显示action
      showOptions: true,
    );
    load=Load.finish;
    if(mounted){
      setState(() {});
    }
  }
  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(load==Load.loading){
      return Scaffold(
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        appBar: AppBar(),
        body: LoadingPage(),
      );
    }else{
      return Scaffold(
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        appBar: AppBarWidget(
          text: widget.title??"",
        ),
        body: Chewie(controller: chewieController!),
      );
    }
  }
}
