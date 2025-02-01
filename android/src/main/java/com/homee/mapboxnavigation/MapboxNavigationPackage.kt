package com.homee.mapboxnavigation

import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.JavaScriptModule
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.facebook.react.uimanager.ViewManager
import com.homee.mapboxnavigation.components.navigation.MapboxNavigationViewManager
import com.homee.mapboxnavigation.components.navigation.NativeMapboxNavigationViewModule
import com.homee.mapboxnavigation.utils.ViewTagResolver

class MapboxNavigationPackage : TurboReactPackage() {

    var viewTagResolver: ViewTagResolver? = null
    fun getViewTagResolver(context: ReactApplicationContext, module: String): ViewTagResolver {
        val viewTagResolver = viewTagResolver
        if (viewTagResolver == null) {
            val result = ViewTagResolver(context)
            this.viewTagResolver = result
            return result
        }
        return viewTagResolver
    }

    fun resetViewTagResolver() {
        viewTagResolver = null
    }

    override fun getModule(
            s: String,
            reactApplicationContext: ReactApplicationContext
    ): NativeModule? {
        when (s) {
            NativeMapboxNavigationViewModule.NAME ->
                    return NativeMapboxNavigationViewModule(
                            reactApplicationContext,
                            getViewTagResolver(reactApplicationContext, s)
                    )
        }
        return null
    }

    @Deprecated("")
    fun createJSModules(): List<Class<out JavaScriptModule?>> {
        return emptyList()
    }

    override fun createViewManagers(
            reactApplicationContext: ReactApplicationContext
    ): List<ViewManager<*, *>> {
        val managers: MutableList<ViewManager<*, *>> = ArrayList()

        // components
        managers.add(
                MapboxNavigationViewManager(
                        reactApplicationContext,
                        getViewTagResolver(reactApplicationContext, "MapboxNavigationViewManager")
                )
        )
        return managers
    }

    override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
        resetViewTagResolver()
        return ReactModuleInfoProvider {
            val moduleInfos: MutableMap<String, ReactModuleInfo> = HashMap()
            val isTurboModule = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED
            moduleInfos[NativeMapboxNavigationViewModule.NAME] =
                    ReactModuleInfo(
                            NativeMapboxNavigationViewModule.NAME,
                            NativeMapboxNavigationViewModule.NAME,
                            false, // canOverrideExistingModule
                            false, // needsEagerInit
                            false, // hasConstants
                            false, // isCxxModule
                            isTurboModule // isTurboModule
                    )
            moduleInfos
        }
    }
}
