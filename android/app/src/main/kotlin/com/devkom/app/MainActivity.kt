package com.devkom.app

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Sertifikayi Instagram / TikTok'a DOGRUDAN gondermek icin kucuk kanal
 * (lib/courses/tanitim/sertifika_paylasimi.dart).
 *
 * SDK yok: ACTION_SEND + setPackage. Dosya kendi FileProvider'imizdan
 * (SertifikaDosyaSaglayici, yalnizca cache/sertifika/) paylasiliyor ve
 * yalnizca hedef uygulamaya okuma izni veriliyor. Uygulama yuklu degilse
 * `false` donuyor; Dart tarafi genel paylasim menusunu aciyor.
 * Dart tarafinda bu cagri ebeveyn kapisinin arkasinda.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, KANAL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "uygulamayaGonder" -> {
                        val yol = call.argument<String>("yol")
                        val paketler = call.argument<List<String>>("paketler") ?: emptyList()
                        val tur = call.argument<String>("tur") ?: "image/png"
                        val metin = call.argument<String>("metin")
                        if (yol == null) {
                            result.error("yol_yok", "Dosya yolu verilmedi", null)
                        } else {
                            try {
                                result.success(gonder(File(yol), paketler, tur, metin))
                            } catch (e: Exception) {
                                result.error("gonderilemedi", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun yuklu(paket: String): Boolean = try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(paket, PackageManager.PackageInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            packageManager.getPackageInfo(paket, 0)
        }
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }

    private fun gonder(dosya: File, paketler: List<String>, tur: String, metin: String?): Boolean {
        val paket = paketler.firstOrNull { yuklu(it) } ?: return false
        val uri = FileProvider.getUriForFile(this, "$packageName.sertifika.fileprovider", dosya)
        val niyet = Intent(Intent.ACTION_SEND).apply {
            type = tur
            putExtra(Intent.EXTRA_STREAM, uri)
            if (metin != null) putExtra(Intent.EXTRA_TEXT, metin)
            setPackage(paket)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        grantUriPermission(paket, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
        startActivity(niyet)
        return true
    }

    companion object {
        private const val KANAL = "com.devkom.app/sertifika"
    }
}

/** Yalnizca sertifika dosyalari icin FileProvider (share_plus'inkinden ayri). */
class SertifikaDosyaSaglayici : FileProvider()
