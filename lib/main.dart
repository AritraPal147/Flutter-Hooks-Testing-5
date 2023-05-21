import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Hooks Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    debugShowCheckedModeBanner: false,
    home: const HomePage(),
  ));
}

const url = 'https://bit.ly/3x7J5Qt';
const imageHeight = 300.0;

/// Normalizes a number -> basically converts a number from
/// a given range, such as 0-300 into a normalized number in the
/// range 0-1.
///
/// [selfRangeMin] is the minimum range of user number
/// [selfRangeMax] is the maximum range of user number
extension Normalize on num {
  num normalized(
    num selfRangeMin,
    num selfRangeMax, [
    num normalizedRangeMin = 0.0,
    num normalizedRangeMax = 1.0,
  ]) =>
      (normalizedRangeMax - normalizedRangeMin) *
          ((this - selfRangeMin) / (selfRangeMax - selfRangeMin)) +
      normalizedRangeMin;
}

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// [opacity] is an AnimationController hook that controls
    /// the opacity of the image on scroll
    final opacity = useAnimationController(
      duration: const Duration(seconds: 1),
      initialValue: 1.0,
      lowerBound: 1.0,
      upperBound: 1.0,
    );

    /// [size] is an AnimationController hook that controls
    /// the size of the image on scroll
    final size = useAnimationController(
      duration: const Duration(seconds: 1),
      initialValue: 1.0,
      upperBound: 1.0,
      lowerBound: 0.0,
    );

    /// [controller] is a ScrollController hook
    final controller = useScrollController();

    /// This function is called only once provided the key
    /// (controller in this case) does not change.
    ///
    /// [newOpacity] stores the maximum among (imageHeight -
    /// current offset of scrollable widget) and zero.
    /// [newOpacity] is then normalized and stored in [normalized]
    /// The normalized value of opacity is then given to the
    /// [opacity] and [size] controllers
    useEffect(() {
      controller.addListener(() {
        final newOpacity = max(imageHeight - controller.offset, 0.0);
        final normalized = newOpacity.normalized(0.0, imageHeight).toDouble();
        opacity.value = normalized;
        size.value = normalized;
      });
      return null;
    }, [controller]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          /// SizeTransition takes care of size changes of image
          SizeTransition(
            sizeFactor: size,
            axis: Axis.vertical,
            axisAlignment: -1.0,
            //// FadeTransition takes care of opacity changes of image
            child: FadeTransition(
              opacity: opacity,
              child: Image.network(
                url,
                height: imageHeight,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                controller: controller,
                itemCount: 100,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      'Person ${index + 1}',
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
