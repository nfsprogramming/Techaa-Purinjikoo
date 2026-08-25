package com.nfsprogramming.techaapurinjikoo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import java.util.Calendar

class TechaaAppWidgetProvider : AppWidgetProvider() {

    private val dailyBites = listOf(
        Pair(
            "Vibe Coding with Cursor & v0: The 2026 Developer Superpower",
            "💡 AI handles repetitive typing; you focus on system architecture & user value!"
        ),
        Pair(
            "How WhatsApp handles 2 Billion users with 50 Engineers?",
            "💡 Erlang actor concurrency + lightweight architecture beats hiring 1000 developers!"
        ),
        Pair(
            "Why Git was built in just 10 Days by Linus Torvalds?",
            "💡 Great developer tools are born out of extreme developer frustration!"
        ),
        Pair(
            "Undersea Fiber Cables: How reels cross the Pacific Ocean",
            "💡 99% of global internet traffic travels through undersea optical fiber!"
        ),
        Pair(
            "Why AI Hallucinations happen & how to prevent fake APIs",
            "💡 Never trust AI code blindly without running compiler and test checks!"
        ),
        Pair(
            "CTC 6 LPA ≠ In-Hand ₹50,000 in your bank account!",
            "💡 Basic Pay (40%) + EPF (12%) + TDS Tax deductions poga in-hand ₹42k dhaan varum!"
        ),
        Pair(
            "Database Indexing: 100x Query Speedup",
            "💡 B-Tree indexes turn 4-second full table scans into 2ms instant lookups!"
        )
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.techaa_app_widget)

        // Select daily bite based on day of year
        val dayOfYear = Calendar.getInstance().get(Calendar.DAY_OF_YEAR)
        val bite = dailyBites[dayOfYear % dailyBites.size]

        views.setTextViewText(R.id.widget_title, bite.first)
        views.setTextViewText(R.id.widget_desc, bite.second)

        // Launch app on tap
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
