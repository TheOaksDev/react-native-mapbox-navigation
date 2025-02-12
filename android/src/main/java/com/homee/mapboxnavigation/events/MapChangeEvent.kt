package com.homee.mapboxnavigation.events

import android.view.View
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap

open class MapChangeEvent(
    view: View,
    private val mEventType: String,
    private val mPayload: WritableMap = Arguments.createMap()
) : AbstractEvent(view, mEventType) {
    override val key: String
        get() = mEventType

    override val payload: WritableMap
        get() {
            val payloadClone = Arguments.createMap()
            payloadClone.merge(mPayload)
            return payloadClone
        }

    override fun canCoalesce(): Boolean {
        // Make sure EventDispatcher never merges EventKeys.MAP_ONCHANGE events.
        // This event name is used to emit events with different
        // com.rnmapbox.rnmbx.events.constants.EventTypes which are dispatched separately on
        // the JS side
        return false
    }
}

public class CameraChangeEvent(view: View, eventType: String, payload: WritableMap) :
        MapChangeEvent(view, eventType, payload) {
    override fun canCoalesce(): Boolean {
        return true
    }
}
