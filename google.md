# Setup Google Sign-In (Optional)

Follow these steps to set up Google Sign-In for your application:

1. **Access Google Cloud Console**
   - Visit the [Google Cloud Console](https://console.cloud.google.com/)

2. **Create or Select a Project**
   - Create a new project or select an existing one

3. **Configure OAuth Consent Screen**
   - In the left sidebar, navigate to "APIs & Services" > "OAuth consent screen"
   - Choose the user type (External or Internal)
   - Fill in the required information and save

4. **Create Credentials**
   - In the left sidebar, go to "APIs & Services" > "Credentials"
   - Click the "Create Credentials" button and select "OAuth client ID"

5. **Set Application Type**
   - For Android apps, choose "Android" as the Application Type

6. **Configure Android App**
   - Enter your app's package name
   - Obtain the SHA-1 certificate fingerprint:
     ```
     cd android
     ./gradlew signingReport
     ```
   - Add the SHA-1 fingerprint to the Google Cloud Console

7. **Create Web Application Credentials**
   - Go back to the Credentials page
   - Click "Create Credentials" > "OAuth client ID" again
   - Select "Web application" as the Application Type
   - You can leave "Authorized JavaScript Origins" and "Authorized redirect URIs" blank for now
   - Click "Create"

8. **Obtain Client ID**
   - After creation, copy the "Client ID" for the web application
   - You'll use this Client ID in your Flutter app's `credentialManager.init()` method

## Implementation in Flutter

Use the obtained Client ID in your Flutter app:

``` 
dart
await credentialManager.init(
  preferImmediatelyAvailableCredentials: true,
  googleClientId: 'YOUR_WEB_CLIENT_ID_HERE',
);
```

## Note
- Ensure you've enabled the necessary APIs (like Google Sign-In API) for your project in the Google Cloud Console
- For production apps, make sure to add your app's release SHA-1 fingerprint as well
- Keep your Client ID secure and don't expose it in public repositories