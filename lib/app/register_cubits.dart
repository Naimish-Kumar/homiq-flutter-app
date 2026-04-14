import 'package:homiq/core/network/api_client.dart';
import 'package:homiq/data/cubits/system/app_theme_cubit.dart';
import 'package:homiq/data/cubits/system/delete_account_cubit.dart';
import 'package:homiq/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:homiq/data/cubits/system/get_api_keys_cubit.dart';
import 'package:homiq/data/cubits/system/language_cubit.dart';
import 'package:homiq/data/cubits/system/notification_cubit.dart';
import 'package:homiq/data/cubits/system/user_details.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:homiq/features/auth/presentation/blocs/auth_state_cubit.dart';
import 'package:homiq/features/home/presentation/blocs/fetch_home_page_data_cubit.dart';
import 'package:homiq/features/profile/presentation/blocs/profile_setting_cubit.dart';
import 'package:homiq/features/studio/data/repositories_impl/design_repository_impl.dart';
import 'package:homiq/features/studio/presentation/blocs/design_generation_cubit.dart';
import 'package:homiq/features/auth/presentation/blocs/get_user_data_cubit.dart';
import 'package:homiq/features/studio/presentation/blocs/fetch_my_designs_cubit.dart';
import 'package:homiq/features/studio/presentation/blocs/fetch_styles_cubit.dart';
import 'package:nested/nested.dart';

class RegisterCubits {
  List<SingleChildWidget> register() {
    final apiClient = ApiClient();
    
    // Repositories
    final designRepository = DesignRepositoryImpl(apiClient: apiClient);

    return [
      BlocProvider(create: (context) => GetUserDataCubit()),
      BlocProvider(create: (context) => AuthCubit()),
      BlocProvider(create: (context) => AuthenticationCubit()),
      BlocProvider(create: (context) => UserDetailsCubit()),
      BlocProvider(create: (context) => ProfileSettingCubit()),
      BlocProvider(create: (context) => DeleteAccountCubit()),
      BlocProvider(create: (context) => NotificationCubit()),
      BlocProvider(create: (context) => AppThemeCubit()),
      BlocProvider(create: (context) => LanguageCubit()),
      BlocProvider(create: (context) => FetchSystemSettingsCubit()),
      BlocProvider(create: (context) => GetApiKeysCubit()),
      BlocProvider(create: (context) => FetchStylesCubit(designRepository)),
      BlocProvider(create: (context) => DesignGenerationCubit(designRepository)),
      BlocProvider(create: (context) => FetchMyDesignsCubit(designRepository)),
      BlocProvider(create: (context) => FetchHomePageDataCubit()),
    ];
  }
}
