package com.example.knownlanguages;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

public class IPSettingActivity extends AppCompatActivity {
    static String TAG = "SettingActivityDebug: ";  //for log
    DataController DC;
    Toolbar toolbar;
    EditText ipET, portET;
    Button updateBTN;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ipsetting);

        DC = new DataController();

        toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setTitle("Ip Setting");

        ipET = findViewById(R.id.ipET);
        portET = findViewById(R.id.portET);
        updateBTN = findViewById(R.id.updateBTN);

        updateBTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (ipET.getText().toString() != null && portET.getText().toString() != null) {
                    DC.setIpAddress(ipET.getText().toString());
                    DC.setPort(portET.getText().toString());
                    alertShowUp("Updated", String.format("Your new IP address is %s and port is %s", DC.ipAddress, DC.port));
                } else {
                    alertShowUp("Error", "Ip address or Port cannot be empty");
                }
            }
        });
    }

    public void alertShowUp(String title, String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);

        builder.setMessage(message)
                .setTitle(title)
                .setPositiveButton("OK", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        if (title.equalsIgnoreCase("updated")) {
                            startActivity(new Intent(IPSettingActivity.this, LoginActivity.class));
                        }
                    }
                });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }
}