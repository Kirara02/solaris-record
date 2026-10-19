package id.kirara.solaris_record_app

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Runs when this app has just been updated. The "update downloaded"
 * notification is no longer wanted then, so it is removed here instead of
 * waiting for the next launch. The id matches `UpdateNotifier.notificationId`
 * on the Dart side.
 */
class PackageReplacedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_MY_PACKAGE_REPLACED) return
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(NOTIFICATION_ID)
    }

    private companion object {
        const val NOTIFICATION_ID = 7001
    }
}
