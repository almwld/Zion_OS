package com.zion.os;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.EventChannel;

// استيراد Termux components
import com.zion.os.termux.TerminalSession;
import com.zion.os.termux.TerminalView;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.zion.os/termux";
    private TerminalSession termuxSession;
    
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "initTermux":
                        try {
                            // تهيئة Termux الحقيقي
                            termuxSession = new TerminalSession(80, 24);
                            result.success(true);
                        } catch (Exception e) {
                            result.error("INIT_ERROR", e.getMessage(), null);
                        }
                        break;
                    case "executeCommand":
                        String command = call.argument("command");
                        if (termuxSession != null) {
                            termuxSession.write(command + "\n");
                        }
                        result.success(null);
                        break;
                    default:
                        result.notImplemented();
                }
            });
    }
}
