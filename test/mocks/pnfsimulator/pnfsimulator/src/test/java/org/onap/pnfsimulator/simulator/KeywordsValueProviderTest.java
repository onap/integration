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

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.onap.pnfsimulator.simulator.KeywordsValueProvider.DEFAULT_STRING_LENGTH;

import java.util.Random;
import org.junit.jupiter.api.RepeatedTest;
import org.junit.jupiter.api.Test;

class KeywordsValueProviderTest {

    @RepeatedTest(10)
    void randomLimitedStringTest() {
        String supplierResult = KeywordsValueProvider.getRandomLimitedString().apply();
        assertEquals(supplierResult.length(), DEFAULT_STRING_LENGTH);
    }

    @RepeatedTest(10)
    void randomStringTest() {
        int length = new Random().nextInt(15) + 1;
        String supplierResult = KeywordsValueProvider.getRandomString().apply(length);
        assertEquals(supplierResult.length(), length);
    }

    @RepeatedTest(10)
    void  randomIntegerTest(){
        int min = new Random().nextInt(10) + 1;
        int max = new Random().nextInt(1000) + 20;
        String supplierResult = KeywordsValueProvider.getRandomInteger().apply(min, max);
        assertTrue(Integer.parseInt(supplierResult)>=min);
        assertTrue(Integer.parseInt(supplierResult)<=max);
    }

    @Test
    void  randomIntegerContainsMaximalAndMinimalValuesTest(){
        int anyNumber = new Random().nextInt(10) + 1;
        String supplierResult = KeywordsValueProvider.getRandomInteger().apply(anyNumber, anyNumber);
        assertEquals(Integer.parseInt(supplierResult), anyNumber);
    }

    @Test
    void  randomIntegerFromNegativeRangeTest(){
        String supplierResult = KeywordsValueProvider.getRandomInteger().apply(-20, -20);
        assertEquals(Integer.parseInt(supplierResult), -20);
    }

    @RepeatedTest(10)
    void  randomIntegerFromParametersWithDifferentOrdersTest(){
        String supplierResult = KeywordsValueProvider.getRandomInteger().apply(-20, -10);
        assertTrue(Integer.parseInt(supplierResult)>=-20);
        assertTrue(Integer.parseInt(supplierResult)<=-10);
    }

    @RepeatedTest(10)
    void  epochSecondGeneratedInCorrectFormatTest(){
        String supplierResult = KeywordsValueProvider.getEpochSecond().apply();
        assertEquals(supplierResult.length(), 10);
    }

}
