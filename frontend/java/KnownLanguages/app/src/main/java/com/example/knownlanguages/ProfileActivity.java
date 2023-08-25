package com.example.knownlanguages;

import android.app.DatePickerDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.navigation.NavigationBarView;

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

public class ProfileActivity extends AppCompatActivity {
    static String TAG = "ProfileActivityDebug: ";  //for log
    DataController DC;
    SharedPreferences sharedpreferences;
    String MyPREFERENCES = DataController.MyPREFERENCES;
    Dictionary<String, String> resultDic;
    String name, currentPassword, newPassword, email, dob, gender, url, token;
    TextView displayNameTV;
    EditText currentPWET, newPWET, emailET, dobET;
    Spinner genderSPN;
    Button updateBTN, logoutBTN;
    BottomNavigationView btmNav;
    int year, month, day;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onStart() {
        super.onStart();
        setContentView(R.layout.activity_profile);

        DC = new DataController();
        url = DC.setUrl(this);
        sharedpreferences = getSharedPreferences(MyPREFERENCES, Context.MODE_PRIVATE);

        name = sharedpreferences.getString("name", null);
        token = sharedpreferences.getString("token", null);

        getUserProfile();
        displayNameTV = findViewById(R.id.displayNameTV);
        displayNameTV.setText(name);

        currentPWET = findViewById(R.id.currentPasswordET);
        newPWET = findViewById(R.id.newPasswordET);
        emailET = findViewById(R.id.emailET);
        dobET = findViewById(R.id.dobET);

        genderSPN = findViewById(R.id.genderSPN);

        updateBTN = findViewById(R.id.updateProfileBTN);
        logoutBTN = findViewById(R.id.logoutBTN);
        btmNav = findViewById(R.id.btmNav);
        btmNav.setSelectedItemId(R.id.profileItem);

        dobET.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(v.getWindowToken(), 0);

                final Calendar c = Calendar.getInstance();

                if(dobET.getText().toString() != null){
                    Date dobDate = DC.StringToDate(dobET.getText().toString());
                    if(dobDate != null){
                        c.setTime(dobDate); //to select sql date
                    }
                    year = c.get(Calendar.YEAR);
                    month = c.get(Calendar.MONTH);
                    day = c.get(Calendar.DAY_OF_MONTH);
                }

                DatePickerDialog datePickerDialog = new DatePickerDialog(
                        // on below line we are passing context.
                        ProfileActivity.this,
                        new DatePickerDialog.OnDateSetListener() {
                            @Override
                            public void onDateSet(DatePicker view, int year,
                                                  int monthOfYear, int dayOfMonth) {
                                dobET.setText(dayOfMonth + "-" + (monthOfYear + 1) + "-" + year);
                            }
                        },
                        year, month, day);
                datePickerDialog.getDatePicker().setMaxDate(new Date().getTime());
                datePickerDialog.show();
            }
        });

        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(this, R.array.genderList, android.R.layout.simple_spinner_item);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_item);
        genderSPN.setAdapter(adapter);

        updateBTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                currentPassword = currentPWET.getText().toString();
                newPassword = newPWET.getText().toString();
                email = emailET.getText().toString();
                dob = DC.DateToSQL(dobET.getText().toString());
                gender = genderSPN.getSelectedItem().toString().equalsIgnoreCase("Prefer not to say") ? "" : genderSPN.getSelectedItem().toString();
                String params = String.format("{" +
                        "\"name\":\"%s\"," +
                        "\"password\":\"%s\", " +
                        "\"newPassword\":\"%s\", " +
                        "\"email\":\"%s\", " +
                        "\"dob\":\"%s\"," +
                        "\"gender\":\"%s\"," +
                        "\"token\":\"%s\"}", name, currentPassword, newPassword, email, dob, gender, token);
                makeHttpRequest("updateProfile", params, "patch");
            }
        });

        logoutBTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String params = String.format("{" +
                        "\"name\":\"%s\"," +
                        "\"token\":\"%s\"}", name, token);
                makeHttpRequest("logout", params, "delete");
            }
        });

        btmNav.setOnItemSelectedListener(new NavigationBarView.OnItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(MenuItem item) {
                if (item.getItemId() == R.id.homeItem) {
                    startActivity(new Intent(getApplicationContext(), HomeActivity.class));
                    overridePendingTransition(0, 0);
                    return true;
                } else if (item.getItemId() == R.id.profileItem) {
                    onStart();
                    return true;
                } else {
                    return false;
                }
            }
        });
    }

    public void getUserProfile() {
        String params = String.format("{\"name\":\"%s\",\"token\":\"%s\"}", name, token);
        makeHttpRequest("profile", params, "post");
    }

    public void alertShowUp(String title, String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);

        builder.setMessage(message)
                .setTitle(title)
                .setPositiveButton("OK", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {

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
        if (method.equalsIgnoreCase("delete")) {
            request = new Request.Builder()
                    .url(url + endPoint)
                    .delete(requestBody)
                    .build();
        }
        if (method.equalsIgnoreCase("post")) {
            request = new Request.Builder()
                    .url(url + endPoint)
                    .post(requestBody)
                    .build();
        }
        if (method.equalsIgnoreCase("patch")) {
            request = new Request.Builder()
                    .url(url + endPoint)
                    .patch(requestBody)
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
                                if (endPoint.equalsIgnoreCase("logout")) {
                                    SharedPreferences.Editor editor = sharedpreferences.edit();
                                    editor.clear();
                                    editor.commit();
                                    Intent i = new Intent(ProfileActivity.this, LoginActivity.class);
                                    startActivity(i);
                                    finish();
                                }
                                if (endPoint.equalsIgnoreCase("profile")) {
                                    resultDic = DC.ArrayToDic(responseBody);
                                    if (endPoint.equalsIgnoreCase("profile")) {
                                        emailET.setText(resultDic.get("email"));
                                        if (!(resultDic.get("DOB").equalsIgnoreCase("null"))) {
                                            dobET.setText(DC.SQLtoDate(resultDic.get("DOB")));
                                        }
                                        if (resultDic.get("gender").equalsIgnoreCase("null")) {
                                            genderSPN.setSelection(0);
                                        } else {
                                            String[] genderList = getResources().getStringArray(R.array.genderList);
                                            for (int i = 1; i < genderList.length; i++) { //0 is null in db
                                                if (resultDic.get("gender").equalsIgnoreCase(genderList[i])) {
                                                    genderSPN.setSelection(i);
                                                }
                                            }
                                        }
                                    }
                                }
                                if (endPoint.equalsIgnoreCase("updateProfile")) {
                                    resultDic = DC.StringToDic(responseBody);
                                    boolean check = resultDic.get("check").equalsIgnoreCase("true");
                                    alertShowUp(check ? "Successfully" : "Error", resultDic.get("result"));
                                    currentPassword = "";
                                    currentPWET.setText("");
                                }
                            } catch (IOException e) {
                                alertShowUp("Error", "Please try again later");
                                throw new RuntimeException(e);
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

}