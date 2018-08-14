package org.onap.pnfsimulator.message;

import static org.onap.pnfsimulator.message.MessageConstants.COMMON_EVENT_HEADER;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT;
import static org.onap.pnfsimulator.message.MessageConstants.OTHER_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_PREFIX;
import java.util.Map;
import org.json.JSONObject;

public class MessageProvider {

    public JSONObject createMessage(JSONObject params) {

        if (params == null) {
            throw new IllegalArgumentException("Params object cannot be null");
        }

        Map<String, Object> paramsMap = params.toMap();
        JSONObject root = new JSONObject();
        JSONObject commonEventHeader = JSONObjectFactory.generateConstantCommonEventHeader();
        JSONObject otherFields = JSONObjectFactory.generateConstantOtherFields();

        paramsMap.forEach((key, value) -> {

            if (key.startsWith(PNF_PREFIX)) {
                otherFields.put(key, value);
            } else {
                commonEventHeader.put(key, value);
            }
        });

        JSONObject event = new JSONObject();
        event.put(COMMON_EVENT_HEADER, commonEventHeader);
        event.put(OTHER_FIELDS, otherFields);
        root.put(EVENT, event);
        return root;
    }

}
