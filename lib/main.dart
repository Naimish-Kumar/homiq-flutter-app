import 'package:homiq/app/register_cubits.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/ui/screens/chat/helpers/registerar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
