import json

import requests
from assertpy import assert_that
from robot.api.deco import keyword

JSESSIONID_COOKIE = "JSESSIONID"

_vid_to_so_request_details = {
    "requestDetails": {
        "cloudConfiguration": {
            "lcpCloudRegionId": "RegionOne",
            "tenantId": "982c540f6e69488eb6be5664255e00c0"
        },
        "modelInfo": {
            "modelInvariantId": "41b3c314-dfab-4501-9c5e-1c9fe5d8e151",
            "modelName": "SoWs1..base_ws..module-0",
            "modelType": "vfModule",
            "modelVersion": "1",
            "modelVersionId": "7ea96ae9-9eac-4eaa-882e-077478a6c44a"
        },
        "relatedInstanceList": [{
            "relatedInstance": {
                "instanceId": "0d8a98d8-d7ca-4c26-b7ab-81d3729e3b6c",
                "modelInfo": {
                    "modelInvariantId": "a4413616-cf96-4615-a94e-0dc5a6a65430",
                    "modelName": "SC_WS_SW_2",
                    "modelType": "service",
                    "modelVersion": "3.0",
                    "modelVersionId": "0fdaaf44-3c6c-4d81-9c57-b2ce7224dbb9"
                }
            }
        },
            {
                "relatedInstance": {
                    "instanceId": "61c19619-2714-46f8-90c9-39734e4f545f",
                    "modelInfo": {
                        "modelCustomizationName": "SO_WS_1 0",
                        "modelInvariantId": "3b2c9dcb-6ef8-4c3c-8d5b-43d5776f7110",
                        "modelName": "SO_WS_1",
                        "modelType": "vnf",
                        "modelVersion": "1.0",
                        "modelVersionId": "0fdaaf44-3c6c-4d81-9c57-b2ce7224dbb9"
                    }
                }
            }
        ],
        "requestInfo": {
            "source": "VID",
            "suppressRollback": False,
            "requestorId": "az2016",
            "instanceName": "SC_WS_VNF_1_2"
        },
        "requestParameters": {
            "controllerType": "SDNC",
            "userParams": []
        }

    }
}

_expected_so_response = {
    "status": 202,
    "entity": {
        "requestReferences": {
            "instanceId": "fffcbb6c-1983-42df-9ca8-89ae8b3a46c1",
            "requestId": "b2197d7e-3a7d-410e-82ba-7b7e8191bc46"
        }
    }
}


def _extract_cookie_from_headers(headers):
    for i in headers["Set-Cookie"].split(";"):
        if JSESSIONID_COOKIE in i:
            return i
    raise RuntimeError("N cookie when logging in to VID")


@keyword('Login To VID')
def login_to_vid():
    headers = {'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0',
               'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
               'Accept-Language': 'pl,en-US;q=0.7,en;q=0.3',
               'Accept-Encoding': 'gzip, deflate', 'Referer': 'http://localhost:8080/vid/login.htm',
               'Content-Type': 'application/x-www-form-urlencoded',
               'Content-Length': '36',
               'Cookie': 'JSESSIONID=1B4AF817AA4BCB87C07BB5B49EFE8526',
               'Connection': 'keep-alive',
               'Upgrade-Insecure-Requests': '1'}
    response = requests.post("https://localhost:8443/vid/login_external", data="loginId=demo&password=Kp8bJ4SXszM0WX",
                             headers=headers, allow_redirects=False)
    return _extract_cookie_from_headers(response.headers)


@keyword('Send create VF module instance request to VID')
def send_create_vfmodule_instance_request_to_vid(jsession_cookie):
    response = requests.post(
        "https://localhost:8443/vid/mso/mso_create_vfmodule_instance/0d8a98d8-d7ca-4c26-b7ab-81d3729e3b6c/vnfs/61c19619-2714-46f8-90c9-39734e4f545f ",
        headers={"Cookie": jsession_cookie}, json=_vid_to_so_request_details)
    return json.loads(response.content)


@keyword('Assert request has finished with 200')
def expect_request_finished_with_200(content):
    assert_that(content['status']).is_equal_to(200)


@keyword('Assert returned response was as expected')
def expect_response_from_so_was_correctly_propageted(content):
    assert_that(content['entity']).is_equal_to(_expected_so_response)