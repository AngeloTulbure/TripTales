import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_tales/src/models/card_model.dart';
import 'package:trip_tales/src/models/tale_model.dart';

import 'tuple.dart';

// coverage:ignore-start
class AppManager extends GetxController {
  Rx<List<CardModel?>?> userCards = Rx<List<CardModel?>?>(null);
  Rx<String> currentTaleId = Rx<String>("");
  Rx<TaleModel> currentTale = Rx<TaleModel>(TaleModel(name: '', imagePath: '', canvas: '0'));
  Rx<List<Tuple<String, LatLng>>?> currentTaleLocations = Rx<List<Tuple<String, LatLng>>?>(List.empty(growable: true));
  Rx<String> currentUserId = Rx<String>("");
  Rx<String> profileImage = Rx<String>("");
  Rx<int> menuIndex = Rx<int>(100);
  Rx<List<Tuple<String, Matrix4>>?> cardsTransform = Rx<List<Tuple<String, Matrix4>>?>(List.empty(growable: true));
  // RxList<Tuple<String, Matrix4>> cardsTransform = RxList<Tuple<String, Matrix4>>();

  Rx<Tuple<double, double>?> chosenLocation = Rx<Tuple<double, double>?>(null);
  Rx<bool> isCardsTransformChanged = Rx<bool>(false);
  Rx<bool> isTablet = Rx<bool>(false);

  void reset() {
    setCurrentUser('');
    setCards(List.empty());
    setIsCardsTransformChanged(false);
    setProfileImage('');
    setMenuIndex(100);
    resetTale();
    cardsTransform.value = List.empty();
  }

  void resetTale() {
    chosenLocation = Rx<Tuple<double, double>?>(null);
    cardsTransform = Rx<List<Tuple<String, Matrix4>>?>(List.empty(growable: true));
    setCurrentTaleId('');
    setCurrentTaleLocations(List.empty());
    setCurrentTale(TaleModel(name: '', imagePath: '', canvas: '0'));
  }

  void clearCardTransform() {
    cardsTransform = Rx<List<Tuple<String, Matrix4>>?>(List.empty(growable: true));
  }

  void setChosenLocation(LatLng loc) {
    if (loc == null) {
      chosenLocation.value = null;
      return;
    }
    chosenLocation.value = Tuple(loc.latitude, loc.longitude);
  }

  void setCardTransform(String name, Matrix4 transform) {
    setIsCardsTransformChanged(true);
    if (cardsTransform.value == null) {
      cardsTransform.value = [Tuple(name, transform)];
      return;
    }

    int index =
        cardsTransform.value!.indexWhere((tuple) => tuple.item1 == name);

    if (index != -1) {
      // "transform1" exists, update its item2
      cardsTransform.value![index] = Tuple(name, transform);
    } else {
      // "transform1" doesn't exist, add it to the list
      cardsTransform.value!.add(Tuple(name, transform));
    }
    // var card = userCards.value!.firstWhere((element) => element!.name == name);
    // card!.transform.setFrom(transform);
    // userCards.value![userCards.value!.indexOf(card)] = card;
  }

  void setIsCardsTransformChanged(bool isChanged) {
    isCardsTransformChanged.value = isChanged;
  }

  void setIsTablet(bool isTablet) {
    this.isTablet.value = isTablet;
  }

  void setProfileImage(String profileImagePath) {
    profileImage.value = profileImagePath;
  }

  void setCurrentTaleId(String taleId) {
    currentTaleId.value = taleId;
  }

  void setCurrentTale(TaleModel taleModel) {
    currentTale.value = taleModel;
  }

  void setCurrentTaleLocations(List<Tuple<String, LatLng>>? locations) {
    currentTaleLocations.value = List.empty();
    currentTaleLocations.value = locations;
  }

  void setCurrentUser(String userId) {
    currentUserId.value = userId;
  }

  void setCards(List<CardModel?>? cards) {
    userCards.value = cards;
  }

  void setMenuIndex(int index) {
    menuIndex.value = index;
  }

  // void setCardByName(CardModel? card) {
  //   userCards.value![userCards.value!.indexWhere((element) => element!.name == card!.name)] = card!;
  // }
  Tuple<double, double>? getChosenLocation() {
    return chosenLocation.value;
  }

  List<Tuple<String, Matrix4>>? getCardsTransform() {
    return cardsTransform.value;
  }

  bool getIsCardsTransformChanged() {
    return isCardsTransformChanged.value;
  }

  bool getIsTablet() {
    return isTablet.value;
  }

  String getProfileImage() {
    return profileImage.value;
  }

  String getCurrentTaleId() {
    return currentTaleId.value;
  }

  TaleModel getCurrentTale() {
    return currentTale.value;
  }

  List<Tuple<String, LatLng>>? getCurrentTaleLocations() {
    return currentTaleLocations.value;
  }

  String getCurrentUser() {
    // return "1";
    return currentUserId.value;
  }

  List<CardModel?>? getCards() {
    if (userCards == Rx<List<CardModel?>?>(null)) return [];
    userCards.value!.sort((a, b) => a!.order.compareTo(b!.order));
    return userCards.value;
  }

  int getCardsNum() {
    if (userCards == Rx<List<CardModel?>?>(null)) return 0;
    return userCards.value!.length;
  }

  int getMenuIndex() {
    return menuIndex.value;
  }

}

// coverage:ignore-end