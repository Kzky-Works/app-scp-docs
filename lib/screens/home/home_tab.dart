import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/wiki/wiki_injection.dart';
import '../../providers/domain_provider.dart';
import '../../providers/text_scale_provider.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  InAppWebViewController? _controller;

  Future<void> _applyInjection(InAppWebViewController c) async {
    await c.evaluateJavascript(source: WikiInjection.hideChromeScript());
    final pct = ref.read(textScalePercentProvider);
    await c.evaluateJavascript(source: WikiInjection.textSizeScript(pct));
  }

  @override
  Widget build(BuildContext context) {
    final domain = ref.watch(domainProvider);
    final initial = WebUri('https://$domain/');
    final scale = ref.watch(textScalePercentProvider);

    ref.listen(textScalePercentProvider, (prev, next) async {
      final c = _controller;
      if (c == null) return;
      await c.evaluateJavascript(source: WikiInjection.textSizeScript(next));
    });

    return Column(
      children: [
        Material(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.format_size, size: 20),
                Expanded(
                  child: Slider(
                    value: scale,
                    min: 75,
                    max: 200,
                    divisions: 125,
                    label: '${scale.toStringAsFixed(0)}%',
                    onChanged: (v) =>
                        ref.read(textScalePercentProvider.notifier).setPercent(v),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: InAppWebView(
            key: ValueKey(domain),
            initialUrlRequest: URLRequest(url: initial),
            initialSettings: InAppWebViewSettings(
              useHybridComposition: true,
              transparentBackground: false,
            ),
            onWebViewCreated: (c) => _controller = c,
            onLoadStop: (controller, uri) async {
              _controller = controller;
              await _applyInjection(controller);
            },
          ),
        ),
      ],
    );
  }
}
