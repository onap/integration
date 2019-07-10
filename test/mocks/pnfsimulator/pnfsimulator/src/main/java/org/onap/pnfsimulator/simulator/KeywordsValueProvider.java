/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018 Nokia. All rights reserved.
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
 * ============LICENSE_END=========================================================
 */
package org.onap.pnfsimulator.simulator;

import io.vavr.Function0;
import io.vavr.Function1;
import io.vavr.Function2;

import java.time.Instant;
import java.util.Random;

import org.apache.commons.lang3.RandomStringUtils;

class KeywordsValueProvider {

    private KeywordsValueProvider() {
    }

    static final int DEFAULT_STRING_LENGTH = 20;
    public static final int RANDOM_INTEGER_MAX_LIMITATION = 9;
    public static final int RANDOM_INTEGER_MIN_LIMITATION = 0;

    private static Function2<Integer, Integer, Integer> bigger = (left, right) -> left >= right ? left : right;
    private static Function2<Integer, Integer, Integer> smaller = (left, right) -> left < right ? left : right;
    private static Function2<Integer, Integer,  Integer> randomPrimitiveIntegerFromSortedRange = (min, max) -> new Random().nextInt(max - min  + 1) + min;
    private static Function2<Integer, Integer, String> randomIntegerFromSortedRange = (min, max) -> Integer.toString(new Random().nextInt(max - min + 1) + min);

    private static Function1<Integer, String> randomString = RandomStringUtils::randomAscii;
    private static Function2<Integer, Integer, String> randomInteger = (left, right) -> randomIntegerFromSortedRange.apply(smaller.apply(left, right), bigger.apply(left, right));
    private static Function0<String> randomLimitedInteger = () -> randomInteger.apply(RANDOM_INTEGER_MIN_LIMITATION, RANDOM_INTEGER_MAX_LIMITATION);
    private static Function0<String> randomLimitedString = () -> RandomStringUtils.randomAscii(DEFAULT_STRING_LENGTH);
    private static Function0<String> epochSecond = () -> Long.toString(Instant.now().getEpochSecond());
    private static Function2<Integer, Integer,  Long> randomPrimitiveInteger = (left, right) -> randomPrimitiveIntegerFromSortedRange.apply(smaller.apply(left, right), bigger.apply(left, right)).longValue();
    private static Function0<Long> timestampPrimitive = () -> Instant.now().getEpochSecond();

    public static Function1<Integer, String> getRandomString() {
        return randomString;
    }

    public static Function2<Integer, Integer, String> getRandomInteger() {
        return randomInteger;
    }

    public static Function0<String> getRandomLimitedInteger() {
        return randomLimitedInteger;
    }

    public static Function0<String> getRandomLimitedString() {
        return randomLimitedString;
    }

    public static Function0<String> getEpochSecond() {
        return epochSecond;
    }

    public static Function2<Integer, Integer, Long> getRandomPrimitiveInteger() {
        return randomPrimitiveInteger;
    }

    public static Function0<Long> getTimestampPrimitive() {
        return timestampPrimitive;
    }
}
