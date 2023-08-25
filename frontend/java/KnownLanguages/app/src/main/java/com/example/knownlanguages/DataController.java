package com.example.knownlanguages;


import android.app.Application;
import android.content.Context;
import android.content.res.Resources;
import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Dictionary;
import java.util.Hashtable;
import java.util.Properties;

public class DataController extends Application {
    private static final String TAG = "DataController: "; //for log
    public static String ipAddress;
    public static String port;
    public static String url;

    public static String MyPREFERENCES = "session";

    public static Dictionary<String, String> StringToDic(String response) {
        String responseRemove = response.substring(1, response.length() - 1);
        String responseReplace = responseRemove.replace("\"", "");
        String[] responseSplit = responseReplace.split(",");
        Dictionary<String, String> responseDic = new Hashtable<>();
        for (String value : responseSplit) {
            String[] valueSplit = value.split(":");
            responseDic.put(valueSplit[0], valueSplit[1]);
        }
        return responseDic;
    }

    //if result is array of dictionary
    public static Dictionary<String, String> ArrayToDic(String response) {
        String removeBracket = response.substring(1, response.length() - 1);
        String removeResult = removeBracket.replaceAll("\"result\":", "");
        String remove2 = removeResult.substring(1);
        return StringToDic(remove2 + " ");
    }

    public static String DateToSQL(String date) {
        if (date.isBlank() || date.equalsIgnoreCase("") || date.isEmpty()) {
            return "";
        } else {
            String[] dateSplit = date.split("-");
            return String.format("%s-%s-%s", dateSplit[2], dateSplit[1], dateSplit[0]);
        }
    }

    public static String SQLtoDate(String date) {
        String[] dateSplit = date.split("/"); //date = MM/dd/YYYY
        return String.format("%s-%s-%s", dateSplit[1], dateSplit[0], dateSplit[2]);
    }

    public static Date StringToDate(String date)  {
        SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy");
        Date dobDate = null;
        try{
            dobDate = formatter.parse(date);
        }catch (ParseException e) {
//            throw new RuntimeException(e);
        }
        return dobDate;
    }
    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public void setPort(String port) {
        this.port = port;
    }

    public static String setUrl(Context context) {
        Resources resources = context.getResources();
        try {
            if (ipAddress == null || port == null) {
                InputStream rawResource = resources.openRawResource(R.raw.config); //change to R.raw.base unless config is created
                Properties properties = new Properties();
                properties.load(rawResource);
                ipAddress = properties.getProperty("api_ipAddress");
                port = properties.getProperty("api_port");
            }
            url = String.format("http://%s:%s/", ipAddress, port);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return url;
    }

    //if you got other config value want to add can use this function
    public static String getConfigValue(Context context, String name) {
        Resources resources = context.getResources();
        try {
            InputStream rawResource = resources.openRawResource(R.raw.config); //change to R.raw.base unless config is created
            Properties properties = new Properties();
            properties.load(rawResource);
            return properties.getProperty(name);
        } catch (Resources.NotFoundException e) {
            Log.e(TAG, "Unable to find the config file: " + e.getMessage());
        } catch (IOException e) {
            Log.e(TAG, "Failed to open config file.");
        }
        return "";
    }
}


