import 'package:fitnessapp/common_widgets/round_button.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/gallery_api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<dynamic> photoArr = [];
  String nextPhotoText = "Next Photos date unavailable";
  bool isLoading = true;
  bool isUploading = false;
  String? errorText;
  final picker.ImagePicker _picker = picker.ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      final data = await GalleryApi.fetchGallery();
      if (!mounted) return;

      setState(() {
        photoArr = (data["groups"] as List?) ?? [];
        nextPhotoText = data["reminder"]?.toString() ?? "Next Photos date unavailable";
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorText = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  Future<void> _pickAndUpload(picker.ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;

      if (mounted) {
        setState(() {
          isUploading = true;
        });
      }

      await GalleryApi.uploadPhoto(imageFile: File(picked.path));
      await _loadGallery();
      _showMessage("Photo uploaded successfully");
    } catch (e) {
      _showMessage(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> _openAddPhotoSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Take photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUpload(picker.ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUpload(picker.ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPhotoTile(String photoPath) {
    final isRemote = photoPath.startsWith("http://") || photoPath.startsWith("https://");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.lightGrayColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: isRemote
            ? Image.network(
                photoPath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  "assets/images/progress_each_photo.png",
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                photoPath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: Text(
          "Progress Photo",
          style: TextStyle(
              color: AppColors.blackColor, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/icons/more_icon.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: const Color(0xffFFE5E5),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(30)),
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/icons/date_notifi.png",
                            width: 30,
                            height: 30,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Reminder!",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  nextPhotoText,
                                  style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ]),
                        ),
                        Container(
                            height: 60,
                            alignment: Alignment.topRight,
                            child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.grayColor,
                                  size: 15,
                                )))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(20),
                    height: media.width * 0.4,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.primaryColor2.withOpacity(0.4),
                          AppColors.primaryColor1.withOpacity(0.4)
                        ]),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Track Your Progress Each\nMonth With Photo",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 110,
                                height: 35,
                                child: RoundButton(
                                    title: isUploading ? "Uploading..." : "Add Photo",
                                    onPressed: isUploading ? () {} : _openAddPhotoSheet),
                              )
                            ]),
                        Image.asset(
                          "assets/images/progress_each_photo.png",
                          width: media.width * 0.35,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Gallery",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            "See more",
                            style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                          ))
                    ],
                  ),
                ),
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: photoArr.length,
                  itemBuilder: ((context, index) {
                      var pObj = photoArr[index] as Map? ?? {};
                      var imaArr = pObj["photo"] as List? ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              pObj["time"].toString(),
                              style:
                              TextStyle(color: AppColors.grayColor, fontSize: 12),
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: imaArr.length,
                              itemBuilder: ((context, indexRow) {
                                return _buildPhotoTile(
                                  imaArr[indexRow] as String? ?? "",
                                );
                              }),
                            ),
                          ),
                        ],
                      );
                    }),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!isLoading && errorText != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                if (!isLoading && errorText == null && photoArr.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      "No gallery photos yet",
                      style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                    ),
                  )
              ],
            ),
            SizedBox(
              height: media.width * 0.05,
            ),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () {
          if (!isUploading) {
            _openAddPhotoSheet();
          }
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.secondaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.photo_camera,
            size: 20,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
