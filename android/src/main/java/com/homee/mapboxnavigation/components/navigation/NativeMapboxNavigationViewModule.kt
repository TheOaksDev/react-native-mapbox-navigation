package com.homee.mapboxnavigation.components.navigation

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeMap
import com.homee.mapboxnavigation.NativeMapboxNavigationViewModuleSpec
import com.homee.mapboxnavigation.utils.ViewRefTag
import com.homee.mapboxnavigation.utils.ViewTagResolver

class NativeMapboxNavigationViewModule(
        context: ReactApplicationContext,
        val viewTagResolver: ViewTagResolver
) : NativeMapboxNavigationViewModuleSpec(context) {
    private fun withMapViewOnUIThread(
            viewRef: ViewRefTag?,
            reject: Promise,
            fn: (MapboxNavigationView) -> Unit
    ) {
        if (viewRef == null) {
            reject.reject(Exception("viewRef is null"))
        } else {
            viewTagResolver.withViewResolved(viewRef.toInt(), reject, fn)
        }
    }

    private fun createCommandResponse(promise: Promise): CommandResponse =
            object : CommandResponse {
                override fun success(builder: (WritableMap) -> Unit) {
                    val payload: WritableMap = WritableNativeMap()
                    builder(payload)

                    promise.resolve(payload)
                }

                override fun error(message: String) {
                    promise.reject(Exception(message))
                }
            }

    override fun stopNavigation(viewRef: ViewRefTag?, promise: Promise) {
        withMapViewOnUIThread(viewRef, promise) {
            it.stopNavigation(createCommandResponse(promise))
        }
    }

    override fun startNavigation(viewRef: ViewRefTag?, promise: Promise) {
        withMapViewOnUIThread(viewRef, promise) {
            it.startNavigation(createCommandResponse(promise))
        }
    }

    override fun startFreeDrive(viewRef: ViewRefTag?, promise: Promise) {
        withMapViewOnUIThread(viewRef, promise) {
            it.startFreeDrive(createCommandResponse(promise))
        }
    }

    override fun stopFreeDrive(viewRef: ViewRefTag?, promise: Promise) {
        withMapViewOnUIThread(viewRef, promise) { it.stopFreeDrive(createCommandResponse(promise)) }
    }

    override fun showRoutePreview(viewRef: ViewRefTag?, coordinates: ReadableArray, promise: Promise) {
        withMapViewOnUIThread(viewRef, promise) {
            it.showRoutePreview(coordinates, createCommandResponse(promise))
        }
    }

    override fun hideRoutePreview(viewRef: ViewRefTag?, promise: Promise) {
        withMapViewOnUIThread(viewRef, promise) {
            it.hideRoutePreview(createCommandResponse(promise))
        }
    }

    override fun setCameraZoom(viewRef: ViewRefTag?, zoomLevel: Double, promise: Promise) {
        withMapViewOnUIThread(viewRef, promise) {
            it.setCameraZoom(zoomLevel, createCommandResponse(promise))
        }
    }

    override fun setVisibleArea(viewRef: ViewRefTag?, visibleArea: ReadableMap, promise: Promise) {
        withMapViewOnUIThread(viewRef, promise) {
            val width = visibleArea.getInt("width")
            val height = visibleArea.getInt("height")
            val top = visibleArea.getInt("top")
            val left = visibleArea.getInt("left")
            val bottom = visibleArea.getInt("bottom")
            val right = visibleArea.getInt("right")
            it.setVisibleArea(top, left, bottom, right, width, height, createCommandResponse(promise))
        }
    }

    override fun getCameraZoom(viewRef: ViewRefTag?, promise: Promise) {
        withMapViewOnUIThread(viewRef, promise) {
            it.getCameraZoom(createCommandResponse(promise))
        }
    }

    companion object {
        const val NAME = "MapboxNavigationViewModule"
    }
}
