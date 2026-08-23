import 'package:boombox/common/models/serializable_model.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:boombox/news-component/services/news_service.dart';
import 'package:boombox/settings-component/models/news_source_model.dart';
import 'package:provider/provider.dart';

class NewsAdditionalInformationWidget extends StatefulWidget {
  const NewsAdditionalInformationWidget({super.key});

  @override
  State<StatefulWidget> createState() => _NewsAdditionalInformationWidget();
}

class _NewsAdditionalInformationWidget
    extends State<NewsAdditionalInformationWidget> {
  late List<SerializableModel<NewsSource>> _sources;

  @override
  void initState() {
    super.initState();

    _sources = [];

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _sources = await Provider.of<NewsService>(
          context,
          listen: false,
        ).getNewsSourcesAsync();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: _sources.length,
      itemBuilder: (context, index) => CheckboxListTile(
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.network(
                _sources.elementAt(index).model.image,
              ).image,
            ),
          ),
        ),
        title: Text(_sources.elementAt(index).model.name),
        subtitle: Text(_sources.elementAt(index).model.url),
        value: _sources.elementAt(index).model.isSelected,
        onChanged: (isSelected) =>
            _onNewsSourceSelected(_sources.elementAt(index).model, isSelected),
      ),
    );
  }

  void _onNewsSourceSelected(NewsSource source, bool? isSelected) async {
    if (isSelected.isNull) return;

    _sources.modifyElement(
      find: (element) => element.model.name.equals(source.name),
      property: 'isSelected',
      value: isSelected!,
    );

    await Provider.of<NewsService>(
      context,
      listen: false,
    ).updateNewsSourceAsync(source, isSelected);

    setState(() {});
  }
}
