import 'package:flutter/material.dart';
import 'package:neura_browser/widgets/neumorphic_style.dart';

class FloatingNavBar extends StatefulWidget {
  final bool isDark;
  final VoidCallback onGoBack;
  final VoidCallback onGoForward;
  final VoidCallback onGoHome;
  final VoidCallback onGoToUrl;
  final VoidCallback onGoToTabs;
  final TextEditingController urlController;
  final FocusNode urlFocusNode;
  final Function(String) onSubmitted;

  const FloatingNavBar({
    super.key,
    required this.isDark,
    required this.onGoBack,
    required this.onGoForward,
    required this.onGoHome,
    required this.onGoToUrl,
    required this.onGoToTabs,
    required this.urlController,
    required this.urlFocusNode,
    required this.onSubmitted,
  });

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isExpanded ? 120 : 60,
        decoration: neumorphicDecoration(isDark: widget.isDark, radius: 30),
        child: Column(
          children: [
            _buildUrlBar(),
            if (_isExpanded) _buildNavControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlBar() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.urlController,
                focusNode: widget.urlFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Search or enter URL',
                  border: InputBorder.none,
                ),
                onSubmitted: widget.onSubmitted,
                style: TextStyle(
                    color: widget.isDark ? Colors.white : Colors.black),
              ),
            ),
            Icon(
              _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: widget.isDark ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavControls() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(Icons.arrow_back, widget.onGoBack),
          _buildNavButton(Icons.arrow_forward, widget.onGoForward),
          _buildNavButton(Icons.home, widget.onGoHome),
          _buildNavButton(Icons.tab, widget.onGoToTabs),
          _buildNavButton(Icons.refresh, widget.onGoToUrl),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: widget.isDark ? Colors.white : Colors.black),
      onPressed: onPressed,
    );
  }
}
