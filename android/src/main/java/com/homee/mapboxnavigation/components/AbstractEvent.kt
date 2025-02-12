package com.homee.mapboxnavigation.components

import android.util.Log
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event
import com.facebook.react.uimanager.events.RCTEventEmitter

class AbstractEvent(
    viewId: Int,
    private val mEventName: String,
    private val mCanCoalesce: Boolean,
    private val mEvent: WritableMap?
) : Event<AbstractEvent>(viewId) {
    override fun getEventName(): String {
        return mEventName
    }

    override fun dispatch(rctEventEmitter: RCTEventEmitter) {
        Log.d("MapboxNavigationViewportUpdate", "Dispatching event: ${viewTag} - ${mEventName}")
        rctEventEmitter.receiveEvent(viewTag, mEventName, mEvent)
    }

    override fun canCoalesce(): Boolean {
        return mCanCoalesce
    }
}