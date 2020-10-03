import 'package:cloudwalk/constants/route_names.dart';
import 'package:cloudwalk/locator.dart';
import 'package:cloudwalk/services/authentication_service.dart';
import 'package:cloudwalk/services/navigation_service.dart';
import 'package:cloudwalk/ui/viewmodels/base_model.dart';

class StartUpViewModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();

  Future handleStartUpLogic() async {
    var hasLoggedInUser = await _authenticationService.isUserLoggedIn();

    if (hasLoggedInUser) {
      _navigationService.clearAllAndNavigateTo(HomeViewRoute);
    } else {
      _navigationService.clearAllAndNavigateTo(LoginViewRoute);
    }
  }

  signOut(){
    _authenticationService.signOut();
  }
}
