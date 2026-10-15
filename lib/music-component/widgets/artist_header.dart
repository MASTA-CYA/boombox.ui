import 'package:boombox/common/widgets/read_more_text.dart';
import 'package:boombox/music-component/models/artist_model.dart';
import 'package:boombox/music-component/services/metadata_service.dart';
import 'package:flutter/material.dart';

class ArtistHeaderWidget extends StatefulWidget {
  final String image;
  final Artist artist;

  const ArtistHeaderWidget({
    super.key,
    required this.image,
    required this.artist,
  });

  @override
  State<StatefulWidget> createState() => _ArtistHeaderWidget();
}

class _ArtistHeaderWidget extends State<ArtistHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 350),
      child: Card(
        margin: Theme.of(context).cardTheme.margin,
        child: Column(
          children: [
            _buildArtistImage(),
            _buildNameAndDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistImage() {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          image: DecorationImage(
            image: widget.image.isNotEmpty
                ? ResizeImage(
                    Image.network(widget.image).image,
                    width: 1000,
                    height: 1000,
                    allowUpscaling: true,
                  )
                : Image.asset('assets/images/artist.png').image,
            fit: widget.image.isNotEmpty ? BoxFit.fill : BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildNameAndDetails() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildName(),
          const SizedBox(
            height: 8,
          ),
          _buildBio(),
          const SizedBox(
            height: 8,
          ),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildName() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        widget.artist.name,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.bodyLarge?.merge(
              const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
    );
  }

  Widget _buildBio() {
    return FutureBuilder(
      future: MetaDataService().getArtistBio(widget.artist.name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return ReadMoreTextWidget(text: snapshot.data!);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          '${widget.artist.albums.toString()} albums',
          style: Theme.of(context).textTheme.bodyMedium?.merge(
                TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
        ),
        _buildDetailsSeparator(),
        Text(
          '${widget.artist.tracks.toString()} songs',
          style: Theme.of(context).textTheme.bodyMedium?.merge(
                TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildDetailsSeparator() {
    return Container(
      width: 5.5,
      height: 5.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
