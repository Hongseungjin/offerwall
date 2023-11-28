package flutter.overlay.window.flutter_overlay_window;

import android.app.Activity;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.PowerManager;
import android.provider.Settings;
import android.service.notification.StatusBarNotification;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationManagerCompat;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.FlutterEngineGroup;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.JSONMessageCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterMain;

public class FlutterOverlayWindowPlugin implements
        FlutterPlugin, ActivityAware, BasicMessageChannel.MessageHandler, MethodCallHandler,
        PluginRegistry.ActivityResultListener {

    private MethodChannel channel;
    private Context context;
    private Activity mActivity;
    private BasicMessageChannel<Object> messenger;
    private Result pendingResult;
    final int REQUEST_CODE_FOR_OVERLAY_PERMISSION = 1248;
    private Toast toast = null;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        this.context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), OverlayConstants.CHANNEL_TAG);
        channel.setMethodCallHandler(this);

        messenger = new BasicMessageChannel(flutterPluginBinding.getBinaryMessenger(), OverlayConstants.MESSENGER_TAG,
                JSONMessageCodec.INSTANCE);
        messenger.setMessageHandler(this);

        WindowSetup.messenger = messenger;
        WindowSetup.messenger.setMessageHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        pendingResult = result;
//         if (call.method.equals("checkPermissionBattery")) {
// //                try{
// //                    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
// //                        Intent intent = new Intent();
// //                        String packageName = context.getPackageName();
// //                        PowerManager pm = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
// //                        if (!pm.isIgnoringBatteryOptimizations(packageName)) {
// //                            intent.setAction(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
// //                            intent.setData(Uri.parse("package:" + packageName));
// //                            context.startService(intent);
// //                        }
// //                    }
// //                }catch (Exception e){
// //                    result.error("open app failure", e.getMessage(),e);
// //                }
//             result.success(true);

//         } else 
        if (call.method.equals("checkPermission")) {
            result.success(checkOverlayPermission());
        } else if (call.method.equals("requestPermission")) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
                intent.setData(Uri.parse("package:" + mActivity.getPackageName()));
                mActivity.startActivityForResult(intent, REQUEST_CODE_FOR_OVERLAY_PERMISSION);
            } else {
                result.success(true);
            }
        } else if (call.method.equals("showOverlay")) {
            try {
                if (!checkOverlayPermission()) {
                    result.error("PERMISSION", "overlay permission is not enabled", null);
                    return;
                }
                Integer height = call.argument("height");
                Integer width = call.argument("width");
                String alignment = call.argument("alignment");
                String flag = call.argument("flag");
                String overlayTitle = call.argument("overlayTitle");
                String overlayContent = call.argument("overlayContent");
                String notificationVisibility = call.argument("notificationVisibility");
                boolean enableDrag = call.argument("enableDrag");
                boolean ensureOpenOnlyOneOverlay = call.argument("ensureOpenOnlyOneOverlay");
                String positionGravity = call.argument("positionGravity");

                WindowSetup.width = width != null ? width : -1;
                WindowSetup.height = height != null ? height : -1;
                WindowSetup.enableDrag = enableDrag;
                WindowSetup.setGravityFromAlignment(alignment != null ? alignment : "center");
                WindowSetup.setFlag(flag != null ? flag : "flagNotFocusable");
                WindowSetup.overlayTitle = overlayTitle;
                WindowSetup.overlayContent = overlayContent == null ? "" : overlayContent;
                WindowSetup.positionGravity = positionGravity;
                WindowSetup.setNotificationVisibility(notificationVisibility);


                if (ensureOpenOnlyOneOverlay) {
                    if (OverlayService.isRunning) {
                        final Intent i = new Intent(context, OverlayService.class);
                        i.putExtra(OverlayService.INTENT_EXTRA_IS_CLOSE_WINDOW, true);
                        context.startService(i);
                    }
                }
                final Intent intent = new Intent(context, OverlayService.class);
//                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent.addFlags(Intent.FLAG_ACTIVITY_TASK_ON_HOME);
                intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
                context.startService(intent);
                result.success(null);
            } catch (Exception e) {
                result.error("showOverlay failure", e.getMessage(), e);
            }
            return;

        } else if (call.method.equals("isOverlayActive")) {
            result.success(OverlayService.isRunning);
            return;
        } else if (call.method.equals("closeOverlay")) {
            try {
                if (OverlayService.isRunning) {
                    final Intent i = new Intent(context, OverlayService.class);
                    i.putExtra(OverlayService.INTENT_EXTRA_IS_CLOSE_WINDOW, true);
                    context.startService(i);
                    result.success(true);
                    return;
                }
                result.success(false);
                return;
            } catch (Exception error) {
                result.error("closeOverlay failure", error.getMessage(), error);
                return;
            }
//            return;
        } else if (call.method.equals("showToast")) {
            String message = call.argument("message");
            toast = Toast.makeText(context, message, Toast.LENGTH_LONG);
            toast.show();
        } else {
            result.notImplemented();
        }

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        // fix run overlay and share data when app killed
//        channel.setMethodCallHandler(null);
//        WindowSetup.messenger.setMessageHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
        FlutterEngineGroup enn = new FlutterEngineGroup(context);
        DartExecutor.DartEntrypoint dEntry = new DartExecutor.DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                "overlayMain");
        FlutterEngine engine = enn.createAndRunEngine(context, dEntry);
        FlutterEngineCache.getInstance().put(OverlayConstants.CACHED_TAG, engine);
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        this.mActivity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
    }


    @Override
    public void onMessage(@Nullable Object message, @NonNull BasicMessageChannel.Reply reply) {
//         Log.d("flutterOverlayWindow", "xxxxxxxxx=>>>>>>");
//         DartExecutor engine;
//         try {
// //            FlutterMain.startInitialization(context);
//             engine = FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG)
//                     .getDartExecutor();
//         } catch (Exception e) {
//             Log.d("flutterOverlayWindow", "xxxxxxxxx=>>>>>> ERRRRRR ");

//             FlutterEngineGroup enn = new FlutterEngineGroup(context);
//             DartExecutor.DartEntrypoint dEntry = new DartExecutor.DartEntrypoint(
//                     FlutterInjector.instance().flutterLoader().findAppBundlePath(),
//                     "overlayMain");
//             FlutterEngine engineNew = enn.createAndRunEngine(context, dEntry);
//             FlutterEngineCache.getInstance().put(OverlayConstants.CACHED_TAG, engineNew);

//             engine = FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG)
//                     .getDartExecutor();
//         }


//         BasicMessageChannel overlayMessageChannel = new BasicMessageChannel(engine,
//                 OverlayConstants.MESSENGER_TAG, JSONMessageCodec.INSTANCE);
//         overlayMessageChannel.send(message, reply);


       BasicMessageChannel overlayMessageChannel = new BasicMessageChannel(
               FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG)
                       .getDartExecutor(),
               OverlayConstants.MESSENGER_TAG, JSONMessageCodec.INSTANCE);
       overlayMessageChannel.send(message, reply);
    }

    private boolean checkOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return Settings.canDrawOverlays(context);
        }
        return true;
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_FOR_OVERLAY_PERMISSION) {
            pendingResult.success(checkOverlayPermission());
            return true;
        }
        return false;
    }

}
