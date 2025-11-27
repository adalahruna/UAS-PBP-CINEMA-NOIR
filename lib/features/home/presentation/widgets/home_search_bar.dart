import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/home/data/models/cinema_model.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeSearchBar extends StatefulWidget {
  final List<MovieModel> movies;
  final Function(String) onSearchChanged;

  const HomeSearchBar({
    super.key,
    required this.movies,
    required this.onSearchChanged,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  String _query = '';

  // Filtered lists
  List<MovieModel> _filteredMovies = [];
  List<CinemaModel> _filteredCinemas = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (_query.isNotEmpty) {
        _showOverlay();
      }
    } else {
      // Delay removal to allow tap events on the overlay to register
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    if (text == _query) return;

    setState(() {
      _query = text;
      _updateFilteredList();
    });

    widget.onSearchChanged(_query);

    if (_query.isNotEmpty && _focusNode.hasFocus) {
      if (_overlayEntry == null) {
        _showOverlay();
      } else {
        _overlayEntry!.markNeedsBuild();
      }
    } else {
      _removeOverlay();
    }
  }

  void _updateFilteredList() {
    if (_query.isEmpty) {
      _filteredMovies = [];
      _filteredCinemas = [];
      return;
    }

    final lowerQuery = _query.toLowerCase();

    _filteredMovies = widget.movies
        .where((movie) => movie.title.toLowerCase().contains(lowerQuery))
        .take(3) // Limit to 3 movies
        .toList();

    _filteredCinemas = CinemaModel.mockCinemas
        .where((cinema) => cinema.name.toLowerCase().contains(lowerQuery))
        .take(3) // Limit to 3 cinemas
        .toList();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    // Use the key from the Container wrapping the TextField to get accurate size and position
    final RenderBox? renderBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (renderBox == null) return;

    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(16),
            color: AppColors.darkGrey,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                color: AppColors.darkGrey,
              ),
              child: (_filteredMovies.isEmpty && _filteredCinemas.isEmpty)
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Tidak ada hasil ditemukan.',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        if (_filteredMovies.isNotEmpty) ...[
                          _buildSectionHeader('Movies'),
                          ..._filteredMovies.map((movie) => _buildMovieItem(movie)),
                        ],
                        if (_filteredMovies.isNotEmpty && _filteredCinemas.isNotEmpty)
                          const Divider(color: AppColors.textGrey, height: 1),
                        if (_filteredCinemas.isNotEmpty) ...[
                          _buildSectionHeader('Cinemas'),
                          ..._filteredCinemas.map((cinema) => _buildCinemaItem(cinema)),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMovieItem(MovieModel movie) {
    return ListTile(
      leading: SizedBox(
        width: 40,
        height: 60,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: movie.getFullPosterUrl(),
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: AppColors.darkGrey),
            errorWidget: (context, url, error) => const Icon(Icons.error, color: AppColors.textGrey),
          ),
        ),
      ),
      title: Text(
        movie.title,
        style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          const Icon(Icons.star, color: AppColors.gold, size: 14),
          const SizedBox(width: 4),
          Text(
            movie.voteAverage.toStringAsFixed(1),
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
      onTap: () {
        context.push('/movies/${movie.id}/ticket', extra: movie);
      },
    );
  }

  Widget _buildCinemaItem(CinemaModel cinema) {
    return ListTile(
      leading: const Icon(Icons.theaters_outlined, color: AppColors.textWhite),
      title: Text(
        cinema.name,
        style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        cinema.location,
        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected Cinema: ${cinema.name}')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: (screenWidth * 0.85).clamp(0, 600),
        ),
        child: CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            key: _textFieldKey, // Kunci ini penting untuk mendapatkan ukuran yang benar
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                hintText: 'Cari film atau bioskop',
                hintStyle: const TextStyle(color: AppColors.textGrey),
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                filled: true,
                fillColor: AppColors.darkGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: AppColors.gold, width: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}