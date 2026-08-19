import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_event.dart';
import '../bloc/forget_password_state.dart';
import '../widgets/auth_app_bar.dart';
import 'forget_password_view.dart';
import 'otp_verification_view.dart';
import 'reset_password_view.dart';

class ForgetPasswordFlowView extends StatefulWidget {
  const ForgetPasswordFlowView({super.key});

  @override
  State<ForgetPasswordFlowView> createState() => _ForgetPasswordFlowViewState();
}

class _ForgetPasswordFlowViewState extends State<ForgetPasswordFlowView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(ForgetPasswordStep step) {
    _pageController.animateToPage(
      step.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Back walks the flow one page at a time and only leaves the route from the
  /// first page.
  void _onBack(ForgetPasswordStep step) {
    if (step == ForgetPasswordStep.email) {
      context.pop();
    } else {
      context.read<ForgetPasswordBloc>().add(BackToPreviousStepEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ForgetPasswordBloc,
      ForgetPasswordState,
      ForgetPasswordStep
    >(
      selector: (state) => state.step,
      builder: (context, step) => PopScope(
        canPop: step == ForgetPasswordStep.email,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _onBack(step);
        },
        child: Scaffold(
          appBar: AuthAppBar(
            title: AppStrings.password,
            onBack: () => _onBack(step),
          ),
          body: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
            listenWhen: (previous, current) => previous.step != current.step,
            listener: (context, state) => _goToStep(state.step),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ForgetPasswordView(),
                OtpVerificationView(),
                ResetPasswordView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
