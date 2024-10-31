part of debug_console;

/// A widget that adds a floating button for debugging purposes.
class DebugConsolePopup extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final bool showButton;

  final DebugConsoleController controller;
  final List<PopupMenuItem<void>> actions;
  final bool expandStackTrace;
  final String? savePath;

  DebugConsolePopup({
    super.key,
    required this.child,
    required this.navigatorKey,
    this.showButton = true,
    DebugConsoleController? controller,
    this.actions = const [],
    this.expandStackTrace = false,
    this.savePath,
  }) : controller = controller ?? DebugConsole.instance;

  @override
  State<DebugConsolePopup> createState() => _DebugConsolePopupState();
}

class _DebugConsolePopupState extends State<DebugConsolePopup> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showButton)
          _DraggableDebugButton(
            onPressed: () => popup(true),
          ),
      ],
    );
  }

  void popup([bool? open]) {
    open ??= !isOpen;
    if (open == isOpen) return;
    if (open) {
      widget.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => WillPopScope(
            onWillPop: () async {
              isOpen = false;
              return true;
            },
            child: Theme(
              data: ThemeData(),
              child: DebugConsole(
                controller: widget.controller,
                actions: widget.actions,
                expandStackTrace: widget.expandStackTrace,
                savePath: widget.savePath,
              ),
            ),
          ),
        ),
      );
    } else {
      widget.navigatorKey.currentState?.pop();
    }
    isOpen = open;
  }
}

class _DraggableDebugButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _DraggableDebugButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<_DraggableDebugButton> createState() => _DraggableDebugButtonState();
}

class _DraggableDebugButtonState extends State<_DraggableDebugButton> {
  Offset buttonPosition = const Offset(15, 15);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: buttonPosition.dx,
      bottom: buttonPosition.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            buttonPosition = Offset(
              (buttonPosition.dx - details.delta.dx)
                  .clamp(0, MediaQuery.of(context).size.width - 56),
              (buttonPosition.dy - details.delta.dy)
                  .clamp(0, MediaQuery.of(context).size.height - 56),
            );
          });
        },
        child: FloatingActionButton(
          child: const Icon(Icons.bug_report),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
