import 'package:flutter/material.dart';
import 'package:fazkorony/core/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Basmallah extends StatefulWidget {
  final int index;
   const Basmallah({super.key, required this.index });

  @override
  State<Basmallah> createState() => _BasmallahState();
}

class _BasmallahState extends State<Basmallah> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(width: screenSize.width,
      child: Padding(
        padding: EdgeInsets.only(
            left: (screenSize.width * .2).w,
            right: (screenSize.width * .2).w,
            top: 
            8.h,
            bottom: 2.h
            ),
        child:
    // Text("115",
    // textAlign: TextAlign.center,
    // style: TextStyle(
    //   color: primaryColors[widget.index],
    //   fontFamily: "arsura",fontSize: 40.sp
    // ),)     
      Image.asset(
          "assets/quran/images/Basmala.png",
          color: primaryColors[widget.index].withOpacity(.9),
          width: MediaQuery.of(context).size.width.w*.4,
        ),
      ),
    );
  }
}
