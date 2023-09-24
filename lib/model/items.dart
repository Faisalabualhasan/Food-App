import 'package:cloud_firestore/cloud_firestore.dart';

class Items {
  String? menuID;
  String? sellerUID;
  String? itemID;
  String? title;
  String? shortInfo;
  Timestamp? publishedDate;
  String? thumbnailUrl;
  String? longDescription;
  String? status;
  int? price;

  Items({
    this.menuID,
    this.sellerUID,
    this.itemID,
    this.title,
    this.shortInfo,
    this.publishedDate,
    this.thumbnailUrl,
    this.longDescription,
    this.status,
  });

  // Bu kod, bir "Items" sınıfının oluşturulmasını ve JSON formatındaki verilerin bu sınıfa dönüştürülmesini sağlar

  // Bu satırlar, "fromJson" fonksiyonunu açıklar ve JSON verilerinin sınıf özelliklerine atanmasını sağlar.
  Items.fromJson(Map<String, dynamic> json) {
    menuID = json['menuID'];
    sellerUID = json['sellerUID'];
    itemID = json['itemID'];
    title = json['title'];
    shortInfo = json['shortInfo'];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    longDescription = json['longDescription'];
    status = json['status'];
    price = json['price'];
  }

  // Bu satırlar, "toJson" fonksiyonunu açıklar ve sınıf özelliklerinin JSON formatına dönüştürülmesini sağlar.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['menuID'] = menuID;
    data['sellerUID'] = sellerUID;
    data['itemID'] = itemID;
    data['title'] = title;
    data['shortInfo'] = shortInfo;
    data['price'] = price;
    data['publishedDate'] = publishedDate;
    data['thumbnailUrl'] = thumbnailUrl;
    data['longDescription'] = longDescription;
    data['status'] = status;

    return data;
  }
}
