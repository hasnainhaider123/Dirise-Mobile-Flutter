import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dirise/widgets/common_colour.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/profile_controller.dart';
import '../model/job_single_model.dart';
import '../repository/repository.dart';
import '../utils/api_constant.dart';
import '../widgets/common_button.dart';

class JobOfferDetailsSingleScreen extends StatefulWidget {
  const JobOfferDetailsSingleScreen({super.key});

  @override
  State<JobOfferDetailsSingleScreen> createState() =>
      _JobOfferDetailsSingleScreenState();
}

class _JobOfferDetailsSingleScreenState
    extends State<JobOfferDetailsSingleScreen> {
  final profileController = Get.put(ProfileController());
  Rx<JobProductModel> getJobModel = JobProductModel().obs;
  final Repositories repositories = Repositories();
  var id = Get.arguments;
  void downloadCV(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  jobTypeApi(id) {
    repositories
        .getApi(
      url: ApiUrls.singleJobList + id,
    )
        .then((value) {
      getJobModel.value = JobProductModel.fromJson(jsonDecode(value));
      log('dada${getJobModel.value.toJson()}');
    });
  }

  void launchLinkedIn(String profileUrl) async {
    final Uri url = Uri.parse(profileUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    jobTypeApi(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.newPrimaryColor,
      appBar: customAppBar(title: "Job Details".tr),
      body: SingleChildScrollView(
        child: Obx(() {
          return getJobModel.value.singleJobProduct != null
              ? Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          )),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: getJobModel
                                        .value.singleJobProduct!.featuredImage
                                        .toString(),
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.contain,
                                    errorWidget: (_, __, ___) =>
                                        Image.asset("assets/images/eoxy.png"),
                                  ),
                                ),

                                const SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getJobModel.value.singleJobProduct!.pname
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                          color: const Color(0xFF1F1F1F),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          color: Color(0xFF545454),
                                          size: 15,
                                        ),
                                        Text(
                                          getJobModel
                                              .value.singleJobProduct!.jobCityId
                                              .toString(),
                                          style: GoogleFonts.poppins(
                                              color: const Color(0xFF545454),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Spacer(),
                                // Icon(Icons.star, color: Color(0xFF545454), size: 15,),
                              ],
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E9EE),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    getJobModel
                                        .value.singleJobProduct!.experience
                                        .toString(),
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF545454),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E9EE),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    getJobModel.value.singleJobProduct!.jobModel
                                        .toString(),
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF545454),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E9EE),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    getJobModel.value.singleJobProduct!.jobType
                                        .toString(),
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF545454),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  getJobModel.value.singleJobProduct!.salary
                                      .toString(),
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFF014E70),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Divider(
                              color: Colors.grey.shade200,
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Job Description",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF1F1F1F),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 35,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: getJobModel
                                    .value.singleJobProduct!.jobCat!.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E9EE),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      getJobModel.value.singleJobProduct!
                                          .jobCat![index].title
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                          color: const Color(0xFF545454),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 11),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: () {
                                launchLinkedIn(
                                  getJobModel.value.singleJobProduct!.linkdinUrl
                                      .toString(),
                                );
                              },
                              child: Text(
                                getJobModel.value.singleJobProduct!.linkdinUrl
                                    .toString(),
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF014E70),
                                    fontWeight: FontWeight.w300,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              getJobModel.value.singleJobProduct!.aboutYourself
                                  .toString(),
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF545454),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: SizedBox(
                                height: 170,
                                child: Stack(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: getJobModel
                                          .value.singleJobProduct!.uploadCv
                                          .toString(),
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.contain,
                                      errorWidget: (_, __, ___) =>
                                          Image.asset("assets/svgs/resume.png"),
                                    ),
                                  ),
                                  Positioned(
                                    top: 50,
                                    left: 25,
                                    child: InkWell(
                                      onTap: () {
                                        downloadCV(
                                          getJobModel
                                              .value.singleJobProduct!.uploadCv
                                              .toString(),
                                        );
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 100,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          "Download",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF014E70),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                              ),
                            ),
                            const SizedBox(
                              height: 110,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )
              : const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }

  AppBar customAppBar({required String title}) {
    return AppBar(
      backgroundColor: AppTheme.newPrimaryColor,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            profileController.selectedLAnguage.value != 'English'
                ? Image.asset(
                    'assets/images/forward_icon.png',
                    height: 19,
                    width: 19,
                  )
                : Image.asset(
                    'assets/images/back_icon_new.png',
                    height: 19,
                    width: 19,
                  ),
          ],
        ),
      ),
      titleSpacing: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.tr,
            style: GoogleFonts.poppins(
                color: Colors.black, fontWeight: FontWeight.w600, fontSize: 22),
          ),
        ],
      ),
    );
  }
}
