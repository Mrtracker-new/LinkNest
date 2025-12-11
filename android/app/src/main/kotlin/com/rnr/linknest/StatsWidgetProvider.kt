package com.rnr.linknest

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.app.PendingIntent

class StatsWidgetProvider : AppWidgetProvider() {
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Called when the first widget is added
    }

    override fun onDisabled(context: Context) {
        // Called when the last widget is removed
    }

    companion object {
        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.stats_widget)

            // Get statistics from SharedPreferences
            // home_widget plugin uses "HomeWidgetPreferences", NOT "FlutterSharedPreferences"
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            
            // Debug: Log all keys in SharedPreferences
            android.util.Log.d("StatsWidget", "=== Reading from HomeWidgetPreferences ===")
            android.util.Log.d("StatsWidget", "All keys: ${prefs.all.keys}")
            
            val totalItems = prefs.getInt("widget_total_items", 0)
            val linksCount = prefs.getInt("widget_links_count", 0)
            val documentsCount = prefs.getInt("widget_documents_count", 0)
            val notesCount = prefs.getInt("widget_notes_count", 0)
            val lastUpdated = prefs.getString("widget_last_updated", "Never")

            // Debug: Log what we read
            android.util.Log.d("StatsWidget", "Read values: Total=$totalItems, Links=$linksCount, Docs=$documentsCount, Notes=$notesCount")
            android.util.Log.d("StatsWidget", "Last updated: $lastUpdated")

            // Update the views
            views.setTextViewText(R.id.total_items_count, totalItems.toString())
            views.setTextViewText(R.id.links_count, linksCount.toString())
            views.setTextViewText(R.id.documents_count, documentsCount.toString())
            views.setTextViewText(R.id.notes_count, notesCount.toString())
            views.setTextViewText(R.id.last_updated, "Updated: $lastUpdated")

            // Set up click handler to open the app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.stats_grid, pendingIntent)
            views.setOnClickPendingIntent(R.id.total_items_card, pendingIntent)

            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        // Method to trigger widget update from Flutter
        fun updateWidget(context: Context) {
            val intent = Intent(context, StatsWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            val ids = AppWidgetManager.getInstance(context)
                .getAppWidgetIds(android.content.ComponentName(context, StatsWidgetProvider::class.java))
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            context.sendBroadcast(intent)
        }
    }
}
