package org.apache.pdfbox.tools;

import org.apache.pdfbox.debugger.PDFDebugger;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Field;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;


public class TestPDFBox {
    @Test
    void test() {

        String[] args = {"encrypt",
                "-O",
                "123",
                "-U",
                "123",
                "--input",
                "/home/aman/Desktop/chains/sbom.exe-poc/rq2/pdfbox/pdfbox/2303.11102.pdf",
                "--output",
                "/home/aman/Desktop/chains/sbom.exe-poc/rq2/pdfbox/pdfbox/temp.pdf"};
        assertDoesNotThrow(() -> {
            PDFBox.main(args);
        });

        try {
            Field defaultHeadlessField = java.awt.GraphicsEnvironment.class.getDeclaredField("defaultHeadless");
            defaultHeadlessField.setAccessible(true);
            defaultHeadlessField.set(null, Boolean.FALSE);
            Field headlessField = java.awt.GraphicsEnvironment.class.getDeclaredField("headless");
            headlessField.setAccessible(true);
            headlessField.set(null, Boolean.FALSE);
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        }
        PDFDebugger.main(new String[]{"/home/aman/Desktop/chains/sbom.exe-poc/rq2/pdfbox/pdfbox/temp.pdf", "-viewstructure", "-password", "123"});
    }
}