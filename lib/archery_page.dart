import 'dart:ffi';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_animation/main.dart';
import 'package:pull_animation/skelton_item.dart';
import 'package:rive/rive.dart';

class Archery_Page extends StatefulWidget {
  const Archery_Page({super.key});

  @override
  State<Archery_Page> createState() => _Archery_PageState();
}

class _Archery_PageState extends State<Archery_Page> {
  int _count = 10;
  late EasyRefreshController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EasyRefresh(
        controller: _controller,
        header: const ArcheryHeader(
          position: IndicatorPosition.locator,
          processedDuration: Duration(seconds: 1),
        ),
        onRefresh: ()async{
          await Future.delayed(const Duration(seconds: 2));
          if(!mounted){
            return;
          }
          setState(() {
            _count = 10;
          });
          _controller.finishRefresh();
          _controller.resetFooter();
        },
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text('Shooting practice'),
              pinned: true,
            ),
            const HeaderLocator.sliver(),
            SliverList(
              delegate: SliverChildBuilderDelegate(
              (context,index){
                return const SkeletonItem();
              },
              childCount:_count,
              
            ))
          ],
        ),
        ),
      );
  }
}

class ArcheryHeader extends Header{
  const ArcheryHeader({
    super.clamping = false,
    super.triggerOffset = kDefaultArcheryTriggerOffset,
    super.position = IndicatorPosition.above,
    super.processedDuration = Duration.zero,
    super.springRebound = false,
    super.hapticFeedback = false,
    super.safeArea = false,
    super.spring,
    super.readySpringBuilder,
    super.frictionFactor,
    super.hitOver,
    super.infiniteHitOver,
  });

  @override
  Widget build(BuildContext context,IndicatorState state){
    return _ArcheryIndicator(
      state:state,
      reverse:state.reverse
    );

  }
}

class _ArcheryIndicator extends StatefulWidget {
  final IndicatorState state;
  final bool reverse;

  const _ArcheryIndicator({Key? key,
  required this.state,
  required this.reverse}) : super(key: key);

  @override
  State<_ArcheryIndicator> createState() => __ArcheryIndicatorState();
}

class __ArcheryIndicatorState extends State<_ArcheryIndicator> {
  double get _offset => widget.state.offset;
  IndicatorMode get _mode => widget.state.mode;
  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  SMINumber? pull;
  SMITrigger? advance;
  StateMachineController? controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.state.notifier.addModeChangeListener(_onModeChange);
    _loadRiveFile();
  }

  RiveFile? _riveFile;
  void _loadRiveFile(){
    rootBundle.load('asset/pull_to_refresh_use_case.riv').then(
      (data) async{
        setState((){
          _riveFile = RiveFile.import(data);
        });
      }
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    controller?.dispose();
    super.dispose();
  }

  void _onModeChange(IndicatorMode mode, double offset){
    switch(mode){
      case IndicatorMode.drag:
      controller?.isActive = true;
      case IndicatorMode.ready:
      advance?.fire();
      case IndicatorMode.processed:
      advance?.fire();
      default:
      break; 
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_mode == IndicatorMode.drag || _mode == IndicatorMode.armed){
      final percentage = (_offset / _actualTriggerOffset).clamp(0.0, 1.1)*100;
      pull?.value = percentage;
    }
    return SizedBox(
      width: double.infinity,
      height: _offset,
      child: Visibility(
        visible: (_offset > 0 && _riveFile != null),
        child: RiveAnimation.direct(_riveFile!,
        artboard: 'Bullseye',
        fit: BoxFit.cover,
        onInit: (artboard){
          controller = StateMachineController.fromArtboard(artboard, 'numberSimulation')!;
          controller?.isActive = false;
          if(controller == null){
            throw Exception('Unable to initialize state machine controller');
          }
          artboard.addController(controller!);
          pull = controller!.findInput<double>('pull') as SMINumber;
          advance = controller!.findInput<bool>('advance') as SMITrigger;
        },
        ),
      ),
    );
  }
}