package id.faishal.petgo

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var quickChannel: MethodChannel? = null
    private var initialQuickRoute: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        initialQuickRoute = intent?.getStringExtra(QuickActionNotificationManager.EXTRA_QUICK_ROUTE)

        quickChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "id.faishal.fleet/quick_notif",
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialActionRoute" -> {
                        result.success(initialQuickRoute)
                        initialQuickRoute = null
                    }
                    "isEnabled" -> {
                        result.success(QuickActionNotificationManager.isEnabled(this@MainActivity))
                    }
                    "show" -> {
                        @Suppress("UNCHECKED_CAST")
                        val actions = (call.arguments as? Map<String, Any?>)
                            ?.get("actions") as? List<Map<String, String>> ?: emptyList()
                        val accent = ((call.arguments as? Map<String, Any?>)
                            ?.get("accentColor") as? Number)?.toInt() ?: 0xFF0F766E.toInt()
                        val ongoing = (call.arguments as? Map<String, Any?>)
                            ?.get("ongoing") as? Boolean ?: true
                        result.success(
                            QuickActionNotificationManager.show(
                                this@MainActivity,
                                actions,
                                accent,
                                ongoing,
                            ),
                        )
                    }
                    "hide" -> {
                        QuickActionNotificationManager.hide(this@MainActivity)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val route = intent.getStringExtra(QuickActionNotificationManager.EXTRA_QUICK_ROUTE)
        if (!route.isNullOrEmpty()) {
            quickChannel?.invokeMethod("onQuickAction", route)
        }
    }
}
