package com.homee.mapboxnavigation.components.navigation

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import android.view.View
import com.facebook.react.bridge.Dynamic
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.uimanager.LayoutShadowNode
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.MapboxNavigationViewManagerDelegate
import com.facebook.react.viewmanagers.MapboxNavigationViewManagerInterface
import com.homee.mapboxnavigation.components.AbstractEventEmitter
import com.homee.mapboxnavigation.events.EventKeys
import com.homee.mapboxnavigation.events.eventMapOf
import com.homee.mapboxnavigation.utils.ViewTagResolver
import com.mapbox.common.MapboxOptions
import com.mapbox.geojson.Point
import com.mapbox.maps.TileStoreUsageMode
import com.mapbox.maps.mapsOptions
import javax.annotation.Nonnull

interface CommandResponse {
    fun success(builder: (WritableMap) -> Unit)
    fun error(message: String)
}

class MapboxNavigationViewManager(
        var mCallerContext: ReactApplicationContext,
        val viewTagResolver: ViewTagResolver
) :
        AbstractEventEmitter<MapboxNavigationView>(mCallerContext),
        MapboxNavigationViewManagerInterface<MapboxNavigationView> {
    private var accessToken: String? = null
    private val mViews: MutableMap<Int, MapboxNavigationView>
    private val mDelegate: ViewManagerDelegate<MapboxNavigationView>


    init {
        val app =
                mCallerContext.packageManager.getApplicationInfo(
                        mCallerContext.packageName,
                        PackageManager.GET_META_DATA
        )
        val bundle = app.metaData
        val accessToken = bundle.getString("MAPBOX_ACCESS_TOKEN")
        this.accessToken = accessToken
        MapboxOptions.accessToken = this.accessToken.toString()
        MapboxOptions.mapsOptions.tileStoreUsageMode = TileStoreUsageMode.READ_ONLY
        mDelegate =
                MapboxNavigationViewManagerDelegate<
                        MapboxNavigationView, MapboxNavigationViewManager>(this)
    }

    override fun getDelegate(): ViewManagerDelegate<MapboxNavigationView>? {
        return mDelegate
    }

    override fun getName(): String {
        return REACT_CLASS
    }

    override fun createShadowNodeInstance(): LayoutShadowNode {
        return MapNavigationShadowNode(this)
    }

    override fun getShadowNodeClass(): Class<out LayoutShadowNode> {
        return MapNavigationShadowNode::class.java
    }

    override fun onAfterUpdateTransaction(mapView: MapboxNavigationView) {
        super.onAfterUpdateTransaction(mapView)
        val first = !mapView.isInitialized
        mapView.applyAllChanges()
        if (first) {
            mViews[mapView.id] = mapView
            mapView.init()
        }
    }

    override fun addView(mapView: MapboxNavigationView, childView: View, childPosition: Int) {
        //mapView.onCreate()
    }

    override fun getChildCount(mapView: MapboxNavigationView): Int {
        return 0
    }

    override fun getChildAt(mapView: MapboxNavigationView, index: Int): View? {
        return null
    }

    override fun removeViewAt(mapView: MapboxNavigationView, index: Int) {
        mapView.onDestroy()
    }

    fun getMapViewContext(themedReactContext: ThemedReactContext): Context {
        return activity ?: themedReactContext
    }

    public override fun createViewInstance(
            @Nonnull reactContext: ThemedReactContext
    ): MapboxNavigationView {
        val context = getMapViewContext(reactContext)
        return MapboxNavigationView(context, this, this.accessToken)
    }

    override fun onDropViewInstance(view: MapboxNavigationView) {
        val reactTag = view.id

        viewTagResolver.viewRemoved(reactTag)

        if (mViews.containsKey(reactTag)) {
            mViews.remove(reactTag)
        }
        view.onDropViewInstance()
        super.onDropViewInstance(view)
    }

    fun getByReactTag(reactTag: Int): MapboxNavigationView? {
        return mViews[reactTag]
    }

    fun tagAssigned(reactTag: Int) {
        return viewTagResolver.tagAssigned(reactTag)
    }

    override fun getCommandsMap(): Map<String, Int>? {
        return mapOf("_useCommandName" to 1)
    }

    override fun customEvents(): Map<String, String>? {
        return eventMapOf(
                EventKeys.MAP_ON_READY to "onReady",
                EventKeys.MAP_ON_LOCATION_CHANGE to "onLocationChange",
                EventKeys.MAP_ON_ERROR to "onError",
                EventKeys.MAP_ON_CANCEL_NAVIGATION to "onCancelNavigation",
                EventKeys.MAP_ON_ARRIVE to "onArrive",
                EventKeys.MAP_ON_ROUTE_PROGRESS_CHANGE to "onRouteProgressChange",
        )
    }

    @ReactProp(name = "origin")
    override fun setOrigin(view: MapboxNavigationView, sources: Dynamic) {
        val origin = sources.asMap()
        if (origin != null && origin.hasKey("latitude") && origin.hasKey("longitude")) {
            try {
                val latitude = origin.getDouble("latitude")
                val longitude = origin.getDouble("longitude")
                view.setOrigin(Point.fromLngLat(longitude, latitude))
            } catch (e: Exception) {
                Log.e(REACT_CLASS, "Error setting origin: ${e.message}")
            }
        } else {
            // Handle null or incomplete origin
            view.setOrigin(null)
        }
    }

    @ReactProp(name = "destination")
    override fun setDestination(view: MapboxNavigationView, sources: Dynamic) {
        val destination = sources.asMap()
        if (destination != null && destination.hasKey("latitude") && destination.hasKey("longitude")
        ) {
            try {
                val latitude = destination.getDouble("latitude")
                val longitude = destination.getDouble("longitude")
                view.setDestination(Point.fromLngLat(longitude, latitude))
            } catch (e: Exception) {
                Log.e(REACT_CLASS, "Error setting destination: ${e.message}")
            }
        } else {
            // Handle null or incomplete destination
            view.setDestination(null)
        }
    }

    @ReactProp(name = "shouldSimulateRoute")
    override fun setShouldSimulateRoute(view: MapboxNavigationView, shouldSimulateRoute: Dynamic) {
        view.setShouldSimulateRoute(shouldSimulateRoute.asBoolean())
    }

    @ReactProp(name = "showsEndOfRouteFeedback")
    override fun setShowsEndOfRouteFeedback(
            view: MapboxNavigationView,
            showsEndOfRouteFeedback: Dynamic
    ) {
        view.setShowsEndOfRouteFeedback(showsEndOfRouteFeedback.asBoolean())
    }

    @ReactProp(name = "mute")
    override fun setMute(view: MapboxNavigationView, mute: Dynamic) {
        view.setMute(mute.asBoolean())
    }

    @ReactProp(name = "viewStyles")
    override fun setViewStyles(view: MapboxNavigationView, viewStyles: Dynamic) {
        view.setViewStyles(viewStyles.asMap())
    }

    @ReactProp(name = "isCarplayView")
    override fun setIsCarplayView(view: MapboxNavigationView, isCarplayView: Dynamic) {
        view.setIsCarplayView(isCarplayView.asBoolean())
    }

    @ReactProp(name = "freeDrive")
    override fun setFreeDriveEnabled(view: MapboxNavigationView, freeDrive: Dynamic) {
        view.setFreeDriveEnabled(freeDrive.asBoolean())
    }

    @ReactProp(name = "mapStyleURL")
    override fun setMapStyleURL(view: MapboxNavigationView, mapStyleURL: Dynamic) {
        view.setMapStyleURL(mapStyleURL.asString())
    }

    @ReactProp(name = "isDarkMode")
    override fun setIsDarkMode(view: MapboxNavigationView, isDarkMode: Dynamic) {
        view.setIsDarkMode(isDarkMode.asBoolean())
    }

    private class MapNavigationShadowNode(private val mViewManager: MapboxNavigationViewManager) :
        LayoutShadowNode() {
        override fun dispose() {
            super.dispose()
            diposeNativeMapView()
        }

        /**
         * We need this mapview to dispose (calls into nativeMap.destroy) before ReactNative starts tearing down the views in
         * onDropViewInstance.
         */
        private fun diposeNativeMapView() {
            val mapView = mViewManager.getByReactTag(reactTag)
            if (mapView != null) {
                UiThreadUtil.runOnUiThread {
                    try {
                        //mapView.dispose();
                    } catch (ex: Exception) {
                        Log.e(LOG_TAG, " disposeNativeMapView() exception destroying map view", ex)
                    }
                }
            }
        }
    }

    companion object {
        const val LOG_TAG = "MapboxNavigationViewManager"
        const val REACT_CLASS = "MapboxNavigationView"
    }

    init {
        mViews = HashMap()
    }
}
