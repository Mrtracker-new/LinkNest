package com.rnr.linknest

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.app.PendingIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class QuickAddWidgetProvider : AppWidgetProvider() {
    
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
            val views = RemoteViews(context.packageName, R.layout.quick_add_widget)

            // Set up click handlers for each button
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE

            // Add Link button
            val addLinkIntent = Intent(context, MainActivity::class.java).apply {
                data = Uri.parse("linknest://add_link")
                action = Intent.ACTION_VIEW
            }
            val addLinkPendingIntent = PendingIntent.getActivity(context, 0, addLinkIntent, flags)
            views.setOnClickPendingIntent(R.id.add_link_button, addLinkPendingIntent)

            // Add Document button
            val addDocIntent = Intent(context, MainActivity::class.java).apply {
                data = Uri.parse("linknest://add_document")
                action = Intent.ACTION_VIEW
            }
            val addDocPendingIntent = PendingIntent.getActivity(context, 1, addDocIntent, flags)
            views.setOnClickPendingIntent(R.id.add_document_button, addDocPendingIntent)

            // Add Note button
            val addNoteIntent = Intent(context, MainActivity::class.java).apply {
                data = Uri.parse("linknest://add_note")
                action = Intent.ACTION_VIEW
            }
            val addNotePendingIntent = PendingIntent.getActivity(context, 2, addNoteIntent, flags)
            views.setOnClickPendingIntent(R.id.add_note_button, addNotePendingIntent)

            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
