import 'package:flutter/material.dart';

class AwarenessCarousel2 extends StatefulWidget {
  final List<ImageProvider> images;
  final List<String> texts;
  const AwarenessCarousel2({
    super.key,
    required this.images,
    required this.texts,
  });

  @override
  State<AwarenessCarousel2> createState() => _AwarenessCarousel2State();
}

class _AwarenessCarousel2State extends State<AwarenessCarousel2> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.images.length;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: itemCount,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(
                        child: Ink.image(
                          image: widget.images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          widget.texts[index],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(itemCount, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: active ? 20 : 8,
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
