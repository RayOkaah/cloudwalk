import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudwalk/constants/constants.dart';
import 'package:cloudwalk/locator.dart';
import 'package:cloudwalk/models/apod.dart';
import 'package:cloudwalk/services/navigation_service.dart';
import 'package:cloudwalk/ui/shared/app_colors.dart';
import 'package:cloudwalk/ui/shared/shared_styles.dart';
import 'package:cloudwalk/ui/widgets/busy_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApodDetailView extends StatefulWidget {
  Apod apod;
  ApodDetailView(this.apod);

  @override
  _ApodDetailViewState createState() => _ApodDetailViewState();
}

class _ApodDetailViewState extends State<ApodDetailView> {
  final NavigationService _navService = locator<NavigationService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: false,
              //pinned: true,
              expandedHeight: 300.0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title:
                Container(
                  //height: 100,
                  //width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    //borderRadius: BorderRadius.all(Radius.circular(20)),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(widget.apod.url,),
                      fit: BoxFit.cover
                    )
                  ),
                ),
              ),
            ),
            SliverList(delegate: SliverChildListDelegate(
              [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(widget.apod.title, style: titleTextStyle,),
                  alignment: Alignment.center,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  alignment: Alignment.center,
                  child: Text(widget.apod.date),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Text(widget.apod.explanation, textAlign: TextAlign.center,),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                    child: RaisedButton(
                      child: Text('Go Back'),
                        color: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            //side: BorderSide(color: Colors.red)
                        ),
                        onPressed: (){
                        _navService.pop();
                        }),
                    height: 50.0),
              ],
            ),)
          ],
        ),
      ),
    );
  }
}
