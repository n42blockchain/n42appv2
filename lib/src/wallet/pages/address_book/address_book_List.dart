import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/utils/event_bus.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/wallet/api/address_book_api.dart';
import 'package:n42appv2/src/wallet/models/address_book_model.dart';
import 'package:n42appv2/src/wallet/pages/address_book/add_address_page.dart';
import 'package:n42appv2/src/wallet/widgets/address_edit.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressBookList extends StatefulWidget {
  final String coinName;
  AddressBookList({this.coinName = "",super.key});

  @override
  State<AddressBookList> createState() => _AddressBookListState();
}

class _AddressBookListState extends State<AddressBookList> {
  List<AddressBookModel> list = [];
  AddressBookApi? _addressBookApi;
  AddressBookApi get addressBookApi{
    if(_addressBookApi==null){
      _addressBookApi=AddressBookApi();
    }
    return _addressBookApi!;
  }
  var eventBusFn;
  initData() async {
    try {
      String coinName=widget.coinName;
      List<AddressBookModel> list = await addressBookApi.getAddressBookList(coinName);
      // debugPrint("list ${list.length}");
      this.list = list;
      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      debugPrint("err ${err.toString()}");
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    eventBusFn=eventBus.on().listen((event) {
      if (event is EventPublic && event.type == EventPublicType.refreshData) {
        if (mounted) {
          debugPrint("----------refreshData---------");
          initData();
        }
      }
    });
    initData();
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
    eventBusFn.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).s_key_2,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddAddressPage()));
              initData();
            },
            icon: Icon(
              Icons.add_circle_outline,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            ),
          ),
        ],
      ),
      body: buildContentList(),
    );
  }
  buildContentList() {
    if (list.isEmpty) {
      return const Center(
        child: EmptyView(),
      );
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildItem(context, index);
      },
    );
  }

  _buildItem(BuildContext context, int index) {
    AddressBookModel info = list[index];
    // debugPrint("id ${info.id}");
    return GestureDetector(
      onTap: () {
        if (widget.coinName == "") {
          SheetBottom(context, "", AddressEdit(info));
        } else {
          Navigator.pop(context, info.address);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(10.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30.0),
          vertical: ScreenUtil().setWidth(20.0),
        ),
        decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),
        child: Row(
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              child: info.coinName == CoinType.N.name
                  ? Image.asset(
                'assets/img/ast.png',
                fit: BoxFit.cover,
              )
                  : ImageNetWork(imageUrl:
                info.coinIcon ?? "",
                placeholder: "assets/img/list_default.png",
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.name ?? '',
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          info.address ?? "",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontSize: ScreenUtil().setSp(26.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
