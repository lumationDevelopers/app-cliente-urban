import 'dart:convert';
import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'dart:io';

class ChangePersonalInfoPage extends StatefulWidget {
  @override
  _ChangePersonalInfoPageState createState() => _ChangePersonalInfoPageState();
}

class _ChangePersonalInfoPageState extends State<ChangePersonalInfoPage> {
  var _sheetController = SnappingSheetController();
  final _form = GlobalKey<FormState>();

  final _api = new Api();
  final _utils = new Utils();

  var name = '';
  var lastname = '';

  bool chooseImage = false;
  File _image;
  bool imageCaptured = false;
  int imageCapturedType = 0;
  final picker = ImagePicker();

  Future getImageFromGallery() async {
    var pickedFile;
    try {
      pickedFile = await picker.getImage(source: ImageSource.gallery, maxWidth: 256.0, maxHeight: 256.0);
    } catch (e){
      return 0;
    }


    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imageCapturedType = 0;
      });

      cropImage();
    }


  }

  Future getImageFromCamera() async {
    var pickedFile;

    try {
      pickedFile = await picker.getImage(source: ImageSource.camera, maxWidth: 256.0, maxHeight: 256.0);
    } catch (e) {
      return 0;
    }
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imageCapturedType = 1;
      });

      cropImage();
    }

  }

  void cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        maxHeight: 1024,
        maxWidth: 1024,
        compressQuality: 100,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );

    if (croppedFile != null) {
      setState(() {
        _image = File(croppedFile.path);
        imageCaptured = true;
      });
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

    setState(() {
      name = bloc.userInfo['name'];
      lastname = bloc.userInfo['lastname'];
    });
    return Stack(
      children: <Widget>[
        Scaffold(
            appBar: urbanAppBar(context, 'Datos personales', false),
            body: Stack(
              children: <Widget>[
                Container(
                    child: Form(
                      key: _form,
                      child: ListView(
                        padding: EdgeInsets.all(26.0),
                        children: <Widget>[
                          Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(120.0),
                                        child: StreamBuilder(
                                          stream: bloc.userStream,
                                          builder: (context, snapshot) {
                                            if (snapshot.data == null || snapshot.data['avatar'] == null) {
                                              return Icon(Icons.person_outline, size: 120.0);
                                            } else {
                                              return SizedBox(
                                                height: 120.0,
                                                child: Image.network(
                                                  snapshot.data['avatar'].toString() ?? '',
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            }
                                          },
                                        )
                                    ),
                                  ),
                                  Container(
                                      width: 120.0,
                                      height: 120.0,
                                      alignment: Alignment.bottomLeft,
                                      child: SizedBox(
                                        width: 32.0,
                                        height: 32.0,
                                        child: FlatButton(
                                          padding: EdgeInsets.all(0),
                                          onPressed: () {
                                            FocusScope.of(context).unfocus();
                                            setState(() {
                                              chooseImage = true;
                                            });
                                          },
                                          color: Colors.orangeAccent,
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.black,
                                          ),
                                          shape: CircleBorder(),
                                        ),
                                      )
                                  )
                                ],
                              )
                          ),
                          Padding(padding: EdgeInsets.only(top: 24.0)),
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
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(6.0),
                                    bottomRight: Radius.circular(6.0)
                                ),
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
                            initialValue: lastname,
                            onChanged: (v) => lastname = v,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(6.0),
                                    bottomRight: Radius.circular(6.0)
                                ),
                              ),
                              labelText: 'Apellido',
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 32.0)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery
                                .of(context)
                                .size
                                .width * 0.15),
                            child: defaultButton(120.0, 'Actualizar', () async {
                              if (_form.currentState.validate()) {
                                _form.currentState.save();

                                _utils.loadingDialog(context);


                                final response = await _api.putByPath(context, 'users/${bloc.userInfo['_id']}', {
                                  "name": name,
                                  "lastname": lastname
                                });

                                final data = jsonDecode(response.body);
                                if (data['success'] == false) {
                                  _utils.closeDialog(context);
                                  return _utils.messageDialog(context, 'Error', data['error']['errors'][0]);
                                }

                                bloc.modifyUserData(data['data']);

                                _utils.closeDialog(context);

                                Navigator.of(context).pop();

                              }
                            }),
                          ),
                        ],
                      ),
                    )
                ),
                if (chooseImage)
                  SnappingSheet(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          chooseImage = false;
                        });
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                    snappingSheetController: _sheetController,
                    lockOverflowDrag: true,
                    initSnapPosition: SnapPosition(positionFactor: 0.4),
                    sheetBelow: SnappingSheetContent(
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24.0),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Editar foto',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26.0),
                                  ),
                                ),
                                Spacer(),
                                Expanded(
                                  flex: 2,
                                  child: defaultButton(
                                      double.infinity,
                                      'Seleccionar foto',
                                          () {
                                            setState(() {
                                              chooseImage = false;
                                            });

                                            getImageFromGallery();
                                          }
                                  ),
                                ),
                                Spacer(),
                                Expanded(
                                  flex: 2,
                                  child: defaultButton(
                                      double.infinity,
                                      'Tomar foto',
                                          () {
                                            setState(() {
                                              chooseImage = false;
                                            });
                                            getImageFromCamera();
                                          },
                                      color: Colors.yellow[700],
                                      textColor: Colors.black
                                  ),
                                ),
                                Spacer()
                              ],
                            )
                        )
                    ),
                  ),

              ],
            )
        ),
        if (imageCaptured == true)
          Container(
            padding: EdgeInsets.all(24.0),
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.circular(180.0),
                    child: Image.file(_image),
                ),
                Padding(padding: EdgeInsets.only(top: 32.0)),
                Text(
                    '¿Quieres usar esta foto?',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontFamily: 'Lato',
                        decoration: TextDecoration.none
                    ),
                ),
                Padding(padding: EdgeInsets.only(top: 32.0)),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: defaultButton(
                          double.infinity,
                          'Repetir',
                              () => imageCapturedType < 1 ? getImageFromGallery() : getImageFromCamera()
                      ),
                    ),
                    Spacer(),
                    Expanded(
                      flex: 6,
                      child: defaultButton(
                          double.infinity,
                          'Aceptar',
                          () async {
                            final response = await _api.uploadFile(_image, 'users/${bloc.userInfo['_id']}', 'avatar', method: 'PUT');

                            if (response.statusCode == 200) {

                              final userResponse = await _api.getByPath(context, 'auth/me');

                              if (userResponse.statusCode != 200) {
                                _utils.closeDialog(context);
                                return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
                              }

                              final userData = jsonDecode(userResponse.body);

                              bloc.modifyUserData(userData['data']['user']);

                              setState(() {
                                imageCaptured = false;
                              });
                            } else {
                              _utils.messageDialog(context, 'Error', 'No se ha actualizado la foto de perfil. Inténtalo de nuevo');
                            }

                          },
                          color: Colors.yellow[700],
                          textColor: Colors.black
                      )
                    )
                  ],
                )
              ],
            ),
          )
      ],
    );
  }
}

