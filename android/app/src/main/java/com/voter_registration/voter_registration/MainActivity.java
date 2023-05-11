package com.voter_registration.voter_registration;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.SystemClock;
import android.util.Log;
import android.view.WindowManager;
import android.widget.Toast;

import com.mantra.mfs100.FingerData;
import com.mantra.mfs100.MFS100;
import com.mantra.mfs100.MFS100Event;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.UUID;


public class MainActivity extends FlutterActivity implements MFS100Event {
    private static final String CHANNEL = "fingerprint.scanner";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "getMessage":
                                    result.success(message);
                                    break;
                                case "getLogs":
                                    result.success(logs);
                                    break;
                                case "init":
                                    InitScanner();
                                    break;
                                case "unInit":
                                    UnInitScanner();
                                    break;
                                case "capture":
                                    StartSyncCapture();
                                    break;
                                case "stopCapture":
                                    StopCapture();
                                    break;
                                case "setFastDetectionTrue":
                                    fastDetectionChecked = true;
                                    break;
                                case "setFastDetectionFalse":
                                    fastDetectionChecked = false;
                                    break;
                                case "checkFingerUuid":
                                    result.success(fingerUuid);
                                    break;
                                case "getFingerImage":
                                    result.success(fingerImage);
                                    break;
                                case "getFingerQuality":
                                    result.success(fingerDataQuality);
                                    break;
                                case "getIsoFilepath":
                                    result.success(isoFilepath);
                                    break;
                                case "getCaptureRunning":
                                    result.success(isCaptureRunning?"true":"false");
                                    break;
                                case "clearLogs":
                                    logs = "";
                                    result.success(logs);
                                    break;
                                default:
                                    result.notImplemented();
                                    break;
                            }
                        }

                );
    }

    private static long mLastClkTime = 0;
    private static final long Threshold = 1500;

    private enum ScannerAction {
        Capture, Verify
    }

    byte[] Enroll_Template;
    byte[] Verify_Template;
    private FingerData lastCapFingerData = null;
    ScannerAction scannerAction = ScannerAction.Capture;

    int timeout = 10000;
    MFS100 mfs100 = null;

    private boolean isCaptureRunning = false;

    private String message = "";
    private String logs = "";

    private boolean fastDetectionChecked = false;

    private byte[] fingerImage;
    private String fingerUuid = "";

    private int fingerDataQuality = 0;

    private String isoFilepath = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        try {
            this.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
        } catch (Exception e) {
            Log.e("Error", e.toString());
        }

        try {
            mfs100 = new MFS100(this);
            mfs100.SetApplicationContext(MainActivity.this);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void InitScanner() {
        try {
            int ret = mfs100.Init();
            if (ret != 0) {
                SetTextOnUIThread(mfs100.GetErrorMsg(ret));
            } else {
                SetTextOnUIThread("Init success");
                String info = "Serial: " + mfs100.GetDeviceInfo().SerialNo()
                        + " Make: " + mfs100.GetDeviceInfo().Make()
                        + " Model: " + mfs100.GetDeviceInfo().Model()
                        + "\nCertificate: " + mfs100.GetCertification();
                SetLogOnUIThread(info);
            }
        } catch (Exception ex) {
            Toast.makeText(getApplicationContext(), "Init failed, unhandled exception",
                    Toast.LENGTH_LONG).show();
            SetTextOnUIThread("Init failed, unhandled exception");
        }
    }

    @Override
    protected void onStart() {
        try {
            if (mfs100 == null) {
                mfs100 = new MFS100(this);
                mfs100.SetApplicationContext(MainActivity.this);
            } else {
                InitScanner();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        super.onStart();
    }

    private long mLastAttTime= 0L;

    private void SetTextOnUIThread(final String str) {
        message = str;
    }

    private void SetLogOnUIThread(final String str) {
        logs+= "\n" + str;
    }

    private void showSuccessLog(String key) {
        try {
            SetTextOnUIThread("Init success");
            String info = "\nKey: " + key + "\nSerial: "
                    + mfs100.GetDeviceInfo().SerialNo() + " Make: "
                    + mfs100.GetDeviceInfo().Make() + " Model: "
                    + mfs100.GetDeviceInfo().Model()
                    + "\nCertificate: " + mfs100.GetCertification();
            SetLogOnUIThread(info);
        } catch (Exception ignored) {
        }
    }

    private String WriteFile(String filename, byte[] bytes) {
        String filepath = "";
        try {
            String path =getExternalFilesDir(null)
                    + "//FingerData";
            File file = new File(path);
            if (!file.exists()) {
                file.mkdirs();
            }
            path = path + "//" + filename;
            file = new File(path);
            if (!file.exists()) {
                file.createNewFile();
            }
            FileOutputStream stream = new FileOutputStream(path);
            stream.write(bytes);
            stream.close();
            filepath = path;
        } catch (Exception e1) {
            e1.printStackTrace();
        }
        return filepath;
    }

    public void SetData2(FingerData fingerData) {
        try {
            if (scannerAction.equals(ScannerAction.Capture)) {
                Enroll_Template = new byte[fingerData.ISOTemplate().length];
                System.arraycopy(fingerData.ISOTemplate(), 0, Enroll_Template, 0,
                        fingerData.ISOTemplate().length);
            } else if (scannerAction.equals(ScannerAction.Verify)) {
                if (Enroll_Template == null) {
                    return;
                }
                Verify_Template = new byte[fingerData.ISOTemplate().length];
                System.arraycopy(fingerData.ISOTemplate(), 0, Verify_Template, 0,
                        fingerData.ISOTemplate().length);
                int ret = mfs100.MatchISO(Enroll_Template, Verify_Template);
                if (ret < 0) {
                    SetTextOnUIThread("Error: " + ret + "(" + mfs100.GetErrorMsg(ret) + ")");
                } else {
                    if (ret >= 96) {
                        SetTextOnUIThread("Finger matched with score: " + ret);
                    } else {
                        SetTextOnUIThread("Finger not matched, score: " + ret);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            WriteFile("Raw.raw", fingerData.RawData());
            WriteFile("Bitmap.bmp", fingerData.FingerImage());
            isoFilepath = WriteFile("ISOTemplate.iso", fingerData.ISOTemplate());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void StartSyncCapture() {
        fingerUuid = "";
        new Thread(() -> {
            SetTextOnUIThread("");
            isCaptureRunning = true;
            try {
                FingerData fingerData = new FingerData();
                int ret = mfs100.AutoCapture(fingerData, timeout, fastDetectionChecked);
                Log.e("StartSyncCapture.RET", "" + ret);
                if (ret != 0) {
                    SetTextOnUIThread(mfs100.GetErrorMsg(ret));
                } else {
                    lastCapFingerData = fingerData;

//                    Bitmap fingerBitmap = BitmapFactory.decodeByteArray(fingerData.FingerImage(), 0, fingerData.FingerImage().length);
                    fingerUuid = UUID.randomUUID().toString();
                    fingerImage = fingerData.FingerImage();
                    fingerDataQuality = fingerData.Quality();

                    SetTextOnUIThread("Capture Success");
                    String log = "\nQuality: " + fingerData.Quality()
                            + "\nNFIQ: " + fingerData.Nfiq()
                            + "\nWSQ Compress Ratio: "
                            + fingerData.WSQCompressRatio()
                            + "\nImage Dimensions (inch): "
                            + fingerData.InWidth() + "\" X "
                            + fingerData.InHeight() + "\""
                            + "\nImage Area (inch): " + fingerData.InArea()
                            + "\"" + "\nResolution (dpi/ppi): "
                            + fingerData.Resolution() + "\nGray Scale: "
                            + fingerData.GrayScale() + "\nBits Per Pixel: "
                            + fingerData.Bpp() + "\nWSQ Info: "
                            + fingerData.WSQInfo();
                    SetLogOnUIThread(log);
                    SetData2(fingerData);
                }
            } catch (Exception ex) {
                SetTextOnUIThread("Error");
            } finally {
                isCaptureRunning = false;
            }
        }).start();
    }

    private void StopCapture() {
        try {
            mfs100.StopAutoCapture();
        } catch (Exception e) {
            SetTextOnUIThread("Error");
        }
    }

    @Override
    public void OnDeviceAttached(int vid, int pid, boolean hasPermission) {
        if (SystemClock.elapsedRealtime() - mLastAttTime < Threshold) {
            return;
        }
        mLastAttTime = SystemClock.elapsedRealtime();
        int ret;
        if (!hasPermission) {
            SetTextOnUIThread("Permission denied");
            return;
        }
        try {
            if (vid == 1204 || vid == 11279) {
                if (pid == 34323) {
                    ret = mfs100.LoadFirmware();
                    if (ret != 0) {
                        SetTextOnUIThread(mfs100.GetErrorMsg(ret));
                    } else {
                        SetTextOnUIThread("Load firmware success");
                    }
                } else if (pid == 4101) {
                    String key = "Without Key";
                    ret = mfs100.Init();
                    if (ret == 0) {
                        showSuccessLog(key);
                    } else {
                        SetTextOnUIThread(mfs100.GetErrorMsg(ret));
                    }

                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void UnInitScanner() {
        try {
            int ret = mfs100.UnInit();
            if (ret != 0) {
                SetTextOnUIThread(mfs100.GetErrorMsg(ret));
            } else {
                SetLogOnUIThread("Uninit Success");
                SetTextOnUIThread("Uninit Success");
                lastCapFingerData = null;
            }
        } catch (Exception e) {
            Log.e("UnInitScanner.EX", e.toString());
        }
    }

    long mLastDttTime= 0L;
    @Override
    public void OnDeviceDetached() {
        try {

            if (SystemClock.elapsedRealtime() - mLastDttTime < Threshold) {
                return;
            }
            mLastDttTime = SystemClock.elapsedRealtime();
            UnInitScanner();

            SetTextOnUIThread("Device removed");
        } catch (Exception ignored) {
        }
    }

    @Override
    public void OnHostCheckFailed(String err) {
        try {
            SetLogOnUIThread(err);
            Toast.makeText(getApplicationContext(), err, Toast.LENGTH_LONG).show();
        } catch (Exception ignored) {
        }
    }
}
