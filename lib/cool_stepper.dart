library cool_stepper;

export 'package:cool_stepper/src/models/cool_step.dart';
export 'package:cool_stepper/src/models/cool_stepper_config.dart';

import 'package:cool_stepper/src/models/cool_step.dart';
import 'package:cool_stepper/src/models/cool_stepper_config.dart';
import 'package:cool_stepper/src/widgets/cool_stepper_view.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// CoolStepper
class CoolStepper extends StatefulWidget {
  /// The steps of the stepper whose titles, subtitles, content always get shown.
  ///
  /// The length of [steps] must not change.
  final List<CoolStep> steps;

  /// Actions to take when the final stepper is passed
  final VoidCallback onCompleted;

  /// Padding for the content inside the stepper
  final EdgeInsetsGeometry contentPadding;

  /// CoolStepper config
  final CoolStepperConfig config;

  /// This determines if or not a snackbar displays your error message if validation fails
  ///
  /// default is false
  final bool showErrorSnackbar;

  const CoolStepper({
    Key? key,
    required this.steps,
    required this.onCompleted,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20.0),
    required this.config,
    this.showErrorSnackbar = false,
  }) : super(key: key);

  @override
  _CoolStepperState createState() => _CoolStepperState();
}

class _CoolStepperState extends State<CoolStepper> {
  PageController _controller = PageController();

  int currentStep = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  switchToPage(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  onStepNext() {
    String? validation = widget.steps[currentStep].validation();
    if (validation == null) {
      if (!_isLast(currentStep)) {
        setState(() {
          currentStep++;
        });
        FocusScope.of(context).unfocus();
        switchToPage(currentStep);
      } else {
        widget.onCompleted();
      }
    } else {
      // Show Error Snakbar
      // if (widget.showErrorSnackbar) {
      //   final snackBar = SnackBar(content: Text(validation ?? "Error!"));
      //   Scaffold.of(context).showSnackBar(snackBar);
      // }
    }
  }

  onStepBack() {
    if (!_isFirst(currentStep)) {
      setState(() {
        currentStep--;
      });
      switchToPage(currentStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Expanded(
      child: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: widget.steps.map((step) {
          return CoolStepperView(
            step: step,
            contentPadding: widget.contentPadding,
            config: widget.config,
          );
        }).toList(),
      ),
    );

    // final counter = Text(
    //   "${widget.config.stepText ?? 'STEP'} ${currentStep + 1} ${widget.config.ofText ?? 'OF'} ${widget.steps.length}",
    //   style: TextStyle(
    //     fontWeight: FontWeight.bold,
    //   ),
    // );

    final counter = SmoothPageIndicator(
      controller: _controller,
      count: widget.steps.length,
      effect: ExpandingDotsEffect(
        dotColor: widget.config.dotColor ?? Colors.grey,
        dotWidth: widget.config.dotWidth ?? 8.0,
        dotHeight: widget.config.dotHeight ?? 8.0,
        activeDotColor: widget.config.activeDotColor ?? Colors.black,
      ),
      onDotClicked: (index) {},
    );

    Widget? getNextBtn() {
      Widget? nextLabel;
      if (_isLast(currentStep)) {
        nextLabel = widget.config.finalBtn ??
            ElevatedButton(
              child: Text('Finish'),
              onPressed: onStepNext,
            );
      } else {
        if (widget.config.nextTextList != null) {
          // nextLabel = widget.config.nextTextList[currentStep];
        } else {
          nextLabel = widget.config.nextBtn ??
              ElevatedButton(
                child: Text('Next'),
                onPressed: onStepNext,
              );
        }
      }
      return nextLabel;
    }

    Widget? getPrevBtn() {
      Widget? backLabel;
      if (_isFirst(currentStep)) {
        backLabel = TextButton(
          child: Text('Back'),
          onPressed: onStepBack,
        );
      } else {
        if (widget.config.backTextList != null) {
          // backLabel = widget.config.backTextList[currentStep - 1];
        } else {
          backLabel = widget.config.backBtn ??
              TextButton(
                child: Text('Back'),
                onPressed: onStepBack,
              );
        }
      }
      return backLabel;
    }

    final buttons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        counter,
        Expanded(child: SizedBox()),
        _isFirst(currentStep) ? Container() : getPrevBtn()!,
        SizedBox(width: widget.config.buttonGutter),
        getNextBtn()!,
      ],
    );

    return Container(
      child: Column(
        children: [content, buttons],
      ),
    );
  }
}
