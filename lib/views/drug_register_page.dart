import 'dart:io';

import 'package:app3idade_caretaker/models/drug.dart';
import 'package:app3idade_caretaker/services/drug_service.dart';
import 'package:app3idade_caretaker/widgets/gallery_camera_picker.dart';
import 'package:app3idade_caretaker/widgets/selected_images_widget.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class DrugRegisterPage extends StatefulWidget {
  const DrugRegisterPage({Key? key}) : super(key: key);
  @override
  State<DrugRegisterPage> createState() => _DrugRegisterPageState();
}

class _DrugRegisterPageState extends State<DrugRegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _strengthController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _images = [];
  final _name = 'Nome:';
  final _strength = 'Dose (ex: 50 mg):';
  final double _labelWidth = 150;

  final DrugService drugService = DrugService();

  void _submit(BuildContext context) async {
    Drug drug = Drug.newDrug(_nameController.text.trim(), _strengthController.text.trim());
    try {
      var navigator = Navigator.of(context);
      var messenger = ScaffoldMessenger.of(context);
      await drugService.createDrug(drug, _images);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text("Medicamento criado com sucesso")),
      );
    } on Exception catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $exception")),
      );
    }
  }

  Future<void> _selectImages() async {
    File? file = await showGalleryCameraPicker(context);
    if (file == null) return;
    if (_images.any((fileI) => fileI.path == file.path)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imagem já adicionada')));
      return;
    }
    setState(() {
      _images.add(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar medicamento'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _submit(context);
          }
        },
        child: const Icon(Icons.done),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            buildInputRow(_name, _nameController, TextInputType.name, validator: _mandatoryValidator),
            buildInputRow(_strength, _strengthController, TextInputType.name),
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: _selectImages,
                  child: const Text('Selecione fotos'),
                ),
                const SizedBox(width: 8.0),
                Text(_images.isNotEmpty ? '${_images.length} imagem(ns) selecionadas' : 'Nenhuma imagem selecionada'),
              ],
            ),
            if (_images.isNotEmpty)
              SelectedImagesWidget(
                  images: _images,
                  onImageRemoved: (index) {
                    setState(() {
                      _images.removeAt(index);
                    });
                  }),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget buildInputRow(String label, TextEditingController controller, TextInputType inputType,
      {String? Function(String?)? validator, bool obscureText = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: _labelWidth, child: Text(label)),
        Expanded(
          child: TextFormField(
            keyboardType: inputType,
            controller: controller,
            validator: validator,
            obscureText: obscureText,
          ),
        )
      ],
    );
  }

  String? _mandatoryValidator(value) {
    if (value!.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }
}
