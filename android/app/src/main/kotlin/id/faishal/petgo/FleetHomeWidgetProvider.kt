package id.faishal.petgo

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class FleetHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.fleet_home_widget).apply {
                val title = widgetData.getString("widget_title", "PetGo") ?: "PetGo"
                val subtitle = widgetData.getString("widget_subtitle", "Pet profiles & care schedules") ?: "Pet profiles & care schedules"
                val badge = widgetData.getString("widget_badge", "PET") ?: "PET"
                val meta = widgetData.getString("widget_meta", "") ?: ""
                val progress = widgetData.getInt("widget_progress", -1)

                setTextViewText(R.id.hw_title, title)
                setTextViewText(R.id.hw_subtitle, subtitle)
                setTextViewText(R.id.hw_badge, badge)

                if (meta.isNotEmpty()) {
                    setViewVisibility(R.id.hw_meta, View.VISIBLE)
                    setTextViewText(R.id.hw_meta, meta)
                } else {
                    setViewVisibility(R.id.hw_meta, View.GONE)
                }

                if (true && progress in 0..100) {
                    setViewVisibility(R.id.hw_progress, View.VISIBLE)
                    setProgressBar(R.id.hw_progress, 100, progress, false)
                } else {
                    setViewVisibility(R.id.hw_progress, View.GONE)
                }

                setOnClickPendingIntent(
                    R.id.hw_root,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("faishal-petgo://open/"),
                    ),
                )
            setTextViewText(R.id.hw_btn_0, "Care")
            setOnClickPendingIntent(
                R.id.hw_btn_0,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("faishal-petgo://open/care"),
                ),
            )
            setTextViewText(R.id.hw_btn_1, "Daily")
            setOnClickPendingIntent(
                R.id.hw_btn_1,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("faishal-petgo://open/daily"),
                ),
            )
            setTextViewText(R.id.hw_btn_2, "Docs")
            setOnClickPendingIntent(
                R.id.hw_btn_2,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("faishal-petgo://open/docs"),
                ),
            )
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
