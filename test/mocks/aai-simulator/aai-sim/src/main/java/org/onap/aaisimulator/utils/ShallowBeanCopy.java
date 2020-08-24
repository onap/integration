/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2019 Nordix Foundation.
 * ================================================================================
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * ============LICENSE_END=========================================================
 */
package org.onap.aaisimulator.utils;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class ShallowBeanCopy {
    private static final Logger LOGGER = LoggerFactory.getLogger(ShallowBeanCopy.class);

    private ShallowBeanCopy() {}

    public static void copy(final Object from, final Object to) throws Exception {
        final Map<String, Method> fromMethods = getMethods(from);
        final Map<String, Method> toMethods = getMethods(to);

        for (final Entry<String, Method> entry : fromMethods.entrySet()) {
            final String methodName = entry.getKey();
            final Method fromMethod = entry.getValue();

            final Optional<Method> optional = getSetMethod(to, fromMethod);
            if (optional.isPresent()) {
                final Method toGetMethod = toMethods.get(methodName);
                final Method toMethod = optional.get();
                final Object toValue = fromMethod.invoke(from);

                final Object fromValue = toGetMethod.invoke(to);
                if (toValue != null && !toValue.equals(fromValue)) {
                    LOGGER.info("Changing {} value from: {} to: {}", methodName, fromValue, toValue);
                    toMethod.invoke(to, toValue);
                }
            }
        }
    }


    private static Optional<Method> getSetMethod(final Object to, final Method fromMethod) {
        final String name = fromMethod.getName().replaceFirst("get|is", "set");
        final Class<?> returnType = fromMethod.getReturnType();
        try {
            return Optional.of(to.getClass().getMethod(name, returnType));
        } catch (final NoSuchMethodException noSuchMethodException) {
        }
        return Optional.empty();
    }

    private static Map<String, Method> getMethods(final Object object) {
        final Map<String, Method> methodsFound = new HashMap<>();
        final Method[] methods = object.getClass().getMethods();

        for (final Method method : methods) {
            if (method.getName().startsWith("get") || method.getName().startsWith("is")) {
                final String name = method.getName().replaceFirst("get|is", "");

                methodsFound.put(name, method);
            }
        }

        return methodsFound;

    }

}
