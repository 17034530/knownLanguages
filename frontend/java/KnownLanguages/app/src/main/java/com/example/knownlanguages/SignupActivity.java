package com.example.knownlanguages;

import android.app.DatePickerDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.Spinner;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import java.util.Dictionary;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class SignupActivity extends AppCompatActivity {
    static String TAG = "SignupActivityDebug: ";  //for log
    DataController DC;

    SharedPreferences sharedpreferences;

    String MyPREFERENCES = DC.MyPREFERENCES;

    Dictionary<String, String> resultDic;


    String name, password, url, email, dob, gender;

    Toolbar toolbar;

    EditText nameET, passwordET, emailET, dobET;
    Spinner genderSPN;

    Button createBTN;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_signup);

    }

    @Override
    protected void onStart() {
        super.onStart();
        setContentView(R.layout.activity_signup);

        DC = new DataController();
        url = DC.setUrl(this);
        sharedpreferences = getSharedPreferences(MyPREFERENCES, Context.MODE_PRIVATE);

        //to check sharedpreferences and change parent class
        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                checkSharedPreferences();
            }
        }, 0);

        toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setTitle("Create Account");

        nameET = findViewById(R.id.nameET);
        passwordET = findViewById(R.id.passwordET);
        emailET = findViewById(R.id.emailET);
        dobET = findViewById(R.id.dobET);
        genderSPN = findViewById(R.id.genderSPN);

        createBTN = findViewById(R.id.createBTN);

        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(this, R.array.genderList, android.R.layout.simple_spinner_item);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_item);
        genderSPN.setAdapter(adapter);

        dobET.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //dismiss keyboard if another edittext was click earlier
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(v.getWindowToken(), 0);

                final Calendar c = Calendar.getInstance();

                // on below line we are getting
                // our day, month and year.
                int year = c.get(Calendar.YEAR);
                int month = c.get(Calendar.MONTH);
                int day = c.get(Calendar.DAY_OF_MONTH);

                // on below line we are creating a variable for date picker dialog.
                DatePickerDialog datePickerDialog = new DatePickerDialog(
                        // on below line we are passing context.
                        SignupActivity.this, new DatePickerDialog.OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                        // on below line we are setting date to our text view.
                        dobET.setText(dayOfMonth + "-" + (monthOfYear + 1) + "-" + year);
                    }
                },
                        // on below line we are passing year,
                        // month and day for selected date in our date picker.
                        year, month, day);
                // at last we are calling show to
                // display our date picker dialog.
                datePickerDialog.getDatePicker().setMaxDate(new Date().getTime());
                datePickerDialog.show();
            }
        });

        createBTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                name = nameET.getText().toString();
                password = passwordET.getText().toString();
                email = emailET.getText().toString();
                dob = DC.DateToSQL(dobET.getText().toString());
                gender = genderSPN.getSelectedItem().toString().equalsIgnoreCase("Prefer not to say") ? "" : genderSPN.getSelectedItem().toString();

                String params = String.format("{\"name\":\"%s\"," + "\"password\":\"%s\"," + "\"email\":\"%s\"," + "\"dob\":\"%s\"," + "\"gender\":\"%s\"}", name, password, email, dob, gender);
                makeHttpRequest("createUser", params, "post");
            }
        });
    }

    public void clearField() {
        name = "";
        password = "";
        email = "";
        dob = "";
        gender = "";
        nameET.setText("");
        passwordET.setText("");
        emailET.setText("");
        dobET.setText("");
        genderSPN.setSelection(0);
    }

    public void alertShowUp(String title, String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage(message).setTitle(title).setPositiveButton("OK", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                if (title.equalsIgnoreCase("error")) {
                    if (message.toLowerCase().contains("name")) {
                        name = "";
                        nameET.setText("");
                    } else if (message.toLowerCase().contains("password")) {
                        password = "";
                        passwordET.setText("");
                    } else if (message.toLowerCase().contains("email")) {
                        email = "";
                        emailET.setText("");
                    } else {
                        clearField();
                    }
                } else if (title.equalsIgnoreCase("successfully")) {
                    String device = android.os.Build.MODEL;
                    String params = String.format("{\"name\":\"%s\"," + "\"password\":\"%s\"," + "\"device\":\"%s\"}", name, password, device);
                    makeHttpRequest("login", params, "post");
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
            request = new Request.Builder().url(url + endPoint).post(requestBody).build();
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
                                        Intent i = new Intent(SignupActivity.this, HomeActivity.class);
                                        startActivity(i);
                                        finish();
                                    } else {
                                        alertShowUp("Error", resultDic.get("result"));
                                    }
                                } else if (endPoint.equalsIgnoreCase("createUser")) {
                                    boolean check = resultDic.get("check").equalsIgnoreCase("true");
                                    alertShowUp(check ? "Successfully" : "Error", resultDic.get("result"));
                                }
                            } catch (IOException e) {
                                alertShowUp("Error", "Please try again later");
                                throw new RuntimeException(e);
                            }

                        } else {
                            alertShowUp("Error", "Try again later");
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
    public void checkSharedPreferences(){
        if(sharedpreferences.getString("token",null) != null) {
            Intent i = new Intent(SignupActivity.this, HomeActivity.class);
            startActivity(i);
            finish();
        }
    }

    @Override
    public void onBackPressed() {
        Intent i = new Intent(SignupActivity.this, LoginActivity.class);
        startActivity(i);
    }
}