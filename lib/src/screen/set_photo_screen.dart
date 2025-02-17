import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_tales/src/constants/color.dart';
import 'package:trip_tales/src/controllers/media_controller.dart';
import 'package:trip_tales/src/utils/device_info.dart';
import 'package:trip_tales/src/widgets/button.dart';
import 'package:video_player/video_player.dart';
import 'select_photo_options_screen.dart';

class SetPhotoScreen extends StatefulWidget {
  final bool isImage;
  final bool contDef;
  final String? imagePath;
  final bool hasImage;
  final double height;
  final double width;

  SetPhotoScreen({
    super.key,
    this.isImage = true,
    this.contDef = false,
    this.imagePath,
    this.hasImage = false,
    this.height = 250.0,
    this.width = 370.0,
  });

  static const id = 'set_photo_screen';

  @override
  State<SetPhotoScreen> createState() => _SetPhotoScreenState();
}

class _SetPhotoScreenState extends State<SetPhotoScreen> {
  final MediaController mediaController = Get.put(MediaController());
  File? _image;
  XFile? _video;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    if (!widget.isImage) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
      ));
    }

    // _image = widget.hasImage
    //     ? ((widget.imagePath != null ||
    //     widget.imagePath != '')
    //     ? File(widget.imagePath!)!
    //     : _image!)
    //     : _image!;
    // mediaController.setImage(_image);
    super.initState();
  }

  @override
  void dispose() {
    if (!widget.isImage) {
      _videoController.dispose();
    }
    super.dispose();
  }

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);
      setState(() {
        _image = img;
        mediaController.setImage(_image);
        Navigator.of(context).pop();
      });
    } on PlatformException catch (e) {
      print(e);
      Navigator.of(context).pop();
    }
  }

  Future _pickVideo(ImageSource source) async {
    try {
      final video = await ImagePicker().pickVideo(source: source);
      if (video == null) return;
      setState(() {
        _video = video;
        mediaController.setVideo(_video);
        _videoController = VideoPlayerController.file(File(video.path))
          ..initialize().then((_) {
            setState(() {});
            _videoController.play();
          });
        Navigator.of(context).pop();
      });
    } on PlatformException catch (e) {
      print(e);
      Navigator.of(context).pop();
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
    await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SelectPhotoOptionsScreen(
                onTap: _pickImage,
              ),
            );
          }),
    );
  }

  void _showSelectVideoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SelectPhotoOptionsScreen(
                onTap: _pickVideo,
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    DeviceInfo device = DeviceInfo();
    device.computeDeviceInfo(context);
    bool isTablet = device.isTablet;
    return SizedBox(
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // coverage:ignore-start
                widget.isImage
                    ? _showSelectPhotoOptions(context)
                    : _showSelectVideoOptions(context);
                // coverage:ignore-end
              },
              child: Center(
                child: widget.contDef
                // coverage:ignore-line
                    ? Container()
                    : Container(
                  height: widget.height,
                  width: widget.width,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey.shade200,
                  ),
                  child: widget.isImage
                      ? Center(
                    child: _image == null
                        ? Text(
                      key: const Key('noImageKey'),
                      widget.hasImage
                          ? 'You can change your image here'
                          : 'No image selected',
                      style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.main1),
                    )
                        : Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(15),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(_image!),
                        ),
                      ),
                    ),
                  )
                      : Center(
                    child: _video == null
                        ? const Text(
                      key: Key('noVideoKey'),
                      'No video selected',
                      style: TextStyle(fontSize: 20),
                    )
                        : Container(
                      child: ClipRRect(
                        // key: const Key('ClipRRectKey'),
                        borderRadius:
                        BorderRadius.circular(15),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: _videoController
                                .value.size!.width,
                            height: _videoController
                                .value.size!.height,
                            child:
                            VideoPlayer(_videoController),
                          ),
                        ),
                        // child: VideoPlayer(_videoController),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                isTablet: isTablet,
                height: isTablet ? 60 : 50,
                width: isTablet ? 300 : 200,
                fontSize: isTablet ? 20 : 18,
                padding: 10,
                onPressed: () => widget.isImage
                    ? _showSelectPhotoOptions(context)
                    : _showSelectVideoOptions(context),
                backgroundColor: AppColors.main2,
                textColor: Colors.white,
                text: widget.isImage ? 'Add Image' : 'Add Video',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
