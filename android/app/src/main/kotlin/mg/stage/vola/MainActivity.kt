package mg.stage.vola

import android.annotation.SuppressLint
import android.hardware.fingerprint.FingerprintManager
import android.os.Build
import android.os.CancellationSignal
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Lecture d'empreinte digitale sans fenêtre système.
 * Le téléphone compare l'empreinte ; l'application ne reçoit que le résultat
 * (reconnue, non reconnue, erreur) et ne stocke aucune donnée biométrique.
 */
@SuppressLint("NewApi")
@Suppress("DEPRECATION")
class MainActivity : FlutterFragmentActivity() {
    private var canal: MethodChannel? = null
    private var annulation: CancellationSignal? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val nouveauCanal =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "mg.stage.vola/empreinte")
        nouveauCanal.setMethodCallHandler { appel, resultat ->
            when (appel.method) {
                "etat" -> resultat.success(etat())
                "demarrer" -> {
                    demarrer()
                    resultat.success(null)
                }
                "arreter" -> {
                    arreter()
                    resultat.success(null)
                }
                else -> resultat.notImplemented()
            }
        }
        canal = nouveauCanal
    }

    private fun gestionnaire(): FingerprintManager? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return null
        return getSystemService(FingerprintManager::class.java)
    }

    private fun etat(): String {
        val g = gestionnaire() ?: return "indisponible"
        if (!g.isHardwareDetected) return "absent"
        if (!g.hasEnrolledFingerprints()) return "aucune"
        return "disponible"
    }

    private fun envoyer(type: String, detail: String?) {
        canal?.invokeMethod("evenement", mapOf("type" to type, "detail" to detail))
    }

    private fun demarrer() {
        arreter()
        val g = gestionnaire()
        if (g == null || !g.isHardwareDetected || !g.hasEnrolledFingerprints()) {
            envoyer("erreur", "indisponible")
            return
        }
        val signal = CancellationSignal()
        annulation = signal
        try {
            g.authenticate(
                null,
                signal,
                0,
                object : FingerprintManager.AuthenticationCallback() {
                    override fun onAuthenticationSucceeded(
                        result: FingerprintManager.AuthenticationResult?
                    ) {
                        envoyer("succes", null)
                    }

                    override fun onAuthenticationFailed() {
                        envoyer("echec", null)
                    }

                    override fun onAuthenticationHelp(helpCode: Int, helpString: CharSequence?) {
                        envoyer("aide", helpString?.toString())
                    }

                    override fun onAuthenticationError(errorCode: Int, errString: CharSequence?) {
                        // 5 et 10 : lecture annulée volontairement, sans importance.
                        if (errorCode != 5 && errorCode != 10) {
                            envoyer("erreur", errorCode.toString())
                        }
                    }
                },
                null
            )
        } catch (e: Exception) {
            envoyer("erreur", "exception")
        }
    }

    private fun arreter() {
        annulation?.cancel()
        annulation = null
    }

    override fun onPause() {
        arreter()
        super.onPause()
    }

    override fun onDestroy() {
        arreter()
        super.onDestroy()
    }
}