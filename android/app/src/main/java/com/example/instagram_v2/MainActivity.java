package com.example.instagram_v2;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    public static final int REQUEST_CODE = 100;
    Uri imagePath;
    MethodChannel.Result pendingResult;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "photogram")
            .setMethodCallHandler(new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if (call.method.equals("edit photo")) {
                  Intent intent = new Intent(MainActivity.this, EditImageActivity.class);
                  intent.putExtra("uri", call.argument("arg") + "");
                  pendingResult = result;
                    Log.d("uri", call.argument("arg"));
                  startActivityForResult(intent, REQUEST_CODE);

                }
              }
            });
  }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                imagePath = data.getData();
                Log.d("uri", imagePath.getPath());
                pendingResult.success(getPathFromRemoteUri(MainActivity.this, imagePath));
            }
        }
    }

    private static String getPathFromRemoteUri(final Context context, final Uri uri) {
        // The code below is why Java now has try-with-resources and the Files utility.
        File file = null;
        InputStream inputStream = null;
        OutputStream outputStream = null;
        boolean success = false;
        try {
            inputStream = context.getContentResolver().openInputStream(uri);
            file = File.createTempFile("image_filter", "jpg", context.getCacheDir());
            outputStream = new FileOutputStream(file);
            if (inputStream != null) {
                copy(inputStream, outputStream);
                success = true;
            }
        } catch (IOException ignored) {
            ignored.printStackTrace();
        } finally {
            try {
                if (inputStream != null) inputStream.close();
            } catch (IOException ignored) {
            }
            try {
                if (outputStream != null) outputStream.close();
            } catch (IOException ignored) {
                // If closing the output stream fails, we cannot be sure that the
                // target file was written in full. Flushing the stream merely moves
                // the bytes into the OS, not necessarily to the file.
                success = false;
            }
        }
        return success ? file.getPath() : null;
    }

    private static void copy(InputStream in, OutputStream out) throws IOException {
        final byte[] buffer = new byte[4 * 1024];
        int bytesRead;
        while ((bytesRead = in.read(buffer)) != -1) {
            out.write(buffer, 0, bytesRead);
        }
        out.flush();
    }
}
