package com.vinayak.smartload

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

private const val IMPORT_CHANNEL = "com.vinayak.smartload/import"
private const val PICK_ZIP_REQUEST = 8101
private const val PICK_FOLDER_REQUEST = 8102
private const val MAX_IMPORT_FILES = 100_000
private const val MAX_IMPORT_BYTES = 2L * 1024 * 1024 * 1024
private const val MAX_FOLDER_DEPTH = 64

private data class CopyBudget(var files: Int = 0, var bytes: Long = 0)

/**
 * Main Android entry point for the Flutter application.
 *
 * Keep this class deliberately small: camera capability detection is handled
 * by CameraX, and the app does not expose a separate native camera activity.
 */
class MainActivity : FlutterActivity() {
    private var pendingResult: MethodChannel.Result? = null
    private var pendingRequest = 0
    private val importExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IMPORT_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "pickZip" && call.method != "pickFolder") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (pendingResult != null) {
                    result.error("BUSY", "Another file selection is already open.", null)
                    return@setMethodCallHandler
                }
                pendingResult = result
                pendingRequest = if (call.method == "pickZip") {
                    PICK_ZIP_REQUEST
                } else {
                    PICK_FOLDER_REQUEST
                }
                val intent = if (pendingRequest == PICK_ZIP_REQUEST) {
                    Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
                        // Some Android file managers report ZIP files as
                        // application/octet-stream. Show all files here and
                        // let SmartLoad validate the selected archive.
                        type = "*/*"
                        putExtra(Intent.EXTRA_MIME_TYPES, arrayOf(
                            "application/zip",
                            "application/x-zip-compressed",
                            "application/octet-stream"
                        ))
                    }
                } else {
                    Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
                    }
                }
                startActivityForResult(intent, pendingRequest)
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_ZIP_REQUEST && requestCode != PICK_FOLDER_REQUEST) return
        val result = pendingResult ?: return
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            pendingResult = null
            pendingRequest = 0
            result.success(null)
            return
        }

        val selectedUri = data.data!!
        try {
            contentResolver.takePersistableUriPermission(
                selectedUri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
        } catch (_: SecurityException) {
            // Some providers grant access only for this activity result. The
            // copy below still succeeds while that temporary grant is active.
        }

        // A SmartLoad archive can contain hundreds of megabytes of photos.
        // Never copy it on Android's UI thread: doing so causes an ANR or a
        // process kill that looks like the app closed after file selection.
        importExecutor.execute {
            try {
                val path = if (requestCode == PICK_ZIP_REQUEST) {
                    copyUriToWorkspace(
                        selectedUri,
                        "smartload_import_${System.currentTimeMillis()}.zip"
                    )
                } else {
                    copyTreeToWorkspace(selectedUri)
                }
                mainHandler.post {
                    pendingResult = null
                    pendingRequest = 0
                    result.success(path)
                }
            } catch (error: Exception) {
                mainHandler.post {
                    pendingResult = null
                    pendingRequest = 0
                    result.error(
                        "IMPORT_PICK_FAILED",
                        error.message ?: "Could not copy the selected archive.",
                        null
                    )
                }
            }
        }
    }

    private fun copyUriToWorkspace(uri: Uri, name: String): String {
        val destination = File(importWorkspace(), name)
        val partial = File(importWorkspace(), "$name.part")
        try {
            contentResolver.openInputStream(uri).use { input ->
                requireNotNull(input) { "Could not read the selected file." }
                partial.outputStream().use { output ->
                    copyStreamWithLimit(input, output, CopyBudget(files = 1))
                }
            }
            if (destination.exists()) destination.delete()
            check(partial.renameTo(destination)) { "Could not finish copying the selected ZIP." }
            return destination.absolutePath
        } catch (error: Throwable) {
            partial.delete()
            throw error
        }
    }

    private fun copyTreeToWorkspace(treeUri: Uri): String {
        val destination = File(importWorkspace(), "smartload_import_${System.currentTimeMillis()}")
        destination.mkdirs()
        try {
            val rootDocumentId = DocumentsContract.getTreeDocumentId(treeUri)
            copyTreeChildren(
                treeUri = treeUri,
                parentDocumentId = rootDocumentId,
                destination = destination,
                visited = mutableSetOf(),
                budget = CopyBudget(),
                depth = 0
            )
            return destination.absolutePath
        } catch (error: Throwable) {
            destination.deleteRecursively()
            throw error
        }
    }

    private fun importWorkspace(): File {
        // cacheDir may be reclaimed while a large ZIP is being processed.
        // filesDir is private internal storage and remains stable for import.
        return File(filesDir, "archive_imports").also { it.mkdirs() }
    }

    private fun copyTreeChildren(
        treeUri: Uri,
        parentDocumentId: String,
        destination: File,
        visited: MutableSet<String>,
        budget: CopyBudget,
        depth: Int
    ) {
        require(depth <= MAX_FOLDER_DEPTH) { "The selected folder is nested too deeply." }
        require(visited.add(parentDocumentId)) { "The selected folder contains a cyclic link." }
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
            treeUri, parentDocumentId
        )
        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE
        )
        contentResolver.query(childrenUri, projection, null, null, null).use { cursor ->
            requireNotNull(cursor) { "Could not read the selected folder." }
            val id = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
            val name = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
            val mime = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)
            while (cursor.moveToNext()) {
                val displayName = cursor.getString(name) ?: "unnamed"
                val safeName = displayName
                    .replace("/", "_")
                    .replace("\\", "_")
                    .ifBlank { "unnamed" }
                val childUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, cursor.getString(id))
                val child = File(destination, safeName)
                if (cursor.getString(mime) == DocumentsContract.Document.MIME_TYPE_DIR) {
                    child.mkdirs()
                    copyTreeChildren(
                        treeUri = treeUri,
                        parentDocumentId = cursor.getString(id),
                        destination = child,
                        visited = visited,
                        budget = budget,
                        depth = depth + 1
                    )
                } else {
                    budget.files++
                    require(budget.files <= MAX_IMPORT_FILES) {
                        "The selected archive contains too many files."
                    }
                    contentResolver.openInputStream(childUri).use { input ->
                        requireNotNull(input) { "Could not read archive folder file." }
                        child.outputStream().use { output ->
                            copyStreamWithLimit(input, output, budget)
                        }
                    }
                }
            }
        }
    }

    private fun copyStreamWithLimit(
        input: java.io.InputStream,
        output: java.io.OutputStream,
        budget: CopyBudget
    ) {
        val buffer = ByteArray(64 * 1024)
        var count: Int
        while (input.read(buffer).also { count = it } != -1) {
            budget.bytes += count
            require(budget.bytes <= MAX_IMPORT_BYTES) {
                "The selected archive is larger than 2 GB."
            }
            output.write(buffer, 0, count)
        }
    }

    override fun onDestroy() {
        importExecutor.shutdown()
        super.onDestroy()
    }
}
