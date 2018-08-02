package org.onap.pnfsimulator.rest.util;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import org.junit.jupiter.api.Test;

class DateUtilTest {

    @Test
    void getFormattedDate() {
        Calendar currentCalendar = Calendar.getInstance();
        String expectedResult = String.valueOf(currentCalendar.get(Calendar.YEAR));

        assertEquals(expectedResult, DateUtil.getTimestamp(new SimpleDateFormat("yyyy")));
    }
}