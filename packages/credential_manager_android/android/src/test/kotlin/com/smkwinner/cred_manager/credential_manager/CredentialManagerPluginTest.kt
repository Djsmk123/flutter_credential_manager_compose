package com.smkwinner.cred_manager.credential_manager

import android.content.Context
import kotlinx.coroutines.runBlocking
import org.mockito.Mockito
import kotlin.test.Test
import kotlin.test.assertEquals

/*
 * Unit tests for [CredentialManagerHostApiImpl], the Pigeon `CredentialManagerHostApi`
 * implementation that replaced the plugin's old raw `MethodChannel` dispatch.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

internal class CredentialManagerPluginTest {
    @Test
    fun getPlatformVersion_returnsExpectedValue() = runBlocking {
        val context: Context = Mockito.mock(Context::class.java)
        val hostApi = CredentialManagerHostApiImpl(CredentialManagerUtils()) { context }

        val version = hostApi.getPlatformVersion()

        assertEquals("Android " + android.os.Build.VERSION.RELEASE, version)
    }
}
