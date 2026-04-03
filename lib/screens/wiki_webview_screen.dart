import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data/wiki_readability_script.dart';
import '../providers/favorites_controller.dart';
import '../theme/scp_reader_theme.dart';

/// Wikidot 表示 + 履歴に応じた戻る制御（[PopScope] でシステム戻るを処理）。
class WikiWebViewScreen extends StatefulWidget {
  const WikiWebViewScreen({
    super.key,
    required this.initialUrl,
    required this.pageTitle,
  });

  final String initialUrl;
  final String pageTitle;

  @override
  State<WikiWebViewScreen> createState() => _WikiWebViewScreenState();
}

class _WikiWebViewScreenState extends State<WikiWebViewScreen> {
  late final WebViewController _controller;
  String? _currentUrl;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) => _onPageFinished(),
          onWebResourceError: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _onPageFinished() async {
    try {
      await _controller.runJavaScript(WikiReadabilityScript.inject());
    } catch (_) {
      /* 読み込み途中のフレームでは失敗しうる */
    }
    final u = await _controller.currentUrl();
    if (mounted) {
      setState(() {
        _loading = false;
        _currentUrl = u ?? _currentUrl;
      });
    }
  }

  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _goForward() async {
    if (await _controller.canGoForward()) {
      await _controller.goForward();
    }
  }

  Future<void> _reload() => _controller.reload();

  Future<void> _onSystemBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = _currentUrl ?? widget.initialUrl;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onSystemBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.pageTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const LinearProgressIndicator(
                minHeight: 2,
                color: ScpReaderTheme.accent,
                backgroundColor: Color(0xFF222222),
              ),
          ],
        ),
        bottomNavigationBar: _WebBottomBar(
          onBack: _goBack,
          onForward: _goForward,
          onReload: _reload,
          currentUrl: url,
        ),
      ),
    );
  }
}

class _WebBottomBar extends StatelessWidget {
  const _WebBottomBar({
    required this.onBack,
    required this.onForward,
    required this.onReload,
    required this.currentUrl,
  });

  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onReload;
  final String currentUrl;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0A0A0A),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: ScpReaderTheme.accent, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Consumer<FavoritesController>(
            builder: (context, fav, _) {
              final starred = fav.isFavorite(currentUrl);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _BarAction(
                    icon: Icons.arrow_back,
                    label: '戻る',
                    onPressed: onBack,
                  ),
                  _BarAction(
                    icon: Icons.arrow_forward,
                    label: '進む',
                    onPressed: onForward,
                  ),
                  _BarAction(
                    icon: Icons.refresh,
                    label: '更新',
                    onPressed: onReload,
                  ),
                  _BarAction(
                    icon: starred ? Icons.star : Icons.star_border,
                    label: 'お気に入り',
                    onPressed: currentUrl.isEmpty
                        ? null
                        : () => fav.toggleFavorite(currentUrl),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled
        ? ScpReaderTheme.accent
        : ScpReaderTheme.accent.withValues(alpha: 0.35);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
