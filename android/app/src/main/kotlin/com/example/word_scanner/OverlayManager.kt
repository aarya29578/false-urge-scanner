package com.example.word_scanner

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView

class OverlayManager(private val context: Context) {
    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var warningView: View? = null
    private var detailsView: View? = null

    @SuppressLint("ClickableViewAccessibility")
    fun showWarningCard(data: Map<String, Any?>) {
        if (warningView != null) {
            return
        }

        val inflater = LayoutInflater.from(context)
        val view = inflater.inflate(R.layout.overlay_warning, null)
        val params = createLayoutParams()

        val title = data["summary"] as? String ?: "Potentially suspicious\ncontent detected"
        val summaryView = view.findViewById<TextView>(R.id.warningSummary)
        summaryView.text = title

        view.findViewById<View>(R.id.closeButton).setOnClickListener {
            dismissWarning()
        }

        view.findViewById<View>(R.id.viewDetailsButton).setOnClickListener {
            showDetailsCard(data)
            dismissWarning()
        }

        view.setOnTouchListener { _, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    view.tag = event.rawX to event.rawY
                }
                MotionEvent.ACTION_MOVE -> {
                    val tag = view.tag as? Pair<Float, Float> ?: return@setOnTouchListener false
                    val dx = (event.rawX - tag.first)
                    val dy = (event.rawY - tag.second)
                    params.x += dx.toInt()
                    params.y += dy.toInt()
                    windowManager.updateViewLayout(view, params)
                    view.tag = event.rawX to event.rawY
                }
            }
            false
        }

        warningView = view
        windowManager.addView(view, params)
    }

    fun dismissWarning() {
        warningView?.let {
            windowManager.removeView(it)
        }
        warningView = null
    }

    fun dismissDetails() {
        detailsView?.let {
            windowManager.removeView(it)
        }
        detailsView = null
    }

    fun dismissAll() {
        dismissWarning()
        dismissDetails()
    }

    private fun showDetailsCard(data: Map<String, Any?>) {
        if (detailsView != null) {
            return
        }

        val inflater = LayoutInflater.from(context)
        val view = inflater.inflate(R.layout.overlay_details, null)
        val params = createLayoutParams()

        val title = data["title"] as? String ?: "Protection Alert"
        val summary = data["summary"] as? String ?: "Potentially suspicious"
        val confidence = data["confidence"] as? Number ?: 78
        val indicators = (data["indicators"] as? List<*>)?.mapNotNull { it as? String } ?: listOf(
            "Example indicator detected",
            "Example warning signal",
            "Verification required"
        )

        view.findViewById<TextView>(R.id.detailsTitle).text = title
        view.findViewById<TextView>(R.id.detailsSummary).text = summary
        view.findViewById<TextView>(R.id.detailsConfidenceValue).text = "${confidence} %"

        val indicatorList = view.findViewById<TextView>(R.id.indicatorItems)
        indicatorList.text = indicators.joinToString(separator = "\n• ", prefix = "• ")

        view.findViewById<View>(R.id.detailsCloseButton).setOnClickListener {
            dismissDetails()
        }

        detailsView = view
        windowManager.addView(view, params)
    }

    private fun createLayoutParams(): WindowManager.LayoutParams {
        return WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 24
            y = 120
        }
    }
}
