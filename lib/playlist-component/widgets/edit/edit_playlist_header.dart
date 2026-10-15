import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/playlist-component/models/playlist_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';

class EditPlaylistHeaderWidget extends StatefulWidget {
  final Playlist playlist;
  final void Function(Uint8List? image, String name) onHeaderUpdated;

  const EditPlaylistHeaderWidget({
    super.key,
    required this.playlist,
    required this.onHeaderUpdated,
  });

  @override
  State<StatefulWidget> createState() => _PlaylistHeaderWidget();
}

class _PlaylistHeaderWidget extends State<EditPlaylistHeaderWidget> {
  late final TextEditingController _nameTextController;
  late FocusNode _nameFocusNode;

  Uint8List? _image;

  @override
  void initState() {
    super.initState();

    _nameFocusNode = FocusNode()
      ..addListener(
        () => setState(() {}),
      );
    _nameTextController = TextEditingController(text: widget.playlist.name);
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _nameFocusNode.unfocus();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      child: Card(
        margin: Theme.of(context).cardTheme.margin,
        child: Column(
          children: [
            _buildImagePicker(),
            _buildTextField(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _selectPlaylistImage,
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 500),
            firstChild: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: const ImageIcon(
                ResizeImage(
                  AssetImage('assets/images/add-image.png'),
                  width: 1000,
                  height: 1000,
                ),
                color: Colors.grey,
                size: 150,
              ),
            ),
            secondChild: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 200,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                image: DecorationImage(
                  image: Image.memory(_image ?? Uint8List(0)).image,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            crossFadeState: _image == null
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          ),
        ),
        _image != null
            ? Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 28,
                    ),
                    onPressed: _onRemoveImagePressed,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildTextField() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: _nameTextController,
        focusNode: _nameFocusNode,
        showCursor: false,
        textInputAction: TextInputAction.send,
        decoration: InputDecoration(
          fillColor: Theme.of(context).cardTheme.color,
          labelText: 'Name',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ),
          suffixIcon: _buildSuffixIcon(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        onChanged: (text) => _onNameUpdated(),
      ),
    );
  }

  Widget _buildSuffixIcon() {
    return IconButton(
      icon: Icon(
        _nameFocusNode.hasFocus ? Icons.arrow_upward : Icons.arrow_downward,
        color: _nameFocusNode.hasFocus
            ? Theme.of(context).iconTheme.color
            : Theme.of(context).primaryColor,
      ),
      onPressed: () async => _onFocusChanged(),
    );
  }

  void _onFocusChanged() {
    _nameFocusNode.hasFocus
        ? _nameFocusNode.unfocus()
        : _nameFocusNode.requestFocus();
  }

  void _onRemoveImagePressed() async {
    _image = null;
    setState(() {});
  }

  void _selectPlaylistImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'heic',
          'heif',
        ],
        withData: true,
        lockParentWindow: true,
      );
      if (result?.count != 1) {
        return;
      }
      if (mounted) {
        _image = result!.files.first.bytes;
      }
    } on PlatformException catch (pe) {
      await Logger.logAsync(
        LogEvent<EditPlaylistHeaderWidget>(
          severity: Severity.error,
          tag: Tag.widget,
          line: 'Unsupported operation: $pe',
        ),
      );
    } catch (e) {
      await Logger.logAsync(
        LogEvent<EditPlaylistHeaderWidget>(
          severity: Severity.error,
          tag: Tag.widget,
          line: e.toString(),
        ),
      );
    } finally {
      setState(() => {});
    }
  }

  void _onNameUpdated() {
    if (_nameTextController.text.isNotEmpty) {
      widget.onHeaderUpdated(_image, _nameTextController.text);
    }
  }
}
