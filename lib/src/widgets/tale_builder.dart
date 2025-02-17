import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:trip_tales/src/constants/color.dart';
import 'package:trip_tales/src/constants/memory_card_info.dart';
import 'package:trip_tales/src/constants/memory_card_type.dart';
import 'package:trip_tales/src/pages/tale.dart';
import 'package:trip_tales/src/utils/app_manager.dart';
import 'package:trip_tales/src/utils/dynamic_stack.dart';
import 'package:trip_tales/src/utils/text_utils.dart';
import 'package:trip_tales/src/widgets/memory_card.dart';

import '../models/card_model.dart';
import '../services/card_service.dart';
import '../utils/device_info.dart';

class TaleBuilder extends StatefulWidget {
  final Function callback;
  final bool isEditMode;
  final bool reload;
  final Key taleKey;

  const TaleBuilder(
      {
      required this.callback,
      required this.isEditMode,
      required this.reload,
      required this.taleKey});

  @override
  _TaleBuilderState createState() => _TaleBuilderState();
}

class _TaleBuilderState extends State<TaleBuilder>
    with TickerProviderStateMixin {
  final CardService _cardService = Get.find<CardService>();
  final AppManager _appManager = Get.put(AppManager());
  List<ValueKey> _widgetKeyList = List<ValueKey>.empty(growable: true);
  List<ValueKey> _widgetSuperKeyList = List<ValueKey>.empty(growable: true);
  double containerTop = 0.0;
  double containerLeft = 0.0;
  final ScrollController _scrollController = ScrollController();
  bool isDragging = false;

  // late final AnimationController _controller;
  // late final AnimationController _controller_place_here;
  late Future<List<CardModel?>> cards;

  Size containersSize = Size(300, 300);

  static int numOfCards = 0;

  // @override
  // void didUpdateWidget(covariant TaleBuilder oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //
  //   print("sadawdwadawwdafdw HHHHHHHHHHHEEEEEEEEEEEE");
  //   setState(() {
  //     cards = _cardService.getCards(_appManager.getCurrentUser());
  //   });
  //   // for(int i = 0; i <
  //   //     print(cards.then((value) => print(value.nam)));)
  // }

  @override
  void initState() {
    super.initState();
    // print("YYYYYYYYYYYYYYYYYYYYYYYYYYYY HHHHHHHHHHHEEEEEEEEEEEE");
    setState(() {
      cards = _cardService.getCards(_appManager.getCurrentTaleId());
    });

    _scrollController.addListener(() {
      if (isDragging) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
      else {

      }
    });
    // _controller = AnimationController(vsync: this);
    // _controller_place_here = AnimationController(vsync: this);
    // for (int i = 0; i < numOfCards; i++) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) => _getWidgetInfo(i));
    // }
  }

  // void _getWidgetInfo(int widgetId) {
  //   // print("------------$widgetId------------");
  //   GlobalKey widgetKey = _widgetKeyList[widgetId];
  //   final RenderBox renderBox =
  //       widgetKey.currentContext?.findRenderObject() as RenderBox;
  //   widgetKey.currentContext?.size;
  //
  //   final Size size = renderBox.size;
  //   print('Size: ${size.width}, ${size.height}');
  //
  //   final Offset offset = renderBox.localToGlobal(Offset.zero);
  //   print('Offset: ${offset.dx}, ${offset.dy}');
  //   print(
  //       'Position: ${(offset.dx + size.width) / 2}, ${(offset.dy + size.height) / 2}');
  // }

  @override
  void dispose() {
    _widgetKeyList = List.empty();
    _widgetSuperKeyList = List.empty();
    super.dispose();
  }


  bool isDraggingWithinTaleBuilder(bool isDrag) {
    isDragging = isDrag;
    return isDragging;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reload) {
      setState(() {
        cards = _cardService.getCards(_appManager.getCurrentTaleId());
        // print("######################${cards}");
      });
    }
    DeviceInfo device = DeviceInfo();
    device.computeDeviceInfo(context);
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return FutureBuilder<List<CardModel?>>(
      key: widget.taleKey,
      future: cards,
      builder:
          (BuildContext context, AsyncSnapshot<List<CardModel?>> snapshot) {
        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
          List<CardModel?> data = [];
          data = snapshot.data!;
          _appManager.setCards(data);
          numOfCards = data.length;
          print("###########${numOfCards}");
          _widgetKeyList = List.empty(growable: true);
          for (int i = 0; i < numOfCards; i++) {
            var translation = data[i]!.transform.getTranslation();
            data[i]!.transform.setTranslationRaw(translation.x * device.width, translation.y, translation.z);
            _widgetKeyList.add(ValueKey(i +
                data[i]!.name.codeUnits.fold<int>(
                    0,
                    (previousValue, element) =>
                        previousValue * 256 + element)));
          }

          _widgetSuperKeyList = List.empty(growable: true);
          for (int i = 0; i < numOfCards; i++) {
            _widgetSuperKeyList.add(ValueKey(500 + i +
                data[i]!.name.codeUnits.fold<int>(
                    0,
                        (previousValue, element) =>
                    previousValue * 256 + element)));
          }

          return Container(
            height: device.height * 10,
            width: device.width,
            child: DynamicStack(
              children: [
                for (int i = 0; i < numOfCards; i++)
                  if (data[i]!.type == MemoryCardType.image)
                    MemoryCard(
                        key: _widgetSuperKeyList[i],
                        isEditable: widget.isEditMode,
                        callback: widget.callback,
                        onDragStateChanged: (isDrag) => {
                          isDragging = isDrag,
                        },
                        name: data[i]!.name,
                        // cardKey: _widgetKeyList[i],
                        size: device.isTablet ? isLandscape ? containersSize * 1.4 : containersSize * 1.2 : containersSize,
                        order: data[i]!.order,
                        type: MemoryCardType.image,
                        initTransform: data[i]!.transform,
                        imagePath: data[i]!.path)
                  else if (data[i]!.type == MemoryCardType.video)
                    MemoryCard(
                        key: _widgetSuperKeyList[i],
                        isEditable: widget.isEditMode,
                        callback: widget.callback,
                        onDragStateChanged: (isDrag) => {
                          isDragging = isDrag,
                        },
                        name: data[i]!.name,
                        // cardKey: _widgetKeyList[i],
                        size: device.isTablet ? isLandscape ? containersSize * 1.4 : containersSize * 1.2 : containersSize,
                        order: data[i]!.order,
                        type: MemoryCardType.video,
                        initTransform: data[i]!.transform,
                        videoPath: data[i]!.path)
                  else if (data[i]!.type == MemoryCardType.text)
                      MemoryCard(
                        key: _widgetSuperKeyList[i],
                        isEditable: widget.isEditMode,
                        callback: widget.callback,
                        onDragStateChanged: (isDrag) => {
                          isDragging = isDrag,
                        },
                        name: data[i]!.name,
                        // cardKey: _widgetKeyList[i],
                        size: device.isTablet ? isLandscape ? containersSize * 1.4 : containersSize * 1.2 : containersSize,
                        order: data[i]!.order,
                        type: MemoryCardType.text,
                        initTransform: data[i]!.transform,
                        text: data[i]!.text,
                        textColor: data[i]!.textColor,
                        textBackgroundColor: data[i]!.textBackgroundColor,
                        textDecoration: data[i]!.textDecoration,
                        fontStyle: data[i]!.fontStyle,
                        fontWeight: data[i]!.fontWeight,
                        fontSize: data[i]!.fontSize,
                      )

                // MemoryCard(cardKey: _widgetKeyList[0], order: 1, type: MemoryCardType.image, initTransform: Matrix4.identity(), imagePath: "https://picsum.photos/200/300", size: containersSize[0]),
                // MemoryCard(cardKey: _widgetKeyList[1], order: 3, type: MemoryCardType.image, initTransform: Matrix4.identity(), imagePath: "https://picsum.photos/900/500", size: containersSize[1]),
                // MemoryCard(cardKey: _widgetKeyList[2], order: 2, type: MemoryCardType.video, initTransform: Matrix4.identity(), size: containersSize[2]),
                // MemoryCard(cardKey: _widgetKeyList[3], order: 0, type: MemoryCardType.text, initTransform: Matrix4.identity(), size: containersSize[2]),
                // MemoryCard(cardKey: _widgetKeyList[3], type: MemoryCardType.text,),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          // print(snapshot.error);
          return Text("Error: ${snapshot.error}");
        } else {
          return Container();
        }
      },
    );
  }
}
