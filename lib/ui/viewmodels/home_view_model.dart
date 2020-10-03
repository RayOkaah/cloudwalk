import 'dart:convert';
import 'dart:io';

import 'package:cloudwalk/constants/constants.dart';
import 'package:cloudwalk/models/apod.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HomeViewModel extends ChangeNotifier {
  static const int ItemRequestThreshold = 8;

  List<String> _items;
  List<String> get items => _items;

  int _count = 0;
  int get count => _count+10;
  bool listEnd = false;
  Future<List<Apod>> getApodList() async{
  apodList = await getUserDataResponse();
  return apodList;
  }

  int _currentPage = 0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  get history => apodList;
  List<Apod> _suggestions = [];
  List<Apod> get suggestions => apodList;

  String _query = '';
  String get query => _query;

  void onQueryChanged(String query) async {
    if (query == _query) return;

    _query = query;
    _isLoading = true;
    notifyListeners();

    if (query.isEmpty) {
      _suggestions = history;
    } else {
      final response = await http.get('http://photon.komoot.de/api/?q=$query');
      final body = json.decode(utf8.decode(response.bodyBytes));
      final features = body['features'] as List;

      _suggestions = features.map((e) => Apod.fromJson(e)).toSet().toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _suggestions = history;
    notifyListeners();
  }


  HomeViewModel(){
    //_items = List<String>.generate(15, (index) => 'Title $index');
    getApodList();

  }

  Future<void> _deleteCacheContents() async {
    final cacheDir = await getTemporaryDirectory();
    String fileName = "CacheData.json";

    if (await File(cacheDir.path + "/" + fileName).exists()) {
      cacheDir.delete(recursive: true);
      print("Deleted the CacheJson file!!");
    }
  }

  Future<void> refresh() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    apodList.clear();
    getUserDataResponse();
    //_deleteCacheContents();
    notifyListeners();
  }

  List<Apod> apodList = [];


  Future<List<Apod>> getUserDataResponse() async {
    //TODO: Step2 - Declare a file name that has .json extension and get the Cache Directory

    String fileName = "CacheData.json";
    var cacheDir = await getTemporaryDirectory();

    //TODO: Step 3 - Check of the Json file exists so that we can decide whether to make an API call or not

    if (await File(cacheDir.path + "/" + fileName).exists()) {
      print("Loading from cache");
      //TOD0: Reading from the json File
      final jsonData = File(cacheDir.path + "/" + fileName).readAsStringSync();
      print('json datahere : '+jsonData);
      //ApiResponse response = ApiResponse.fromJson(json.decode(jsonData));
      final responseList = json.decode(jsonData);
      for(var m in responseList){
        apodList.add(Apod.fromJson(m));
      }
      notifyListeners();
      return apodList;
    }
    //TODO: If the Json file does not exist, then make the API Call

    else {
      print("Loading from API");
      final response = await fetchApodList(count);

      if (response is List<Apod>) {
        //final jsonResponse = response;
        //ApiResponse res = ApiResponse.fromJson(json.decode(jsonResponse));
        var jsonResponse = jsonEncode(response.map((e) => e.toJson()).toList());

        //TODO: Step 4  - Save the json response in the CacheData.json file in Cache
        var tempDir = await getTemporaryDirectory();
        File file = new File(tempDir.path + "/" + fileName);
        file.writeAsString(jsonResponse, flush: true, mode: FileMode.write);
        notifyListeners();
        return response;
      }

    }
  }

Future<List<Apod>> fetchApodList(int itemCount) async {
    // widget.callback();
    //final response = await http.get(BASEAPIURL+"/planetary/apod?api_key=$APIKEY", headers: {
    final response = await http.get(BASEAPIURL+"/planetary/apod?api_key=$APIKEY&count=${count}", headers: {
      "Accept": "application/json"
    });
    print('result : '+response.body);
    if (response.statusCode == 200) {
      Iterable responseList = json.decode(response.body);

      //apodList = responseList.map((m) => Apod.fromJson(json.decode(m))).toList();
      for(var m in responseList){
        apodList.add(Apod.fromJson(m));
      }

      //_navService.navigateTo(StockDetailViewRoute, arguments: _stockEntity);
      //widget.callback();
      notifyListeners();
      return apodList;
    } else {
      // If the server did not return a 200 OK response,
      // notify Hud and then throw an exception.
      // widget.callback();
      notifyListeners();
      throw Exception('Failed to fetch apodlist');
    }
  }

  Future handleItemCreated(int index) async {
    var itemPosition = index + 1;
    var requestMoreData =
        itemPosition % ItemRequestThreshold == 0 && itemPosition != 0;
    var pageToRequest = itemPosition ~/ ItemRequestThreshold;

    if(count >=100){
      if (listEnd) {
        return;
      }
      else {
        //_showListEnding();
        return;
      }

    }
    else if (requestMoreData && pageToRequest > _currentPage) {
      print('handleItemCreated | pageToRequest: $pageToRequest');
      _currentPage = pageToRequest;
      _showLoadingIndicator();

      await Future.delayed(Duration(seconds: 3));
      //count = count + 10;
      var newFetchedItems = await getUserDataResponse(); //fetchApodList(count);
      _count = newFetchedItems.length;
       //apodList.addAll(newFetchedItems);
      //await Future.delayed(Duration(seconds: 5));
      _removeLoadingIndicator();
    }

    else {
      return;
    }

  }

  void _showLoadingIndicator() {
    apodList.add(Apod(title: LoadingIndicatorTitle));
    notifyListeners();
  }

  void _showListEnding() {
    apodList.add(Apod(title: ListEndText));
    listEnd = true;
    notifyListeners();
  }

  void _removeLoadingIndicator() {
    apodList.removeWhere((element) => element.title == LoadingIndicatorTitle);
    notifyListeners();
  }
}
