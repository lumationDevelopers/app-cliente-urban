import 'dart:async';
import 'dart:convert';

import 'package:after_init/after_init.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class AddFavoriteLocationInfoPage extends StatefulWidget {
  @override
  _AddFavoriteLocationInfoPageState createState() => _AddFavoriteLocationInfoPageState();
}

class _AddFavoriteLocationInfoPageState extends State<AddFavoriteLocationInfoPage> with AfterInitMixin<AddFavoriteLocationInfoPage> {
  final _form = GlobalKey<FormState>();

  final _api = new Api();
  final _utils = new Utils();

  List addressTypes = [];

  var name = '';
  var address = '';

  bool showIcons = false;

  var _sheetController = new SnappingSheetController();

  String iconSelected;

  @override
  void didInitState() {
    // TODO: implement didInitState

    getData(context);
  }

  getData(context) async {
    final addressTypesResponse = await _api.getByPath(context, 'addresstype');

    final addressTypesData = jsonDecode(addressTypesResponse.body);

    if (addressTypesResponse.statusCode == 200) {

      print(addressTypesData['data']);
      setState(() {
        addressTypes = addressTypesData['data'];
      });
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      _utils.messageDialog(context, 'Error', 'Hubo un error en obtener la información. Inténtalo mas tarde');

    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //BackButtonInterceptor.add(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.of(context).pop();
    return true;

  }

  @override
  void dispose() {
    super.dispose();
    //BackButtonInterceptor.remove(myInterceptor);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context).userBloc;
    final addressBloc = Provider.of(context).addressBloc;
    final AddFavoriteLocationInfoPageArguments args = ModalRoute.of(context).settings.arguments;

    setState(() {
      address = args.addressName;
    });


    return Scaffold(
      appBar: urbanAppBar(context, 'Agregar dirección', false),
      body: Stack(
        children: <Widget>[
            Container(
              child: Form(
                key: _form,
                child: ListView(
                  padding: EdgeInsets.all(26.0),
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() {
                          showIcons = true;
                        });
                        Timer(Duration(milliseconds: 100), () {
                          _sheetController.snapToPosition(SnapPosition(positionFactor: 0.0));
                        });
                      },
                      child: ListTile(
                        leading: Container(
                          width: 58.0,
                          height: 58.0,
                          decoration: BoxDecoration(
                            color: Colors.yellow[600],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(Icons.star, size: 42.0, color: Colors.white),
                        ),
                        title: Text('Seleccionar tipo de dirección'),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 16.0)),
                    TextFormField(
                      validator: (v) {
                        if (v == '') {
                          return 'Este campo s obligatorio';
                        }
                        return null;
                      },
                      initialValue: name,
                      onChanged: (v) => name = v,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0)
                        ),
                        labelText: 'Nombre',
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 16.0)),
                    TextFormField(
                      validator: (v) {
                        if (v == '') {
                          return 'Este campo s obligatorio';
                        }
                        return null;
                      },
                      initialValue: address,
                      enabled: false,
                      onChanged: (v) => address = v,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0)
                        ),
                        labelText: 'Dirección',
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 32.0)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery
                          .of(context)
                          .size
                          .width * 0.15),
                      child: defaultButton(120.0, 'Agregar', () async {
                        if (_form.currentState.validate()) {
                          if (iconSelected == null) {
                            return _utils.messageDialog(context, 'Selecciona un tipo de dirección', 'Debes seleccionar un tipo de dirección');
                          }

                          _form.currentState.save();

                          _utils.loadingDialog(context);

                          print(bloc.userInfo['_id']);

                          final response = await _api.postByPath(context, 'address', {
                            "user": bloc.userInfo['_id'],
                            "address_name": name,
                            "address": address,
                            "coordinates": '${args.location.latitude},${args.location.longitude}',
                            "address_type": iconSelected
                          });

                          final data = jsonDecode(response.body);

                          print(data);
                          if (response.statusCode != 200) {
                            _utils.closeDialog(context);
                            return _utils.messageDialog(context, 'Error', 'No se ha agregado la dirección. Inténtalo de nuevo.');
                          }

                          final addresses = addressBloc.addresses;
                          addresses.add(data['data']);

                          addressBloc.modifyAddresses(addresses);

                          _utils.closeDialog(context);

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                      }),
                    ),
                  ],
                ),
              )
          ),
          if (showIcons)
            SnappingSheet(
              child: InkWell(
                onTap: () {
                  _sheetController.snapToPosition(SnapPosition(positionFactor: -0.8));

                  Timer(Duration(milliseconds: 400), () {
                    setState(() {
                      showIcons = false;
                    });
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
              snappingSheetController: _sheetController,
              lockOverflowDrag: true,
              initSnapPosition: SnapPosition(positionFactor: -1.0),
              snapPositions: [
                SnapPosition(positionFactor: -1.0)
              ],
              grabbingHeight: MediaQuery.of(context).padding.bottom + 160,
              grabbing: InkWell(
                onTap: () => FocusManager.instance.primaryFocus.unfocus(),
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 18.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.2),
                        )],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(22.0),
                          topRight: Radius.circular(22.0),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                              height: 150.0,
                              width: double.infinity,
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                      child: ListView.builder(
                                        padding: EdgeInsets.only(left: 18.0, right: 18.0),
                                        itemCount: addressTypes.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  iconSelected = addressTypes[index]['_id'];
                                                });
                                                _sheetController.snapToPosition(SnapPosition(positionFactor: -0.8));

                                                Timer(Duration(milliseconds: 400), () {
                                                  setState(() {
                                                    showIcons = false;
                                                  });
                                                });
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius: BorderRadius.circular(6.0)
                                                    ),
                                                    margin: EdgeInsets.only(right: 12.0),
                                                    padding: EdgeInsets.all(12.0),
                                                    width: 86.0,
                                                    height: 86.0,
                                                    child: SvgPicture.network(addressTypes[index]['icon'].toString(), color: Colors.white),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 13.0),
                                                    child: Text(addressTypes[index]['name'].toString()),
                                                  )
                                                ],
                                              )
                                          );
                                        },
                                      )
                                  ),
                                ],
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ]
      )
    );
  }


}

class AddFavoriteLocationInfoPageArguments {
  final LatLng location;
  final String addressName;

  AddFavoriteLocationInfoPageArguments(this.location, this.addressName);
}