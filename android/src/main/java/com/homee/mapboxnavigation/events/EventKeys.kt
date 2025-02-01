package com.homee.mapboxnavigation.events

object EventTypes {
    // map event types
    const val MAP_ON_READY = "ready"
    const val MAP_ON_LOCATION_CHANGE = "locationchange"
    const val MAP_ON_ERROR = "error"
    const val MAP_ON_CANCEL_NAVIGATION = "cancelnavigation"
    const val MAP_ON_ARRIVE = "arrive"
    const val MAP_ON_ROUTE_PROGRESS_CHANGE = "routeProgressChange"
}

enum class EventKeys(val value: String) {
    // map events
    MAP_ON_READY("ready"),
    MAP_ON_LOCATION_CHANGE("locationchange"),
    MAP_ON_ERROR("error"),
    MAP_ON_CANCEL_NAVIGATION("cancelnavigation"),
    MAP_ON_ARRIVE("arrive"),
    MAP_ON_ROUTE_PROGRESS_CHANGE("routeProgressChange"),
}

fun eventMapOf(vararg values: Pair<EventKeys, String>): Map<String, String> {
    val mapped = values.map { (k,v) -> Pair(k.value, v) }

    return mapOf(
        *mapped.toTypedArray()
    )
}