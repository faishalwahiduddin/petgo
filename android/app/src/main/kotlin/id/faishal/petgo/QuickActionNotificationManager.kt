package id.faishal.petgo

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat

object QuickActionNotificationManager {
    const val CHANNEL_ID = "quick_actions_bar"
    const val NOTIFICATION_ID = 9001
    const val EXTRA_QUICK_ROUTE = "quick_action_route"
    private const val PREFS_NAME = "quick_notif_prefs"
    private const val KEY_ENABLED = "quick_notif_enabled"

    private val btnIds = intArrayOf(R.id.qa_btn_0, R.id.qa_btn_1, R.id.qa_btn_2, R.id.qa_btn_3)
    private val iconIds = intArrayOf(R.id.qa_icon_0, R.id.qa_icon_1, R.id.qa_icon_2, R.id.qa_icon_3)
    private val labelIds = intArrayOf(R.id.qa_label_0, R.id.qa_label_1, R.id.qa_label_2, R.id.qa_label_3)

    fun isEnabled(context: Context): Boolean {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_ENABLED, false)
    }

    private fun setEnabled(context: Context, enabled: Boolean) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_ENABLED, enabled)
            .apply()
    }

    fun show(
        context: Context,
        actions: List<Map<String, String>>,
        accentColor: Int,
        ongoing: Boolean,
    ): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS,
            ) == PackageManager.PERMISSION_GRANTED
            if (!granted) {
                setEnabled(context, false)
                return false
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Quick Actions Bar",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Persistent quick-action shortcuts in the notification shade"
                setShowBadge(false)
            }
            nm.createNotificationChannel(channel)
        }

        val views = RemoteViews(context.packageName, R.layout.notification_quick_actions)
        for (i in 0 until minOf(4, actions.size)) {
            val item = actions[i]
            val label = item["label"] ?: ""
            val route = item["route"] ?: "/"
            val iconName = item["iconRes"] ?: "ic_qa_home"
            val iconResId = context.resources.getIdentifier(iconName, "drawable", context.packageName)

            views.setTextViewText(labelIds[i], label)
            if (iconResId != 0) {
                views.setImageViewResource(iconIds[i], iconResId)
            }
            views.setInt(iconIds[i], "setColorFilter", accentColor)

            val launchIntent = Intent(context, MainActivity::class.java).apply {
                action = "${context.packageName}.QUICK_ACTION_$i"
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra(EXTRA_QUICK_ROUTE, route)
            }
            val pi = PendingIntent.getActivity(
                context,
                9100 + i,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(btnIds[i], pi)
        }

        val dismissIntent = Intent(context, QuickActionDismissReceiver::class.java)
        val dismissPi = PendingIntent.getBroadcast(
            context,
            9200,
            dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.qa_close, dismissPi)

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(views)
            .setCustomBigContentView(views)
            .setOngoing(ongoing)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification)
        setEnabled(context, true)
        return true
    }

    fun hide(context: Context) {
        NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
        setEnabled(context, false)
    }
}
