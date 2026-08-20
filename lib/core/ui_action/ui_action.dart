sealed class UiAction {
  const UiAction();
}

enum SnackBarType { success, error }

class NavigateAction extends UiAction {
  final String routeName;
  final bool replace;

  const NavigateAction(this.routeName, {this.replace = false});
}

class ShowSnackBarAction extends UiAction {
  final SnackBarType type;
  final String message;

  const ShowSnackBarAction.success(this.message) : type = SnackBarType.success;
  const ShowSnackBarAction.error(this.message) : type = SnackBarType.error;
}

class DialogAction extends UiAction {
  final String title;
  final String message;

  const DialogAction({required this.title, required this.message});
}
