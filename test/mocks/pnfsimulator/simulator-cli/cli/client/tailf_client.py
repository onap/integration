###
# ============LICENSE_START=======================================================
# Simulator
# ================================================================================
# Copyright (C) 2019 Nokia. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=========================================================
###

import logging

import websockets
import asyncio
import signal
import sys


class TailfClient(object):

    def __init__(self, url: str, verbose: bool = False) -> None:
        self._url = url
        self._is_running = False
        self._connection = None
        self.logger = logging.getLogger()
        self.logger.setLevel(logging.DEBUG if verbose else logging.INFO)
        signal.signal(signal.SIGINT, self._handle_keyboard_interrupt)

    def tailf_messages(self):
        self._is_running = True
        self.logger.debug("Attempting to connect to websocket server on %s", self._url)
        asyncio.get_event_loop().run_until_complete(
            self._tailf_messages()
        )

    async def _tailf_messages(self):
        try:
            async with websockets.connect(self._url) as connection:
                self.logger.debug("Connection with %s established", self._url)
                self._connection = connection
                while self._is_running:
                    print(await self._connection.recv(), "\n")
        except ConnectionRefusedError:
            self.logger.error("Cannot establish connection with %s", self._url)

    def _handle_keyboard_interrupt(self, sig, frame):
        self.logger.warning("CTR-C pressed, interrupting.")
        self._is_running = False
        sys.exit(0)
