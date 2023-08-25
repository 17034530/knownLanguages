package com.example.knownlanguages;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.navigation.NavigationBarView;

public class HomeActivity extends AppCompatActivity {
    static String TAG = "HomeActivityDebug: "; //for log
    BottomNavigationView btmNav;
    boolean justLogin;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onStart() {
        super.onStart();
        setContentView(R.layout.activity_home);

        btmNav = findViewById(R.id.btmNav);
        btmNav.setSelectedItemId(R.id.homeItem);

        Intent i = getIntent();
        justLogin = i.getBooleanExtra("justLogin",false);

        btmNav.setOnItemSelectedListener(new NavigationBarView.OnItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(MenuItem item) {
                if(item.getItemId() == R.id.homeItem){
                    onStart();
                    return true;
                }else if(item.getItemId() == R.id.profileItem){
                    startActivity(new Intent(getApplicationContext(),ProfileActivity.class));
                    overridePendingTransition(0,0);
                    return true;
                }else{
                    return false;
                }
            }
        });
    }

    @Override
    public void onBackPressed() {
        if(justLogin){
            justLogin = false;
            moveTaskToBack(true); //exit the app if is just Login
        }else{
            super.onBackPressed();
        }

    }
}