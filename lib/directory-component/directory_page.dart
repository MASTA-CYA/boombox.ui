import 'package:boombox/common/helpers/color_helper.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/helpers/enums/snackbar_type_enum.dart';
import 'package:boombox/common/helpers/snackbar_helper.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/common/widgets/trailing_card.dart';
import 'package:boombox/directory-component/services/directory_service.dart';
import 'package:boombox/directory-component/widgets/action_button.dart';
import 'package:boombox/directory-component/widgets/expandable_fab.dart';
import 'package:boombox/directory-component/widgets/no_directories_view.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DirectoryPage extends StatefulWidget {
  const DirectoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _DirectoriesPage();
}

class _DirectoriesPage extends State<DirectoryPage> {
  final String _title = 'Folders';

  // bool _hasDirectories = false;

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<DirectoryPage>(title: _title),
          drawer: null,
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: _buildDirectoryScaffold(),
          ),
          floatingActionButton: ExpandableFabWidget(
            distance: 112,
            children: [
              _buildDeleteSweepButton(),
              _buildSyncActionButton(),
              ActionButton(
                onPressed: () async => await _onOpenFilePickerPressed(),
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteSweepButton() {
    return Consumer<DirectoryService>(
      builder: (context, service, child) => FutureBuilder(
        future: service.hasDirectoryListingAsync(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data!) {
            return ActionButton(
              onPressed: () => _onRemoveAllDirectories(),
              icon: const Icon(
                Icons.delete_sweep,
                color: Colors.white,
              ),
            );
          } else {
            return ActionButton(
              onPressed: null,
              icon: Icon(
                Icons.delete_sweep,
                color: ColorHelper.lighten(
                  Theme.of(context).colorScheme.secondary,
                  50,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSyncActionButton() {
    return Consumer<DirectoryService>(
      builder: (context, service, child) => FutureBuilder(
        future: service.hasDirectoryListingAsync(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data!) {
            return ActionButton(
              onPressed: () => _onSyncPressed(),
              icon: const Icon(
                Icons.sync,
                color: Colors.white,
              ),
            );
          } else {
            return ActionButton(
              onPressed: null,
              icon: Icon(
                Icons.sync,
                color: ColorHelper.lighten(
                  Theme.of(context).colorScheme.secondary,
                  50,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDirectoryScaffold() {
    return Column(
      children: [
        _buildDirectoryListing(),
      ],
    );
  }

  Widget _buildDirectoryListing() {
    return Consumer<DirectoryService>(
      builder: (context, service, child) => FutureBuilder(
        future: service.getDirectoryListingAsync(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.isEmpty) {
              return const Center(child: NoDirectoriesViewWidget());
            } else {
              return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.entries.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          leading: TrailingCardWidget(
                            child: Text(
                              snapshot.data!.entries
                                  .elementAt(index)
                                  .value
                                  .toString(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          title:
                              Text(snapshot.data!.entries.elementAt(index).key),
                          subtitle: Text(
                            'SD Card',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.merge(
                                  TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                          ),
                          trailing: GestureDetector(
                            onTap: () async => _onRemoveDirectoryPressed(
                              snapshot.data!.entries.elementAt(index).key,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const Divider(
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                      ],
                    );
                  });
            }
          } else {
            return const CircularProgressIndicatorWidget();
          }
        },
      ),
    );
  }

  void _onRemoveDirectoryPressed(String displayName) async {
    await Provider.of<DirectoryService>(
      context,
      listen: false,
    ).removeDirectoryAsync(displayName: displayName);
  }

  Future<void> _onOpenFilePickerPressed() async {
    try {
      String? path = await FilePicker.platform.getDirectoryPath(
        lockParentWindow: true,
      );
      if (path?.isEmpty ?? true) {
        return;
      }
      if (mounted) {
        await Provider.of<DirectoryService>(
          context,
          listen: false,
        ).addDirectoriesAsync(path!);
      }
    } on PlatformException catch (ex) {
      await Logger.logAsync(
        LogEvent<DirectoryPage>(
          severity: Severity.error,
          tag: Tag.widget,
          line: 'Unsupported operation: $ex',
        ),
      );
    } catch (ex) {
      await Logger.logAsync(
        LogEvent<DirectoryPage>(
          severity: Severity.error,
          tag: Tag.widget,
          line: ex.toString(),
        ),
      );
    } finally {
      // _hasDirectories = true;
      setState(() => {});
    }
  }

  void _onRemoveAllDirectories() async {
    await Provider.of<DirectoryService>(context, listen: false)
        .removeDirectoryAsync();
  }

  void _onSyncPressed() async {
    SnackbarHelper.showMessage(
      context,
      SnackbarType.information,
      'Sync started. This might take a while',
    );
    await Provider.of<DirectoryService>(
      context,
      listen: false,
    ).syncDirectoriesAsync();
    if (mounted) {
      SnackbarHelper.showMessage(
        context,
        SnackbarType.information,
        'Sync complete',
      );
    }
  }
}
