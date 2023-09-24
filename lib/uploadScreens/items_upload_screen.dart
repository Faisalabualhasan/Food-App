import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodpanda_sellers_app/global/global.dart';
import 'package:foodpanda_sellers_app/mainScreens/home_screen.dart';

import 'package:foodpanda_sellers_app/widgets/error_dialog.dart';
import 'package:foodpanda_sellers_app/widgets/progress_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;

import '../model/menus.dart';

class ItemsUploadScreen extends StatefulWidget {
  final Menus? model;
  ItemsUploadScreen({this.model});

  @override
  _ItemsUploadScreenState createState() => _ItemsUploadScreenState();
}

class _ItemsUploadScreenState extends State<ItemsUploadScreen> {
  XFile? imageXFile; // Seçilen resmin dosya yolunu tutacak değişken
  final ImagePicker _picker =
      ImagePicker(); // Resim seçmek için kullanılacak ImagePicker sınıfından bir örnek oluşturuldu

  TextEditingController shortInfoController =
      TextEditingController(); // Ürünün kısa açıklaması için metin alanı denetleyicisi
  TextEditingController titleController =
      TextEditingController(); // Ürün başlığı için metin alanı denetleyicisi
  TextEditingController descriptionController =
      TextEditingController(); // Ürün açıklaması için metin alanı denetleyicisi
  TextEditingController priceController =
      TextEditingController(); // Ürün fiyatı için metin alanı denetleyicisi

  bool uploading =
      false; // Ürün bilgilerinin sunucuya yüklenme durumunu tutacak değişken
  String uniqueIdName = DateTime.now()
      .millisecondsSinceEpoch
      .toString(); // Resmin yüklenme tarihine göre benzersiz bir isim oluşturuldu

  defaultScreen() // Ekranın varsayılan halini oluşturacak metod
  {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            // İki renk arasında bir geçiş için bir LinearGradient bileşeni tanımlandı
            colors: [
              Color(0xFF5e1eaa),
              Colors.amber,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          )),
        ),
        title: const Text(
          "Add New Items",
          style: TextStyle(fontSize: 30, fontFamily: "Lobster"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true, // Geri tuşunun gösterilmesi
        leading: IconButton(
          // Sol tarafta bir IconButton bileşeni oluşturuldu
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => const HomeScreen()));
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color(0xFF5e1eaa),
            Colors.amber,
          ],
          begin: FractionalOffset(0.0, 0.0),
          end: FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        )),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shop_two,
                color: Colors.white,
                size: 200.0,
              ),
              ElevatedButton(
                child: const Text(
                  "Add New Item",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                style: ButtonStyle(
                  // Düğme stilleri tanımlanıyor
                  backgroundColor: // Arkaplan rengi ayarlanıyor
                      MaterialStateProperty.all<Color>(Colors.amber),
                  // Düğme şekli ayarlanıyor
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                onPressed: () {
                  takeImage(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bu kod parçası, kullanıcının kamera veya galeriden bir resim seçebileceği bir basit bir diyalog kutusu gösterir.
  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          title: const Text(
            "Menu Image", // Diyalog kutusu başlığı
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
          children: [
            SimpleDialogOption(
              child: const Text(
                "Capture with Camera",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: const Text(
                "Select from Gallery",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  captureImageWithCamera() async {
    //kullanıcının kamerayı kullanarak bir resim çekmesine izin verir
    Navigator.pop(context); // Diyalog kutusunu kapatır

    // _picker.pickImage() yöntemi, kameradan bir resim çekmenizi sağlar
    imageXFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 720,
      maxWidth: 1280,
    );

    // setState() yöntemi, resmi göstermek için görünümü günceller
    setState(() {
      imageXFile;
    });
  }

  pickImageFromGallery() async {
    //kullanıcının galeriden bir resim seçmesine izin
    Navigator.pop(context); // Diyalog kutusunu kapatır

    // _picker.pickImage() yöntemi, galeriden bir resim seçmenizi sağlar
    imageXFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 720,
      maxWidth: 1280,
    );

    // setState() yöntemi, resmi göstermek için görünümü günceller
    setState(() {
      imageXFile;
    });
  }

  itemsUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Color(0xFF5e1eaa),
              Colors.amber,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          )),
        ),
        title: const Text(
          "Uploading New Item",
          style: TextStyle(fontSize: 20, fontFamily: "Lobster"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        // Appbar'ın leading'i oluşturuluyor
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            clearMenusUploadForm();
          },
        ),
        actions: [
          TextButton(
            child: const Text(
              "Add",
              style: TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: "Varela",
                letterSpacing: 3,
              ),
            ),
            onPressed: uploading ? null : () => validateUploadForm(),
          ),
        ],
      ),
      body: ListView(
        children: [
          // uploading == true ise linearProgress widget'ı görüntüleniyor, değilse boş Text widget'ı görüntüleniyor
          uploading == true ? linearProgress() : const Text(""),
          Container(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(imageXFile!.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.perm_device_information,
              color: Colors.cyan,
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: shortInfoController,
                decoration: const InputDecoration(
                  hintText: "info",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.title,
              color: Colors.cyan,
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "title",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.description,
              color: Colors.cyan,
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: "description",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.camera,
              color: Color(0xFF5e1eaa),
            ),
            title: Container(
              width: 250,
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                controller: priceController,
                decoration: const InputDecoration(
                  hintText: "price",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  // Bu fonksiyon, kullanıcının yüklediği menü öğesinin bilgilerini temizler
  clearMenusUploadForm() {
    setState(() {
      // Metin kutularını ve resim dosyasını temizle
      shortInfoController.clear();
      titleController.clear();
      priceController.clear();
      descriptionController.clear();

      imageXFile = null;
    });
  }

  // Bu fonksiyon, kullanıcının yüklediği menü öğesinin bilgilerini doğrular ve Firebase'e kaydeder
  validateUploadForm() async {
    // Resim dosyası yüklendi mi kontrol et
    if (imageXFile != null) {
      // Kısa bilgi, başlık, açıklama ve fiyat alanları dolduruldu mu kontrol et
      if (shortInfoController.text.isNotEmpty &&
          titleController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty &&
          priceController.text.isNotEmpty) {
        setState(() {
          uploading =
              true; // Yükleme sırasında "yükleniyor" durumunu etkinleştir
        });

        // Resmi yükle
        String downloadUrl = await uploadImage(File(imageXFile!.path));

        // Firestore'a bilgileri kaydet
        saveInfo(downloadUrl);
      } else {
        // Bilgiler eksik olduğunda bir hata iletişim kutusu göster
        showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: "Please write title and info for menu.",
              );
            });
      }
    } else {
      // Resim seçilmediyse bir hata iletişim kutusu göster
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please pick an image for menu.",
            );
          });
    }
  }

  // Bu fonksiyon, kullanıcının yüklediği menü öğesinin bilgilerini Firestore'a kaydeder
  saveInfo(String downloadUrl) {
    // Firestore referansı oluştur
    final ref = FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .collection("menus")
        .doc(widget.model!.menuID)
        .collection("items");

    // Firestore'a belirtilen belirli bir dökümana bilgileri kaydetme işlemi
    ref.doc(uniqueIdName).set({
      "itemID": uniqueIdName,
      "menuID": widget.model!.menuID,
      "sellerUID": sharedPreferences!.getString("uid"),
      "sellerName": sharedPreferences!.getString("name"),
      "shortInfo": shortInfoController.text.toString(),
      "longDescription": descriptionController.text.toString(),
      "price": int.parse(priceController.text),
      "title": titleController.text.toString(),
      "publishedDate": DateTime.now(),
      "status": "available",
      "thumbnailUrl": downloadUrl,
    }).then((value) {
      // Yeni menü öğesini genel 'items' koleksiyonuna da kaydet
      final itemsRef = FirebaseFirestore.instance.collection("items");

      itemsRef.doc(uniqueIdName).set({
        "itemID": uniqueIdName,
        "menuID": widget.model!.menuID,
        "sellerUID": sharedPreferences!.getString("uid"),
        "sellerName": sharedPreferences!.getString("name"),
        "shortInfo": shortInfoController.text.toString(),
        "longDescription": descriptionController.text.toString(),
        "price": int.parse(priceController.text),
        "title": titleController.text.toString(),
        "publishedDate": DateTime.now(),
        "status": "available",
        "thumbnailUrl": downloadUrl,
      });
    }).then((value) {
      // Tüm alanları temizleme
      clearMenusUploadForm();

      // Yüklenen resimlerin benzersiz ID'sini oluşturma
      setState(() {
        uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
        uploading = false;
      });
    });
  }

  // Resmi Firebase Storage'a yüklemek için bir fonksiyon oluşturulur
// Parametre olarak yüklenecek dosya (mImageFile) alınır
// Storage referansı oluşturulur ve dosya bu referansa yüklenir
// Yükleme işlemi tamamlandıktan sonra download URL'si alınır ve döndürülür
  uploadImage(mImageFile) async {
    storageRef.Reference reference =
        storageRef.FirebaseStorage.instance.ref().child("items");

    // Yükleme işlemi başlatılır ve sonucu beklenir
    // uniqueIdName adlı dosya ismi kullanılır
    storageRef.UploadTask uploadTask =
        reference.child(uniqueIdName + ".jpg").putFile(mImageFile);

    storageRef.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    // Dosyanın indirme URL'si alınır ve döndürülür
    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    return downloadURL;
  }

  // Widget'ın build metodu, resim dosyası yüklendi mi kontrol eder
// Eğer yüklenmemişse defaultScreen() çağırılır, yüklenmişse itemsUploadFormScreen() çağırılır
  @override
  Widget build(BuildContext context) {
    return imageXFile == null ? defaultScreen() : itemsUploadFormScreen();
  }
}
