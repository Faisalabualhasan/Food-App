import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:foodpanda_sellers_app/global/global.dart';

import 'package:foodpanda_sellers_app/uploadScreens/items_upload_screen.dart';

import 'package:foodpanda_sellers_app/widgets/my_drawer.dart';
import 'package:foodpanda_sellers_app/widgets/progress_bar.dart';

import '../model/items.dart';
import '../model/menus.dart';
import '../widgets/items_design.dart';
import '../widgets/text_widget_header.dart';

class ItemsScreen extends StatefulWidget {
  final Menus? model;
  ItemsScreen({this.model});

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  @override
  Widget build(BuildContext context) {
    // Ekranın UI'sini oluşturur
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
        title: Text(
          sharedPreferences!
              .getString("name")!, // paylaşılan tercihlerden ismi alır
          style: const TextStyle(fontSize: 30, fontFamily: "Lobster"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.library_add,
              color: Colors.cyan,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => ItemsUploadScreen(
                          model: widget
                              .model))); // Yeni bir öğe eklemek için ItemsUploadScreen sınıfına yönlendirir
            },
          ),
        ],
      ),
      drawer: MyDrawer(), // MyDrawer widgeti, sol menüyü oluşturur
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
              // Sabit başlık
              pinned: true,
              delegate: TextWidgetHeader(
                  title: "My " +
                      widget.model!.menuTitle.toString() +
                      "'s Items")), // Menü başlığındaki modelin başlığını alır
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("sellers")
                .doc(sharedPreferences!.getString(
                    "uid")) // paylaşılan tercihlerden kullanıcı kimliğini alır
                .collection("menus")
                .doc(widget.model!.menuID)
                .collection("items")
                .orderBy("publishedDate", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // Firebase'den veri akışı alır ve bunu işler
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                      child: Center(
                        child:
                            circularProgress(), // progress indicator, veriler yüklenirken görüntülenir
                      ),
                    )
                  : SliverStaggeredGrid.countBuilder(
                      // öğelerin görüntülenmesi için kılavuz çizgileri
                      crossAxisCount: 1,
                      staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                      itemBuilder: (context, index) {
                        Items model = Items.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        return ItemsDesignWidget(
                          model: model,
                          context: context,
                        ); // ItemsDesignWidget sınıfı, öğelerin tasarımını gösterir
                      },
                      itemCount: snapshot.data!.docs.length,
                    );
            },
          ),
        ],
      ),
    );
  }
}
