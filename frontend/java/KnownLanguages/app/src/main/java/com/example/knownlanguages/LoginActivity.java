package com.example.knownlanguages;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.loopj.android.http.BuildConfig;

import java.io.IOException;
import java.util.Dictionary;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;


public class LoginActivity extends AppCompatActivity {
    static String TAG = "LoginActivityDebug: ";  //for log
    DataController DC;
    SharedPreferences sharedpreferences;
    String MyPREFERENCES = DC.MyPREFERENCES;
    Dictionary<String, String> resultDic;
    String name, password, url;
    Toolbar toolbar;
    EditText nameET, passwordET;
    Button loginBTN, signupBTN;

    Boolean releaseMode;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onStart() {
        super.onStart();
        setContentView(R.layout.activity_login);

        DC = new DataController();
        url = DC.setUrl(this);
        sharedpreferences = getSharedPreferences(MyPREFERENCES, Context.MODE_PRIVATE);


        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                checkSharedPreferences();
            }
        }, 0);

        toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setTitle("Login");

        nameET = findViewById(R.id.nameET);
        passwordET = findViewById(R.id.passwordET);

        loginBTN = findViewById(R.id.loginBTN);
        signupBTN = findViewById(R.id.signupBTN);

        loginBTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                name = nameET.getText().toString();
                password = passwordET.getText().toString();
                String device = Settings.Global.getString(getContentResolver(), "device_name");

                String params = String.format(
                        "{\"name\":\"%s\"," +
                                "\"password\":\"%s\"," +
                                "\"device\":\"%s\"}",
                        name, password, device);
                makeHttpRequest("login", params, "post");
            }
        });

        signupBTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(LoginActivity.this, SignupActivity.class);
                startActivity(i);
                finish();
            }
        });
        releaseMode = !BuildConfig.DEBUG;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if (releaseMode) {
            getMenuInflater().inflate(R.menu.toolbar_menu, menu);
            return true;
        } else {
            return false;
        }
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (releaseMode) {
            if (item.getItemId() == R.id.setting) {
                Intent i = new Intent(LoginActivity.this, IPSettingActivity.class);
                startActivity(i);
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    public void clearField() {
        name = "";
        password = "";
        nameET.setText("");
        passwordET.setText("");
    }

    public void alertShowUp(String title, String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);

        builder.setMessage(message)
                .setTitle(title)
                .setPositiveButton("OK", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        if (title.equalsIgnoreCase("error")) {
                            clearField();
                        }
                    }
                });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private void makeHttpRequest(String endPoint, String params, String method) {
        OkHttpClient client = new OkHttpClient();

        MediaType mediaType = MediaType.parse("application/json; charset=utf-8");
        RequestBody requestBody = RequestBody.create(params, mediaType);

        Request request = null;
        if (method.equalsIgnoreCase("post")) {
            request = new Request.Builder()
                    .url(url + endPoint)
                    .post(requestBody)
                    .build();
        }

        client.newCall(request).enqueue(new Callback() {
            Handler mainHandler = new Handler(Looper.getMainLooper());

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (response.isSuccessful()) {
                            try {
                                String responseBody = response.body().string();
                                resultDic = DC.StringToDic(responseBody);

                                if (endPoint.equalsIgnoreCase("login")) {
                                    if (resultDic.get("check").equalsIgnoreCase("true")) {
                                        SharedPreferences.Editor editor = sharedpreferences.edit();
                                        editor.putString("name", name);
                                        editor.putString("token", resultDic.get("token"));
                                        editor.commit();
                                        Intent i = new Intent(LoginActivity.this, HomeActivity.class);
                                        i.putExtra("justLogin",true);
                                        startActivity(i);
                                        finish();
                                    } else {
                                        alertShowUp("Error", resultDic.get("result"));
                                    }
                                }
                            } catch (IOException e) {
                                alertShowUp("Error", "Please try again later");
                            }
                        } else {
                            alertShowUp("Error", "Please try again later");

                        }
                    }
                });
            }

            @Override
            public void onFailure(Call call, IOException e) {
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        alertShowUp("Error", "Please try again later");
                    }
                });
            }
        });
    }

    @Override
    public void onBackPressed() {
        moveTaskToBack(true); //exit the app
    }
    public void checkSharedPreferences(){
        if(sharedpreferences.getString("token",null) != null) {
            Intent i = new Intent(LoginActivity.this, HomeActivity.class);
            startActivity(i);
            finish();
        }
    }
}
