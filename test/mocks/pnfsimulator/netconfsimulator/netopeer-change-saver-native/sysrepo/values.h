/**
 * @file values.h
 * @author Rastislav Szabo <raszabo@cisco.com>, Lukas Macko <lmacko@cisco.com>,
 *         Milan Lenco <milan.lenco@pantheon.tech>
 * @brief Functions for simplified manipulation with Sysrepo values.
 *
 * @copyright
 * Copyright 2016 Cisco Systems, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef SYSREPO_VALUES_H_
#define SYSREPO_VALUES_H_

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @defgroup values Value Manipulation Utilities
 * @{
 *
 *  @brief Set of functions facilitating simplified manipulation with sysrepo
 *  values. It is not necessary to use these functions in any scenario, values
 *  can be allocated and initialized manually (just remember to set all uninitialized
 *  members to zero!).
 *
 *  Using these utilities, however, has several benefits. Firstly, all the memory
 *  allocations associated with creating values and setting their attributes get
 *  hidden behind these functions. The "old-way" was (and still is) to set xpath
 *  and string values using strdup, which may repeat in applications communicating
 *  with sysrepo very often and becomes very annoying to write.
 *  Secondly, the programmer may actually forget to copy or give-up on the ownership
 *  of a string passed to sysrepo value which will then get unexpectedly deallocated
 *  in ::sr_free_val or ::sr_free_values.
 *  The third benefit is that the values created using ::sr_new_val
 *  and ::sr_new_values will be allocated using the Sysrepo's own memory management
 *  (if enabled) which was proven to be more efficient for larger data sets
 *  (far less copying, quicker conversion to/from google protocol buffer messages,
 *  stable memory footprint, etc.).
 */

/**
 * @brief Allocate an instance of Sysrepo value.
 *
 * @param [in] xpath Xpath to set for the newly allocated value. Can be NULL.
 * @param [out] value Returned newly allocated value.
 */
int sr_new_val(const char *xpath, sr_val_t **value);

/**
 * @brief Allocate an array of sysrepo values.
 *
 * @param [in] value_cnt Length of the array to allocate.
 * @param [out] values Returned newly allocated array of values.
 */
int sr_new_values(size_t value_cnt, sr_val_t **values);

/**
 * @brief Reallocate an array of sysrepo values.
 *
 * @param [in] old_value_cnt Current length of the value array.
 * @param [in] new_value_cnt Desired length of the value array.
 * @param [in,out] values Returned newly allocated/enlarged array of values.
 */
int sr_realloc_values(size_t old_value_cnt, size_t new_value_cnt, sr_val_t **values);

/**
 * @brief Set/change xpath of a Sysrepo value.
 *
 * @param [in] value Sysrepo value to change the xpath of.
 * @param [in] xpath XPath to set.
 */
int sr_val_set_xpath(sr_val_t *value, const char *xpath);

/**
 * @brief Set/change xpath of a Sysrepo value to a new one, built from
 * a format string and a variable arguments list.
 *
 * @param [in] value Sysrepo value to change the xpath of.
 * @param [in] format Format string used to build XPath.
 */
int sr_val_build_xpath(sr_val_t *value, const char *format, ...);

/**
 * @brief Store data of string type into the Sysrepo value data.
 *
 * @param [in] value Sysrepo value to edit.
 * @param [in] type Exact type of the data.
 * @param [in] string_val String value to set.
 */
int sr_val_set_str_data(sr_val_t *value, sr_type_t type, const char *string_val);

/**
 * @brief Store data of string type into the Sysrepo value data. The actual data
 * will be built from the a format string and a variable arguments list.
 *
 * @param [in] value Sysrepo value to edit.
 * @param [in] type Exact type of the data.
 * @param [in] format Format string used to build the data.
 */
int sr_val_build_str_data(sr_val_t *value, sr_type_t type, const char *format, ...);

/**
 * @brief Duplicate value (with or without Sysrepo memory context) into a new
 * instance with memory context.
 *
 * @param [in] value Sysrepo value to duplicate
 * @param [out] value_dup Returned duplicate of the input value.
 */
int sr_dup_val(const sr_val_t *value, sr_val_t **value_dup);

/**
 * @brief Duplicate values (with or without Sysrepo memory context) into a new
 * array with memory context.
 *
 * @param [in] values Array of sysrepo values to duplicate
 * @param [in] count Size of the array to duplicate.
 * @param [out] values_dup Returned duplicate of the input array.
 */
int sr_dup_values(const sr_val_t *values, size_t count, sr_val_t **values_dup);

/**
 * @brief Print sysrepo value to STDOUT.
 *
 * @param [in] value Sysrepo value to print.
 */
int sr_print_val(const sr_val_t *value);

/**
 * @brief Print sysrepo value to the specified file descriptor.
 *
 * @param [in] fd File descriptor to print the value into.
 * @param [in] value Sysrepo value to print.
 */
int sr_print_val_fd(int fd, const sr_val_t *value);

/**
 * @brief Print sysrepo value to the specified output file stream.
 *
 * @param [in] stream Output file stream to print the value into.
 * @param [in] value Sysrepo value to print.
 */
int sr_print_val_stream(FILE *stream, const sr_val_t *value);

/**
 * @brief Print sysrepo value into a newly allocated memory buffer.
 * The caller is expected to eventually free the returned string.
 *
 * @param [in] mem_p Pointer to store the resulting dump.
 * @param [in] value Sysrepo value to print.
 */
int sr_print_val_mem(char **mem_p, const sr_val_t *value);

/**
 * @brief Converts value to string representation
 * @param [in] value
 * @return allocated string representation of value (must be freed by caller), NULL in case of error
 * @note In case of SR_DECIMAL64_T type, number of fraction digits doesn't have to
 * correspond to schema.
 */
char *sr_val_to_str(const sr_val_t *value);

/**
 * @brief Converts value to string and prints it to the provided buffer including
 * terminating NULL byte
 * @param [in] value
 * @param [in] buffer - buffer provided by caller where the data will be printed
 * @param [in] size - the size of the buffer
 * @return number of characters that was written in case of success, otherwise number of characters which would have been
 * written if enough space had been available (excluding terminating NULL byte)
 * @note In case of SR_DECIMAL64_T type, number of fraction digits doesn't have to
 * correspond to schema.
 */
int sr_val_to_buff(const sr_val_t *value, char buffer[], size_t size);

/**@} values */

#ifdef __cplusplus
}
#endif

#endif /* SYSREPO_VALUES_H_ */
