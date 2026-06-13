package com.zion.os;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.zion.os/termux";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "initTermux":
                        result.success(true);
                        break;
                    case "executeCommand":
                        String command = call.argument("command");
                        // TODO: تنفيذ الأمر لاحقًا عند دمج Termux كاملاً
                        result.success(null);
                        break;
                    default:
                        result.notImplemented();
                }
            });
    }
}
