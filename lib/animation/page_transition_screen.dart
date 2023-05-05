import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class SlideTopRoute<T> extends MaterialPageRoute<T> {
  SlideTopRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0,1),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}
class SlideTopRightRoute<T> extends MaterialPageRoute<T> {
  SlideTopRightRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1,-1),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}
class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class LiquidTransitionPage extends StatefulWidget {
  final Widget child;
  final double fullTransitionValue;
  final bool enableLoop;

  LiquidTransitionPage({
    required this.child,
    this.fullTransitionValue = 400,
    this.enableLoop = true,
  });

  @override
  State<LiquidTransitionPage> createState() => _LiquidTransitionPageState();
}

class _LiquidTransitionPageState extends State<LiquidTransitionPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: LiquidSwipe(
        pages: [widget.child],
        fullTransitionValue: widget.fullTransitionValue,
        enableLoop: widget.enableLoop,
        slideIconWidget: const Icon(Icons.arrow_back_ios),
        positionSlideIcon: 0.8,
      ),
    );
  }
}
