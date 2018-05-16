FROM opnfv/xtesting

ARG OPENSTACK_TAG=stable/pike
ARG OPNFV_TAG=master
ARG ONAP_TAG=master

ENV PYTHONPATH $PYTHONPATH:/src/testing-utils/eteutils

COPY thirdparty-requirements.txt thirdparty-requirements.txt
RUN apk --no-cache add --virtual .build-deps --update \
        python-dev build-base linux-headers libffi-dev \
        openssl-dev libjpeg-turbo-dev && \
    git clone --depth 1 https://git.onap.org/testsuite -b $ONAP_TAG /var/opt/OpenECOMP_ETE && \
    git clone --depth 1 https://git.onap.org/testsuite/properties -b $ONAP_TAG /share/config && \
    git clone --depth 1 https://git.onap.org/testsuite/python-testing-utils -b $ONAP_TAG /src/testing-utils && \
    pip install \
        -chttps://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt?h=$OPENSTACK_TAG \
        -chttps://git.opnfv.org/functest/plain/upper-constraints.txt?h=$OPNFV_TAG \
        -rthirdparty-requirements.txt \
        -e /src/testing-utils && \
    rm -r thirdparty-requirements.txt /src/testing-utils/.git /share/config/.git \
        /var/opt/OpenECOMP_ETE/.git && \
    apk del .build-deps

COPY testcases.yaml /usr/lib/python2.7/site-packages/xtesting/ci/testcases.yaml
CMD ["run_tests", "-t", "all"]
