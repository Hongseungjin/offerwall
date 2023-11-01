package com.app.abeeofferwal

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine


class MyFlutterActivity : FlutterActivity(){
    companion object {
        const val EXTRA_BOOK = "offerWall"
        fun withOfferwall(context: Context, offerwall: Api.Offerwall): Intent {
            return CachedEngineBookIntentBuilder(MyFlutterApplication.ENGINE_ID)
                .build(context) .putExtra(
                    EXTRA_BOOK,
                    HashMap(offerwall.toMap())
                )
        }

    }
    class CachedEngineBookIntentBuilder(engineId: String): CachedEngineIntentBuilder(MyFlutterActivity::class.java, engineId) { }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Called shortly after the activity is created, when the activity is bound to a
        // FlutterEngine responsible for rendering the Flutter activity's content.
        super.configureFlutterEngine(flutterEngine)


        // Register the HostBookApiHandler callback class to get results from Flutter.
        Api.HostOfferwallApi.setup(flutterEngine.dartExecutor, HostBookApiHandler())


        // The book to give to Flutter is passed in from the MainActivity via this activity's
        // source intent getter. The intent contains the book serialized as on extra.
        val bookToShow = Api.Offerwall.fromMap(intent.getSerializableExtra(EXTRA_BOOK) as HashMap<String, Any>)
        // Send in the book instance to Flutter.
        Api.FlutterOfferWallApi(flutterEngine.dartExecutor).displayOfferwallDetails(bookToShow) {
            // We don't care about the callback
        }
    }

    inner class HostBookApiHandler: Api.HostOfferwallApi {
        override fun cancel() {
            // Flutter called cancel. Finish the activity with a cancel result.
            setResult(Activity.RESULT_CANCELED)
            finish()
        }

//        override fun finishEditingBook(book: Api.Book?) {
//            if (book == null) {
//                throw IllegalArgumentException("finishedEditingBook cannot be called with a null argument")
//            }
//            // Flutter returned an edited book instance. Return it to the MainActivity via the
//            // standard Android Activity set result mechanism.
//            setResult(Activity.RESULT_OK, Intent().putExtra(EXTRA_BOOK, HashMap(book.toMap())))
//            finish()
//        }
    }
}