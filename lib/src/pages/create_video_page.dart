import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:trip_tales/src/screen/set_photo_screen.dart';
import 'package:trip_tales/src/utils/validator.dart';
import '../constants/color.dart';
import '../constants/error_messages.dart';
import '../constants/memory_card_type.dart';
import '../controllers/media_controller.dart';
import '../models/card_model.dart';
import '../services/card_service.dart';
import '../services/tale_service.dart';
import '../utils/app_manager.dart';
import '../utils/device_info.dart';
import '../utils/password_strength_indicator.dart';
import '../widgets/button.dart';
import '../widgets/map.dart';
import '../widgets/text_field.dart';

class CreateVideoPage extends StatefulWidget {
  @override
  _CreateVideoPageState createState() => _CreateVideoPageState();
}

class _CreateVideoPageState extends State<CreateVideoPage> with TickerProviderStateMixin {
  final Validator _validator = Validator();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final MediaController mediaController = Get.put(MediaController());
  final AppManager _appManager = Get.put(AppManager());
  final CardService _cardService = Get.find<CardService>();
  final TaleService _taleService = Get.find<TaleService>();
  late final AnimationController _controller;

  // late final TextEditingController _passwordController;

  void _submit() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid == null || !isValid) {
      return;
    }
    var cardLocation = _appManager.getChosenLocation();
    CardModel videoCardData = CardModel(
      // id: _appManager.getCurrentUser(),
      order: _appManager.getCardsNum(),
      type: MemoryCardType.video,
      transform: Matrix4.identity(),
      name: '${_nameController.text}.mp4',
      locationLatitude: cardLocation?.item1,
      locationLongitude: cardLocation?.item2,
    );
    String taleId = _appManager.getCurrentTaleId();
    int result = await _cardService.addVideoCard(taleId,
        videoCardData, mediaController.getVideo()!);
    _appManager.setCurrentTaleLocations(await _taleService.getTaleLocations(taleId));
    showAnimatedPopUp();
    Future.delayed(Duration(seconds: 3), () async {
      Navigator.of(context).pop();
    });
    Future.delayed(Duration(seconds: 4), () async {
      if (result == 200) {
        _formKey.currentState?.save();
        Navigator.of(context).pop(true);
    } else {
        ErrorController.showSnackBarError(ErrorController.createVideo);
        Navigator.of(context).pop();
      }
    });
  }

  showAnimatedPopUp() {
    return showDialog(
        context: context,
        builder: (context) {
          _controller.reset();
          _controller.forward();
          _controller.repeat();
          return AlertDialog(
            content: Lottie.asset(
              "assets/animations/loading2.json",
              width: 400,
              height: 400,
              controller: _controller,
            ),
          );
        });
  }

  @override
  void initState() {
    _nameController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DeviceInfo device = DeviceInfo();
    device.computeDeviceInfo(context);
    return AlertDialog(
      elevation: 10,
      shadowColor: Colors.grey,
      title: const Center(
          child: Text(
        'Add new video',
        style: TextStyle(
            color: AppColors.main1, fontSize: 25, fontWeight: FontWeight.w700),
      )),
      insetPadding: EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      content: buildBody(device),
      actions: <Widget>[
        CustomButton(
            height: 40,
            width: 100,
            fontSize: 12,
            text: "Submit",
            textColor: Colors.white,
            onPressed: () => _submit()),
        CustomButton(
            height: 40,
            width: 100,
            fontSize: 12,
            backgroundColor: AppColors.main3,
            text: "close",
            textColor: Colors.white,
            onPressed: () => Navigator.of(context).pop())
      ],
    );
  }

  Widget buildBody(DeviceInfo device) {
    return SingleChildScrollView(
      child: Container(
        // height: device.height - 240,
        // width: device.width,
        height: 520,
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Center(
                    child: CustomTextField(
                      controller: _nameController,
                      labelText: 'Video name',
                      hintText: 'Enter your video name',
                      prefixIcon: Icons.abc,
                      obscureText: false,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: _validator.nameValidator,
                    ),
                  )),
              Flexible(
                flex: 11,
                fit: FlexFit.tight,
                child: Container(
                  height: 310,
                  child: SetPhotoScreen(isImage: false),
                ),
              ),
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Center(
                    child: CustomButton(
                        width: 180,
                        fontSize: 15,
                        backgroundColor: AppColors.main1,
                        icon: Icons.location_on,
                        text: "Location",
                        textColor: Colors.white,
                        onPressed: () => _onMapTap())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMapTap() {
    showDialog(
      context: context,
      builder: (context) {
        return MapScreen();
      },
    );
  }
}
