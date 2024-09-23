package com.homee.mapboxnavigation

import android.annotation.SuppressLint
import android.content.res.Configuration
import android.content.res.Resources
import android.graphics.Color
//import android.location.Location
import android.location.LocationManager
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.ThemedReactContext
import com.mapbox.api.directions.v5.models.DirectionsRoute
import com.mapbox.api.directions.v5.models.RouteOptions
import com.mapbox.bindgen.Expected
import com.mapbox.geojson.Point
import com.mapbox.maps.EdgeInsets
import com.mapbox.maps.MapView
import com.mapbox.maps.MapboxMap
import com.mapbox.maps.Style
import com.mapbox.maps.plugin.LocationPuck2D
import com.mapbox.maps.plugin.animation.camera
import com.mapbox.maps.plugin.locationcomponent.location
import com.mapbox.navigation.base.TimeFormat
import com.mapbox.navigation.base.extensions.applyDefaultNavigationOptions
import com.mapbox.navigation.base.extensions.applyLanguageAndVoiceUnitOptions
import com.mapbox.navigation.base.options.NavigationOptions
//import com.mapbox.navigation.base.route.RouterCallback
import com.mapbox.navigation.base.route.RouterFailure
import com.mapbox.navigation.base.route.RouterOrigin
import com.mapbox.navigation.core.MapboxNavigation
import com.mapbox.navigation.core.MapboxNavigationProvider
import com.mapbox.navigation.core.directions.session.RoutesObserver
import com.mapbox.navigation.core.formatter.MapboxDistanceFormatter
import com.mapbox.navigation.core.replay.MapboxReplayer
//import com.mapbox.navigation.core.replay.ReplayLocationEngine
import com.mapbox.navigation.core.replay.route.ReplayProgressObserver
import com.mapbox.navigation.core.replay.route.ReplayRouteMapper
import com.mapbox.navigation.core.trip.session.LocationMatcherResult
import com.mapbox.navigation.core.trip.session.LocationObserver
import com.mapbox.navigation.core.trip.session.RouteProgressObserver
import com.mapbox.navigation.core.trip.session.VoiceInstructionsObserver
import com.homee.mapboxnavigation.databinding.NavigationViewBinding
import com.mapbox.api.directions.v5.DirectionsCriteria
import com.mapbox.navigation.base.trip.model.RouteLegProgress
import com.mapbox.navigation.base.trip.model.RouteProgress
import com.mapbox.navigation.core.arrival.ArrivalObserver
import com.mapbox.navigation.ui.base.util.MapboxNavigationConsumer

import com.mapbox.navigation.tripdata.maneuver.api.MapboxManeuverApi
import com.mapbox.navigation.ui.components.maneuver.view.MapboxManeuverView

import com.mapbox.navigation.ui.maps.camera.NavigationCamera
import com.mapbox.navigation.ui.maps.camera.data.MapboxNavigationViewportDataSource
import com.mapbox.navigation.ui.maps.camera.lifecycle.NavigationBasicGesturesHandler
import com.mapbox.navigation.ui.maps.camera.state.NavigationCameraState
import com.mapbox.navigation.ui.maps.camera.transition.NavigationCameraTransitionOptions
import com.mapbox.navigation.ui.maps.location.NavigationLocationProvider
import com.mapbox.navigation.ui.maps.route.arrow.api.MapboxRouteArrowApi
import com.mapbox.navigation.ui.maps.route.arrow.api.MapboxRouteArrowView
import com.mapbox.navigation.ui.maps.route.arrow.model.RouteArrowOptions
import com.mapbox.navigation.ui.maps.route.line.api.MapboxRouteLineApi
import com.mapbox.navigation.ui.maps.route.line.api.MapboxRouteLineView
import com.mapbox.navigation.ui.maps.route.line.model.NavigationRouteLine
import com.mapbox.navigation.ui.maps.route.line.model.MapboxRouteLineApiOptions
import com.mapbox.navigation.ui.maps.route.line.model.MapboxRouteLineViewOptions
import com.mapbox.navigation.tripdata.progress.api.MapboxTripProgressApi
import com.mapbox.navigation.tripdata.progress.model.DistanceRemainingFormatter
import com.mapbox.navigation.tripdata.progress.model.EstimatedTimeToArrivalFormatter
import com.mapbox.navigation.tripdata.progress.model.PercentDistanceTraveledFormatter
import com.mapbox.navigation.tripdata.progress.model.TimeRemainingFormatter
import com.mapbox.navigation.tripdata.progress.model.TripProgressUpdateFormatter
import com.mapbox.navigation.ui.components.tripprogress.view.MapboxTripProgressView

import com.mapbox.navigation.voice.api.MapboxSpeechApi
import com.mapbox.navigation.voice.api.MapboxVoiceInstructionsPlayer
import com.mapbox.navigation.voice.model.SpeechAnnouncement
import com.mapbox.navigation.voice.model.SpeechError
import com.mapbox.navigation.voice.model.SpeechValue
import com.mapbox.navigation.voice.model.SpeechVolume

import java.util.Locale
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.mapbox.navigation.core.directions.session.RoutesUpdatedResult
import com.mapbox.common.location.Location
import com.mapbox.maps.ImageHolder
import com.mapbox.maps.extension.style.layers.getLayer
import com.mapbox.maps.plugin.locationcomponent.LocationComponentConstants
import com.mapbox.navigation.base.route.NavigationRoute
import com.mapbox.navigation.base.route.NavigationRouterCallback
import com.mapbox.navigation.ui.components.maneuver.model.ManeuverPrimaryOptions
import com.mapbox.navigation.ui.components.maneuver.model.ManeuverSecondaryOptions
import com.mapbox.navigation.ui.components.maneuver.model.ManeuverSubOptions
import com.mapbox.navigation.ui.components.maneuver.model.ManeuverViewOptions
import com.mapbox.navigation.ui.maps.route.RouteLayerConstants

class MapboxNavigationView(private val context: ThemedReactContext, private val accessToken: String?) :
        FrameLayout(context.baseContext) {

    private companion object {
        private const val BUTTON_ANIMATION_DURATION = 1500L
    }

    private var origin: Point? = null
    private var destination: Point? = null
    private var shouldSimulateRoute = false
    private var showsEndOfRouteFeedback = false
    private var hideReportFeedback = false
    private var mute = false
    private var mapStyleURL = ""
    private var viewStyles: ReadableMap? = null
    private var isCarplayView = false
    private var isDarkMode = false

    /**
     * Debug tool used to play, pause and seek route progress events that can be used to produce mocked location updates along the route.
     */
    private val mapboxReplayer = MapboxReplayer()

    /**
     * Debug tool that mocks location updates with an input from the [mapboxReplayer].
     */
    //private val replayLocationEngine = ReplayLocationEngine(mapboxReplayer)

    /**
     * Debug observer that makes sure the replayer has always an up-to-date information to generate mock updates.
     */
    private val replayProgressObserver = ReplayProgressObserver(mapboxReplayer)

    /**
     * Bindings to the example layout.
     */
    private var binding: NavigationViewBinding =
            NavigationViewBinding.inflate(LayoutInflater.from(context), this, true)

    /**
     * Mapbox Maps entry point obtained from the [MapView].
     * You need to get a new reference to this object whenever the [MapView] is recreated.
     */
    private lateinit var mapboxMap: MapboxMap

    private var mapStyle: Style? = null

    /**
     * Mapbox Navigation entry point. There should only be one instance of this object for the app.
     * You can use [MapboxNavigationProvider] to help create and obtain that instance.
     */
    private lateinit var mapboxNavigation: MapboxNavigation

    /**
     * Used to execute camera transitions based on the data generated by the [viewportDataSource].
     * This includes transitions from route overview to route following and continuously updating the camera as the location changes.
     */
    private lateinit var navigationCamera: NavigationCamera

    /**
     * Produces the camera frames based on the location and routing data for the [navigationCamera] to execute.
     */
    private lateinit var viewportDataSource: MapboxNavigationViewportDataSource

    /*
     * Below are generated camera padding values to ensure that the route fits well on screen while
     * other elements are overlaid on top of the map (including instruction view, buttons, etc.)
     */
    private val pixelDensity = Resources.getSystem().displayMetrics.density
    private val overviewPadding: EdgeInsets by lazy {
        EdgeInsets(
                140.0 * pixelDensity,
                40.0 * pixelDensity,
                120.0 * pixelDensity,
                40.0 * pixelDensity
        )
    }
    private val landscapeOverviewPadding: EdgeInsets by lazy {
        EdgeInsets(
                30.0 * pixelDensity,
                380.0 * pixelDensity,
                110.0 * pixelDensity,
                20.0 * pixelDensity
        )
    }
    private val followingPadding: EdgeInsets by lazy {
        EdgeInsets(
                180.0 * pixelDensity,
                40.0 * pixelDensity,
                150.0 * pixelDensity,
                40.0 * pixelDensity
        )
    }
    private val landscapeFollowingPadding: EdgeInsets by lazy {
        EdgeInsets(
                30.0 * pixelDensity,
                380.0 * pixelDensity,
                110.0 * pixelDensity,
                40.0 * pixelDensity
        )
    }

    /**
     * Generates updates for the [MapboxManeuverView] to display the upcoming maneuver instructions
     * and remaining distance to the maneuver point.
     */
    private lateinit var maneuverApi: MapboxManeuverApi

    /**
     * Generates updates for the [MapboxTripProgressView] that include remaining time and distance to the destination.
     */
    private lateinit var tripProgressApi: MapboxTripProgressApi

    /**
     * Generates updates for the [routeLineView] with the geometries and properties of the routes that should be drawn on the map.
     */
    private lateinit var routeLineApi: MapboxRouteLineApi

    /**
     * Draws route lines on the map based on the data from the [routeLineApi]
     */
    private lateinit var routeLineView: MapboxRouteLineView

    /**
     * Generates updates for the [routeArrowView] with the geometries and properties of maneuver arrows that should be drawn on the map.
     */
    private val routeArrowApi: MapboxRouteArrowApi = MapboxRouteArrowApi()

    /**
     * Draws maneuver arrows on the map based on the data [routeArrowApi].
     */
    private lateinit var routeArrowView: MapboxRouteArrowView

    /**
     * Stores and updates the state of whether the voice instructions should be played as they come or muted.
     */
    private var isVoiceInstructionsMuted = false
        set(value) {
            field = value
            if (value) {
                binding.soundButton.muteAndExtend(BUTTON_ANIMATION_DURATION)
                voiceInstructionsPlayer.volume(SpeechVolume(0f))
            } else {
                binding.soundButton.unmuteAndExtend(BUTTON_ANIMATION_DURATION)
                voiceInstructionsPlayer.volume(SpeechVolume(1f))
            }
        }

    /**
     * Extracts message that should be communicated to the driver about the upcoming maneuver.
     * When possible, downloads a synthesized audio file that can be played back to the driver.
     */
    private lateinit var speechApi: MapboxSpeechApi

    /**
     * Plays the synthesized audio files with upcoming maneuver instructions
     * or uses an on-device Text-To-Speech engine to communicate the message to the driver.
     */
    private lateinit var voiceInstructionsPlayer: MapboxVoiceInstructionsPlayer

    /**
     * Observes when a new voice instruction should be played.
     */
    private val voiceInstructionsObserver = VoiceInstructionsObserver { voiceInstructions ->
        speechApi.generate(voiceInstructions, speechCallback)
    }

    /**
     * Based on whether the synthesized audio file is available, the callback plays the file
     * or uses the fall back which is played back using the on-device Text-To-Speech engine.
     */
    private val speechCallback =
            MapboxNavigationConsumer<Expected<SpeechError, SpeechValue>> { expected ->
                expected.fold(
                        { error ->
                            // play the instruction via fallback text-to-speech engine
                            voiceInstructionsPlayer.play(
                                    error.fallback,
                                    voiceInstructionsPlayerCallback
                            )
                        },
                        { value ->
                            // play the sound file from the external generator
                            voiceInstructionsPlayer.play(
                                    value.announcement,
                                    voiceInstructionsPlayerCallback
                            )
                        }
                )
            }

    /**
     * When a synthesized audio file was downloaded, this callback cleans up the disk after it was played.
     */
    private val voiceInstructionsPlayerCallback =
            MapboxNavigationConsumer<SpeechAnnouncement> { value ->
                // remove already consumed file to free-up space
                speechApi.clean(value)
            }

    /**
     * [NavigationLocationProvider] is a utility class that helps to provide location updates generated by the Navigation SDK
     * to the Maps SDK in order to update the user location indicator on the map.
     */
    private val navigationLocationProvider = NavigationLocationProvider()

    /**
     * Gets notified with location updates.
     *
     * Exposes raw updates coming directly from the location services
     * and the updates enhanced by the Navigation SDK (cleaned up and matched to the road).
     */
    private val locationObserver = object : LocationObserver {
        override fun onNewRawLocation(rawLocation: Location) {
            // not handled
        }

        override fun onNewLocationMatcherResult(locationMatcherResult: LocationMatcherResult) {
            val enhancedLocation = locationMatcherResult.enhancedLocation
            // update location puck's position on the map
            navigationLocationProvider.changePosition(
                    location = enhancedLocation,
                    keyPoints = locationMatcherResult.keyPoints,
            )

            // update camera position to account for new location
            viewportDataSource.onLocationChanged(enhancedLocation)
            viewportDataSource.evaluate()

            val event = Arguments.createMap()
            event.putDouble("longitude", enhancedLocation.longitude)
            event.putDouble("latitude", enhancedLocation.latitude)
            context
                    .getJSModule(RCTEventEmitter::class.java)
                    .receiveEvent(id, "onLocationChange", event)
        }
    }

    /**
     * Gets notified with progress along the currently active route.
     */
    private val routeProgressObserver = RouteProgressObserver { routeProgress ->
        // update the camera position to account for the progressed fragment of the route
        viewportDataSource.onRouteProgressChanged(routeProgress)
        viewportDataSource.evaluate()

        // draw the upcoming maneuver arrow on the map
        val style = mapboxMap.style
        if (style != null) {
            val maneuverArrowResult = routeArrowApi.addUpcomingManeuverArrow(routeProgress)
            routeArrowView.renderManeuverUpdate(style, maneuverArrowResult)
        }

        // update top banner with maneuver instructions
        val maneuvers = maneuverApi.getManeuvers(routeProgress)
        maneuvers.fold(
                { error ->
                    Toast.makeText(
                            context,
                            error.errorMessage,
                            Toast.LENGTH_SHORT
                    ).show()
                },
                {
                    binding.maneuverView.visibility = View.VISIBLE
//                binding.maneuverView.updatePrimaryManeuverTextVisibility(R.style.PrimaryManeuverTextAppearance.)
//                binding.maneuverView.updateSecondaryManeuverVisibility(R.style.ManeuverTextAppearance)
//                binding.maneuverView.updateSubManeuverViewVisibility(R.style.ManeuverTextAppearance)
//                binding.maneuverView.updateStepDistanceTextAppearance(R.style.StepDistanceRemainingAppearance)
                    binding.maneuverView.renderManeuvers(maneuvers)
                }
        )

        // update bottom trip progress summary
        binding.tripProgressView.render(
                tripProgressApi.getTripProgress(routeProgress)
        )

        val event = Arguments.createMap()
        event.putDouble("distanceTraveled", routeProgress.distanceTraveled.toDouble())
        event.putDouble("durationRemaining", routeProgress.durationRemaining.toDouble())
        event.putDouble("fractionTraveled", routeProgress.fractionTraveled.toDouble())
        event.putDouble("distanceRemaining", routeProgress.distanceRemaining.toDouble())
        context
                .getJSModule(RCTEventEmitter::class.java)
                .receiveEvent(id, "onRouteProgressChange", event)
    }

    /**
     * Gets notified whenever the tracked routes change.
     *
     * A change can mean:
     * - routes get changed with [MapboxNavigation.setRoutes]
     * - routes annotations get refreshed (for example, congestion annotation that indicate the live traffic along the route)
     * - driver got off route and a reroute was executed
     */
    private val routesObserver = object : RoutesObserver {
        override fun onRoutesChanged(result: RoutesUpdatedResult) {
            try {
                if (result.navigationRoutes.isNotEmpty()) {

                    val routeLines = result.navigationRoutes.map { NavigationRouteLine(it, null) }
                    routeLineApi.setNavigationRouteLines(routeLines) { value ->
                        mapStyle?.let { style ->
                            routeLineView.renderRouteDrawData(style, value)
                        }
                    }

                    // update the camera position to account for the new route
                    viewportDataSource.onRouteChanged(result.navigationRoutes.first())
                    viewportDataSource.evaluate()
                } else {
                    // remove the route line and route arrow from the map

                    mapStyle?.let { style ->
                        routeLineApi.clearRouteLine { value ->
                            routeLineView.renderClearRouteLineValue(
                                    style,
                                    value
                            )
                        }
                        routeArrowView.render(style, routeArrowApi.clearArrows())
                    }

                    // remove the route reference from camera position evaluations
                    viewportDataSource.clearRouteData()
                    viewportDataSource.evaluate()
                }
            } catch (ex: Exception) {
                sendErrorToReact(ex.toString())
            }
        }
    }

    private val arrivalObserver = object : ArrivalObserver {

        override fun onWaypointArrival(routeProgress: RouteProgress) {
            // do something when the user arrives at a waypoint
        }

        override fun onNextRouteLegStart(routeLegProgress: RouteLegProgress) {
            // do something when the user starts a new leg
        }

        override fun onFinalDestinationArrival(routeProgress: RouteProgress) {
            val event = Arguments.createMap()
            event.putString("onArrive", "")
            context
                    .getJSModule(RCTEventEmitter::class.java)
                    .receiveEvent(id, "onRouteProgressChange", event)
        }
    }


    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        onCreate()
    }

    override fun requestLayout() {
        super.requestLayout()
        post(measureAndLayout)
    }

    private val measureAndLayout = Runnable {
        measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
        layout(left, top, right, bottom)
    }

    private fun setCameraPositionToOrigin() {
//        val startingLocation = Location(origin!!.latitude(), origin!!.longitude(), System.currentTimeMillis(), null, null, null, null, null, null, null, null, null, null, null)
//        startingLocation.latitude = origin!!.latitude()
//        startingLocation.longitude = origin!!.longitude()
//        viewportDataSource.onLocationChanged(startingLocation)

        navigationCamera.requestNavigationCameraToFollowing(
                stateTransitionOptions = NavigationCameraTransitionOptions.Builder()
                        .maxDuration(0) // instant transition
                        .build()
        )
    }

    @SuppressLint("MissingPermission")
    fun onCreate() {
        if (accessToken == null) {
            sendErrorToReact("Mapbox access token is not set")
            return
        }

        if (origin == null || destination == null) {
            sendErrorToReact("origin and destination are required")
            return
        }

        mapboxMap = binding.mapView.mapboxMap

        // initialize Mapbox Navigation
        mapboxNavigation = if (MapboxNavigationProvider.isCreated()) {
            MapboxNavigationProvider.retrieve()
        } else {
            MapboxNavigationProvider.create(
                    NavigationOptions.Builder(context).build()
            )
        }

        // initialize Navigation Camera
        viewportDataSource = MapboxNavigationViewportDataSource(mapboxMap)

        navigationCamera = NavigationCamera(
                mapboxMap,
                binding.mapView.camera,
                viewportDataSource
        )
        // set the animations lifecycle listener to ensure the NavigationCamera stops
        // automatically following the user location when the map is interacted with
        binding.mapView.camera.addCameraAnimationsLifecycleListener(
                NavigationBasicGesturesHandler(navigationCamera)
        )
        navigationCamera.registerNavigationCameraStateChangeObserver { navigationCameraState ->
            // shows/hide the recenter button depending on the camera state
            when (navigationCameraState) {
                NavigationCameraState.TRANSITION_TO_FOLLOWING,
                NavigationCameraState.FOLLOWING -> binding.recenter.visibility = View.INVISIBLE
                NavigationCameraState.TRANSITION_TO_OVERVIEW,
                NavigationCameraState.OVERVIEW,
                NavigationCameraState.IDLE -> binding.recenter.visibility = View.VISIBLE
            }
        }
        // set the padding values depending on screen orientation and visible view layout
        if (this.resources.configuration.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            viewportDataSource.overviewPadding = landscapeOverviewPadding
        } else {
            viewportDataSource.overviewPadding = overviewPadding
        }
        if (this.resources.configuration.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            viewportDataSource.followingPadding = landscapeFollowingPadding
        } else {
            viewportDataSource.followingPadding = followingPadding
        }

        // make sure to use the same DistanceFormatterOptions across different features
        val distanceFormatterOptions = mapboxNavigation.navigationOptions.distanceFormatterOptions

        // initialize maneuver api that feeds the data to the top banner maneuver view
        maneuverApi = MapboxManeuverApi(
                MapboxDistanceFormatter(distanceFormatterOptions)
        )

        // initialize bottom progress view
        tripProgressApi = MapboxTripProgressApi(
                TripProgressUpdateFormatter.Builder(context)
                        .distanceRemainingFormatter(
                                DistanceRemainingFormatter(distanceFormatterOptions)
                        )
                        .timeRemainingFormatter(
                                TimeRemainingFormatter(context)
                        )
                        .percentRouteTraveledFormatter(
                                PercentDistanceTraveledFormatter()
                        )
                        .estimatedTimeToArrivalFormatter(
                                EstimatedTimeToArrivalFormatter(context, TimeFormat.NONE_SPECIFIED)
                        )
                        .build()
        )

        // initialize voice instructions api and the voice instruction player
        speechApi = MapboxSpeechApi(
                context,
                Locale.US.language
        )
        voiceInstructionsPlayer = MapboxVoiceInstructionsPlayer(
                context,
                Locale.US.language
        )

        initRouteLineComponent()
        setCameraPositionToOrigin()

        // Load the map style and store it in the mapStyle variable
        mapboxMap.loadStyle(Style.STANDARD) { style ->
            mapStyle = style

            initLocationPuckComponent()

            Log.d("MapboxNavigationStyles", "View styles: $viewStyles")
            updateStyles()

        }

        // initialize view interactions
        binding.stop.setOnClickListener {
//            clearRouteAndStopNavigation() // TODO: figure out how we want to address this since a user cannot reinitialize a route once it is canceled.
            val event = Arguments.createMap()
            event.putString("onCancelNavigation", "Navigation Closed")
            context
                    .getJSModule(RCTEventEmitter::class.java)
                    .receiveEvent(id, "onCancelNavigation", event)
        }
        binding.recenter.setOnClickListener {
            navigationCamera.requestNavigationCameraToFollowing()
            binding.routeOverview.showTextAndExtend(BUTTON_ANIMATION_DURATION)
        }
        binding.routeOverview.setOnClickListener {
            navigationCamera.requestNavigationCameraToOverview()
            binding.recenter.showTextAndExtend(BUTTON_ANIMATION_DURATION)
        }
        binding.soundButton.setOnClickListener {
            // mute/unmute voice instructions
            isVoiceInstructionsMuted = !isVoiceInstructionsMuted
        }

        // set initial sounds button state
        binding.soundButton.unmute()

        // start the trip session to being receiving location updates in free drive
        // and later when a route is set also receiving route progress updates
        if (shouldSimulateRoute) {
            //mapboxNavigation.startReplayTripSession();
        } else {
            mapboxNavigation.startTripSession()
        }
        startRoute()
    }

    private fun initRouteLineComponent() {
        // initialize route line, the withRouteLineBelowLayerId is specified to place
        // the route line below road labels layer on the map
        // the value of this option will depend on the style that you are using
        // and under which layer the route line should be placed on the map layers stack
        val mapboxRouteLineOptions = MapboxRouteLineViewOptions.Builder(context)
                .routeLineBelowLayerId(LocationComponentConstants.LOCATION_INDICATOR_LAYER)
                .build()
        val mapboxRouteLineAPIOptions = MapboxRouteLineApiOptions.Builder().build()
        routeLineApi = MapboxRouteLineApi(mapboxRouteLineAPIOptions)
        routeLineView = MapboxRouteLineView(mapboxRouteLineOptions)

        // initialize maneuver arrow view to draw arrows on the map
        val routeArrowOptions = RouteArrowOptions.Builder(context).build()
        routeArrowView = MapboxRouteArrowView(routeArrowOptions)
    }

    private fun initLocationPuckComponent() {
        val locationComponentPlugin = binding.mapView.location
        locationComponentPlugin.updateSettings {
            locationPuck = LocationPuck2D(
                    bearingImage = ImageHolder.from(R.drawable.mapbox_navigation_puck_icon),
            )
            puckBearingEnabled = true
            enabled = true
            // Use slot-based positioning
            slot = "top" // Positions the puck above POI labels and behind Place labels
        }
    }

    /**
     * Method to set maneuver view options based on viewStyles from React Native
     */
    private fun updateStyles() {
        // Handle Banner Styles
        // if (styles.hasKey("banner")) {
        //     val bannerStyles = styles.getMap("banner")
        //     bannerStyles?.let {
        //         setBannerStyles(it)
        //     }
        // }

        // Handle Maneuver Styles
        setManeuverStyles()

        // Handle Primary Text Styles
        // if (styles.hasKey("primary")) {
        //     val primaryStyles = styles.getMap("primary")
        //     primaryStyles?.let {
        //         setPrimaryTextStyles(it)
        //     }
        // }

        // Handle Secondary Text Styles
        // if (styles.hasKey("secondary")) {
        //     val secondaryStyles = styles.getMap("secondary")
        //     secondaryStyles?.let {
        //         setSecondaryTextStyles(it)
        //     }
        // }

        // Continue similarly for other style categories...
    }

    private fun setBannerStyles(styles: ReadableMap) {
//        if (styles.hasKey("topBannerBackgroundColor")) {
//            val color = parseColor(styles.getString("topBannerBackgroundColor"))
//            binding.topBannerView.setBackgroundColor(color)
//        }
//        if (styles.hasKey("bottomBannerBackgroundColor")) {
//            val color = parseColor(styles.getString("bottomBannerBackgroundColor"))
//            binding.bottomBannerView.setBackgroundColor(color)
//        }
        // Handle other banner-related styles...
    }

    private fun setManeuverStyles() {
        val maneuverViewOptions = ManeuverViewOptions.Builder()
        if (isDarkMode) {
            maneuverViewOptions.primaryManeuverOptions(
                    ManeuverPrimaryOptions.Builder()
                            .textAppearance(R.style.DarkPrimaryManeuverTextAppearance)
                            .build()
            ).secondaryManeuverOptions(
                    ManeuverSecondaryOptions.Builder()
                            .textAppearance(R.style.DarkSecondaryManeuverTextAppearance)
                            .build()
            ).subManeuverOptions(
                    ManeuverSubOptions.Builder()
                            .textAppearance(R.style.DarkSecondaryManeuverTextAppearance)
                            .build()
            )
            .upcomingManeuverBackgroundColor(R.color.DarkManeuverBackgroundColor)
            .maneuverBackgroundColor(R.color.DarkManeuverBackgroundColor)
            .subManeuverBackgroundColor(R.color.DarkSubManeuverBackgroundColor)
            .stepDistanceTextAppearance(R.style.DarkStepDistanceRemainingAppearance)
            .maneuverViewIconStyle(R.style.DarkManeuverViewIconAppearance)
        } else {
            maneuverViewOptions.primaryManeuverOptions(
                    ManeuverPrimaryOptions.Builder()
                            .textAppearance(R.style.LightPrimaryManeuverTextAppearance)
                            .build()
            ).secondaryManeuverOptions(
                    ManeuverSecondaryOptions.Builder()
                            .textAppearance(R.style.LightSecondaryManeuverTextAppearance)
                            .build()
            ).subManeuverOptions(
                    ManeuverSubOptions.Builder()
                            .textAppearance(R.style.LightSecondaryManeuverTextAppearance)
                            .build()
            )
            .upcomingManeuverBackgroundColor(R.color.LightManeuverBackgroundColor)
            .maneuverBackgroundColor(R.color.LightManeuverBackgroundColor)
            .subManeuverBackgroundColor(R.color.LightSubManeuverBackgroundColor)
            .stepDistanceTextAppearance(R.style.LightStepDistanceRemainingAppearance)
            .maneuverViewIconStyle(R.style.LightManeuverViewIconAppearance)
        }

        binding.maneuverView.updateManeuverViewOptions(maneuverViewOptions.build())
    }

    private fun setPrimaryTextStyles(styles: ReadableMap) {
//        if (styles.hasKey("normalTextColor")) {
//            val color = parseColor(styles.getString("normalTextColor"))
//            binding.primaryTextView.setTextColor(color)
//        }
        // Handle other primary text styles...
    }

    private fun setSecondaryTextStyles(styles: ReadableMap) {
//        if (styles.hasKey("normalTextColor")) {
//            val color = parseColor(styles.getString("normalTextColor"))
//            binding.secondaryTextView.setTextColor(color)
//        }
        // Handle other secondary text styles...
    }

    private fun parseColor(colorStr: String?): Int {
        return try {
            Color.parseColor(colorStr)
        } catch (e: IllegalArgumentException) {
            Log.e("MapboxNavigationView", "Invalid color string: $colorStr. Using default color.")
            Color.WHITE
        }
    }

    private fun startRoute() {
        // register event listeners
        mapboxNavigation.registerRoutesObserver(routesObserver)
        mapboxNavigation.registerArrivalObserver(arrivalObserver)
        mapboxNavigation.registerRouteProgressObserver(routeProgressObserver)
        mapboxNavigation.registerLocationObserver(locationObserver)
        mapboxNavigation.registerVoiceInstructionsObserver(voiceInstructionsObserver)
        mapboxNavigation.registerRouteProgressObserver(replayProgressObserver)

        this.origin?.let { this.destination?.let { it1 -> this.findRoute(it, it1) } }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        mapboxNavigation.unregisterRoutesObserver(routesObserver)
        mapboxNavigation.unregisterRouteProgressObserver(routeProgressObserver)
        mapboxNavigation.unregisterLocationObserver(locationObserver)
        mapboxNavigation.unregisterVoiceInstructionsObserver(voiceInstructionsObserver)
        mapboxNavigation.unregisterRouteProgressObserver(replayProgressObserver)
    }

    private fun onDestroy() {
        MapboxNavigationProvider.destroy()
        mapboxReplayer.finish()
        maneuverApi.cancel()
        routeLineApi.cancel()
        routeLineView.cancel()
        speechApi.cancel()
        voiceInstructionsPlayer.shutdown()
    }

    private fun findRoute(origin: Point, destination: Point) {
        try {
            mapboxNavigation.requestRoutes(
                    RouteOptions.builder()
                            .applyDefaultNavigationOptions()
                            .applyLanguageAndVoiceUnitOptions(context)
                            .coordinatesList(listOf(origin, destination))
                            .profile(DirectionsCriteria.PROFILE_DRIVING)
                            .steps(true)
                            .build(),
                    object : NavigationRouterCallback {
                        override fun onCanceled(routeOptions: RouteOptions, routerOrigin: String) {
                            // no impl
                        }

                        override fun onFailure(
                                reasons: List<RouterFailure>,
                                routeOptions: RouteOptions
                        ) {
                            sendErrorToReact("Error finding route $reasons")
                        }

                        override fun onRoutesReady(routes: List<NavigationRoute>, routerOrigin: String) {
                            setRouteAndStartNavigation(routes)
                        }
                    }
            )
        } catch (ex: Exception) {
            sendErrorToReact(ex.toString())
        }

    }

    private fun sendErrorToReact(error: String?) {
        val event = Arguments.createMap()
        event.putString("error", error)
        context
                .getJSModule(RCTEventEmitter::class.java)
                .receiveEvent(id, "onError", event)
    }

    private fun setRouteAndStartNavigation(routes: List<NavigationRoute>) {
        if (routes.isEmpty()) {
            sendErrorToReact("No route found")
            return;
        }
        // set routes, where the first route in the list is the primary route that
        // will be used for active guidance
        mapboxNavigation.setNavigationRoutes(routes)

        // start location simulation along the primary route
        if (shouldSimulateRoute) {
            startSimulation(routes.first())
        }

        // show UI elements
        binding.soundButton.visibility = View.VISIBLE
        binding.routeOverview.visibility = View.VISIBLE
        binding.tripProgressCard.visibility = View.VISIBLE

        // move the camera to overview when new route is available
        navigationCamera.requestNavigationCameraToFollowing()
    }

    private fun clearRouteAndStopNavigation() {
        // clear
        mapboxNavigation.setNavigationRoutes(listOf())

        // stop simulation
        mapboxReplayer.stop()

        // hide UI elements
        binding.soundButton.visibility = View.INVISIBLE
        binding.maneuverView.visibility = View.INVISIBLE
        binding.routeOverview.visibility = View.INVISIBLE
        binding.tripProgressCard.visibility = View.INVISIBLE
    }

    private fun startSimulation(route: NavigationRoute) {
        mapboxReplayer.run {
            stop()
            clearEvents()
            val replayEvents = ReplayRouteMapper().mapDirectionsRouteGeometry(route.directionsRoute)
            pushEvents(replayEvents)
            seekTo(replayEvents.first())
            play()
        }
    }

    fun onDropViewInstance() {
        this.onDestroy()
    }

    fun setOrigin(origin: Point?) {
        this.origin = origin
    }

    fun setDestination(destination: Point?) {
        this.destination = destination
    }

    fun setShouldSimulateRoute(shouldSimulateRoute: Boolean) {
        this.shouldSimulateRoute = shouldSimulateRoute
    }

    fun setShowsEndOfRouteFeedback(showsEndOfRouteFeedback: Boolean) {
        this.showsEndOfRouteFeedback = showsEndOfRouteFeedback
    }

    fun setMute(mute: Boolean) {
        this.isVoiceInstructionsMuted = mute
    }

    fun setViewStyles(viewStyles: ReadableMap) {
        this.viewStyles = viewStyles
    }

    fun setIsCarplayView(isCarplayView: Boolean) {
        this.isCarplayView = isCarplayView
    }

    fun setMapStyleURL(mapStyleURL: String) {
        this.mapStyleURL = mapStyleURL
    }

    fun setIsDarkMode(isDarkMode: Boolean) {
        this.isDarkMode = isDarkMode
    }
}
