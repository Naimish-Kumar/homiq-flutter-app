import 'package:firebase_auth/firebase_auth.dart';
import 'package:homiq/app/register_cubits.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/ui/screens/chat/helpers/registerar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase before app initialization
  try {
    await Firebase.initializeApp();
    // Configure Firebase Auth settings
    if (Platform.isAndroid) {
      await FirebaseAuth.instance.setSettings(
        
      );
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  await initApp();
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});
  @override
  EntryPointState createState() => EntryPointState();
}

class EntryPointState extends State<EntryPoint> {
  @override
  void initState() {
    super.initState();
    ChatMessageHandler.handle();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [...RegisterCubits().register()],
      child: Builder(
        builder: (BuildContext context) {
          return const App();
        },
      ),
    );
  }
}
