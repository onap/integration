import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Arrays;

public class Crypto {

    private static final String AES = "AES";
    private static final int GCM_TAG_LENGTH = 16;
    private static final int GCM_IV_LENGTH = 12;
    private static final String AES_GCM_NO_PADDING = "AES/GCM/NoPadding";

    public static void main(String[] args) {
    	if(args.length != 2) {
    		System.out.println("Usage: java Crypto value_to_encrypt key");
    		System.out.println("exit(1)");
    		System.exit(1);
    	}

    	String value = args[0];
    	String key = args[1];
    	String encrypted = encryptCloudConfigPassword(value, key);
    	System.out.println(encrypted);
    }

    /**
     * encrypt a value and generate a keyfile
     * if the keyfile is not found then a new one is created
     * 
     * @throws GeneralSecurityException
     */
    public static String encrypt (String value, String keyString) throws GeneralSecurityException {
        SecretKeySpec sks = getSecretKeySpec (keyString);
        Cipher cipher = Cipher.getInstance(AES_GCM_NO_PADDING);
        byte[] initVector = new byte[GCM_IV_LENGTH];
        (new SecureRandom()).nextBytes(initVector);
        GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH * java.lang.Byte.SIZE, initVector);
        cipher.init(Cipher.ENCRYPT_MODE, sks, spec);
        byte[] encoded = value.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        byte[] cipherText = new byte[initVector.length + cipher.getOutputSize(encoded.length)];
        System.arraycopy(initVector, 0, cipherText, 0, initVector.length);
        cipher.doFinal(encoded, 0, encoded.length, cipherText, initVector.length);
        return byteArrayToHexString(cipherText);
    }

    public static String encryptCloudConfigPassword(String message, String key) {
    	try {
	    	return Crypto.encrypt(message, key);
	    } catch (GeneralSecurityException e) {
          return null;
      }
    }

    private static SecretKeySpec getSecretKeySpec (String keyString) {
        byte[] key = hexStringToByteArray (keyString);
        return new SecretKeySpec (key, AES);
    }

    public static String byteArrayToHexString (byte[] b) {
        StringBuilder sb = new StringBuilder(b.length * 2);
        for (byte aB : b) {
            int v = aB & 0xff;
            if (v < 16) {
                sb.append('0');
            }
            sb.append(Integer.toHexString(v));
        }
        return sb.toString ().toUpperCase ();
    }

    private static byte[] hexStringToByteArray (String s) {
        byte[] b = new byte[s.length () / 2];
        for (int i = 0; i < b.length; i++) {
            int index = i * 2;
            int v = Integer.parseInt (s.substring (index, index + 2), 16);
            b[i] = (byte) v;
        }
        return b;
    }
}