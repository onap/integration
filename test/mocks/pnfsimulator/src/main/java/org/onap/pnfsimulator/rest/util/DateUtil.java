package org.onap.pnfsimulator.rest.util;

import java.text.DateFormat;
import java.util.Date;

public final class DateUtil {

    private DateUtil() {
    }

    public static String getTimestamp(DateFormat dateFormat) {

        return dateFormat.format(new Date());
    }
}
