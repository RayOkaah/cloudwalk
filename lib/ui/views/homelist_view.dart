import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudwalk/constants/constants.dart';
import 'package:cloudwalk/constants/route_names.dart';
import 'package:cloudwalk/locator.dart';
import 'package:cloudwalk/models/apod.dart';
import 'package:cloudwalk/services/navigation_service.dart';
import 'package:cloudwalk/ui/shared/app_colors.dart';
import 'package:cloudwalk/ui/viewmodels/home_view_model.dart';
import 'package:cloudwalk/ui/views/detail_view.dart';
import 'package:cloudwalk/ui/widgets/aware_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:loadmore/loadmore.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

class InfoListTile extends StatefulWidget {
  Apod apod;
  InfoListTile({this.apod});
  @override
  _InfoListTileState createState() => _InfoListTileState();
}

class _InfoListTileState extends State<InfoListTile> {
  final NavigationService _navService = locator<NavigationService>();

  onClick(){
    _navService.navigateTo(ApodDetailViewRoute, arguments: widget.apod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.apod.title == LoadingIndicatorTitle
          ? Center(child: CircularProgressIndicator())
      : widget.apod.title == ListEndText ? Center(child: Text(widget.apod.title),)
          : ListTile(
        onTap: (){
         onClick();
        },
        contentPadding: EdgeInsets.all(10),
        leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(widget.apod.url??' '),
            //child: CachedNetworkImage(imageUrl: widget.apod.url??' ',)
        ),
        title: Text(widget.apod.title?? ' '),
        subtitle: Text(widget.apod.date),
      ),
    );
  }
}

class HomeListView extends StatefulWidget {
  const HomeListView({Key key}) : super(key: key);

  @override
  _HomeListViewState createState() => _HomeListViewState();
}

class _HomeListViewState extends State<HomeListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<HomeViewModel>(
        create: (context) => HomeViewModel(),
        child: Consumer<HomeViewModel>(
          builder: (context, model, child) => RefreshIndicator(
            onRefresh: model.refresh,
            child: Stack(
              children: [
                SafeArea(
                  minimum: EdgeInsets.only(top: 50),
                  child: ListView.builder(
                    itemCount: model.apodList.length,
                    itemBuilder: (context, index) => CreationAwareListItem(
                      itemCreated: () {
                        SchedulerBinding.instance.addPostFrameCallback(
                                (duration) => model.handleItemCreated(index));
                      },
                      child: Container(
                        height: 100,
                        child: InfoListTile(
                          apod: model.apodList[index],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                    child: buildFloatingSearchBar(model.apodList)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Apod> displayedList = [];
  List<Apod> tempList = [];
  Widget buildFloatingSearchBar(List<Apod> _apodList) {
    bool isPortrait =true;

    void filterSearchResults(String query) {
     // List<String> tempList = List<String>();
      //tempList.addAll(_apodList);
      if(query.isNotEmpty) {
        print('newquery : '+query);
       // List<String> tempList = List<String>();
        _apodList.forEach((item) {
          if(item.title.contains(query)) {
            tempList.add(item);
          }
        });
        setState(() {
          print('tema here o : '+tempList.toString());
          displayedList.clear();
          displayedList.addAll(tempList);
          print('diplaya : '+displayedList.toString());
        });
        return;
      } else {
        setState(() {
          displayedList.clear();
          displayedList.addAll(_apodList);
        });
      }
    }

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      maxWidth: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        filterSearchResults(query);
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: displayedList.map((apod) {
                return Container(
                  height: 100,
                  child: InfoListTile(
                    apod: apod,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
