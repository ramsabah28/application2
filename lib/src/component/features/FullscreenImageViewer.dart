import 'package:flutter/material.dart';

class FullscreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullscreenImageViewer({super.key, required this.imageUrls, this.initialIndex = 0});

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  Size? _childSize;
  bool _isZoomed = false;

  double _currentScale() {
    final Matrix4 v = _transformationController.value;
    return v.getMaxScaleOnAxis();
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1}/${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: _isZoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
        onPageChanged: (i) {
          setState(() => _currentIndex = i);
          _transformationController.value = Matrix4.identity();
          _isZoomed = false;
        },
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          final url = widget.imageUrls[index];
          return GestureDetector(
            onDoubleTapDown: (d) => _doubleTapDetails = d,
            onDoubleTap: () {
              final Matrix4 current = _transformationController.value;
              final bool isZoomed = current != Matrix4.identity();
              if (isZoomed) {
                _transformationController.value = Matrix4.identity();
                setState(() => _isZoomed = false);
              } else {
                final Size size = _childSize ?? MediaQuery.of(context).size;
                final Offset center = Offset(size.width / 2, size.height / 2);
                final Matrix4 m = Matrix4.identity()
                  ..translate(center.dx, center.dy)
                  ..scale(2.0)
                  ..translate(-center.dx, -center.dy);
                _transformationController.value = m;
                setState(() => _isZoomed = true);
              }
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(80),
              panEnabled: true,
              scaleEnabled: true,
              onInteractionStart: (_) {
                final bool nowZoomed = _currentScale() > 1.01;
                if (nowZoomed != _isZoomed) {
                  setState(() => _isZoomed = nowZoomed);
                }
              },
              onInteractionUpdate: (_) {
                final bool nowZoomed = _currentScale() > 1.01;
                if (nowZoomed != _isZoomed) {
                  setState(() => _isZoomed = nowZoomed);
                }
              },
              onInteractionEnd: (_) {
                final bool nowZoomed = _currentScale() > 1.01;
                if (nowZoomed != _isZoomed) {
                  setState(() => _isZoomed = nowZoomed);
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _childSize = constraints.biggest;
                  return Center(
                    child: Hero(
                      tag: 'image_viewer_${index}_$url',
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}


