import 'package:dialog_flowtter/dialog_flowtter.dart';

class DialogflowService {
  late DialogFlowtter dialogFlowtter;

  // Initialize Dialogflow with API Key
  Future<void> init() async {
    try {
      dialogFlowtter = await DialogFlowtter.fromFile(path: "assets/dialogflow_key.json");
      print("✅ Dialogflow Initialized Successfully");
    } catch (e) {
      print("❌ Error Initializing Dialogflow: $e");
    }
  }

  // Send Message to Dialogflow and Get Response
  Future<String> sendMessage(String message) async {
    try {
      DetectIntentResponse response = await dialogFlowtter.detectIntent(
        queryInput: QueryInput(text: TextInput(text: message)),
      );

      return response.text ?? "I didn't understand that.";
    } catch (e) {
      return "❌ Error: $e";
    }
  }
}
