import 'package:boombox/music-component/models/folder_model.dart';
import 'package:flutter/material.dart';

class FolderViewWidget extends StatefulWidget {
  final List<Folder> folders;
  final void Function(String id) onFolderSelected;

  const FolderViewWidget({
    super.key,
    required this.folders,
    required this.onFolderSelected,
  });

  @override
  State<StatefulWidget> createState() => _FolderViewWidget();
}

class _FolderViewWidget extends State<FolderViewWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: widget.folders.length,
      itemBuilder: (context, index) => Column(
        children: [
          ListTile(
            visualDensity: VisualDensity.comfortable,
            leading: const ImageIcon(
              ResizeImage(
                AssetImage('assets/images/folder.png'),
                width: 70,
                height: 70,
                allowUpscaling: false,
              ),
            ),
            title: Text(widget.folders.elementAt(index).name),
            subtitle: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const ImageIcon(
                        ResizeImage(
                          AssetImage('assets/images/album.png'),
                          width: 70,
                          height: 70,
                          allowUpscaling: false,
                        ),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.folders.elementAt(index).folders.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.merge(
                              TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const ImageIcon(
                        ResizeImage(
                          AssetImage('assets/images/cd.png'),
                          width: 70,
                          height: 70,
                          allowUpscaling: false,
                        ),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.folders.elementAt(index).items.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.merge(
                              TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () =>
                widget.onFolderSelected(widget.folders.elementAt(index).path),
          ),
          const Divider(
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),
        ],
      ),
    );
  }
}
