FROM debian:stable-slim

WORKDIR /app/tooling

ENV QUEX_PATH /app/tooling/quex-0.65.4
ENV PYTHONPATH "$PYTHONPATH:/app/tooling/langkit"

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes git gprbuild libgnatcoll-iconv1.7-dev

# Install Python and Pip for libadalang REQUIREMENTS
RUN apt-get install --no-install-recommends --assume-yes ca-certificates build-essential python-dev python-setuptools
RUN easy_install pip
RUN pip install virtualenv

# Install libadalang REQUIREMENTS
RUN virtualenv env
RUN	. env/bin/activate
RUN git clone https://github.com/UnintendedSideEffect/langkit.git
RUN pip install -r langkit/REQUIREMENTS.dev
RUN python langkit/setup.py install

# Install QUEX
#ADD https://sourceforge.net/projects/quex/files/HISTORY/0.65/quex-0.65.4.tar.gz .
ADD https://10gbps-io.dl.sourceforge.net/project/quex/HISTORY/0.65/quex-0.65.4.tar.gz $QUEX_PATH
RUN tar -xvf $QUEX_PATH
RUN ln -s ${QUEX_PATH}/quex-exe.py /usr/local/bin/quex

WORKDIR /app

# build this and run as followed:
# docker run --rm -v $project_path:/app <container-name> python /ada/manage.py