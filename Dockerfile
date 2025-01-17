FROM python:3.8

ARG USER_ID
ARG GROUP_ID

ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
COPY . /code

RUN mkdir /config

ADD /config/* /config/

ENV PATH /opt/conda/bin:$PATH

RUN apt-get -qq update && \
    apt-get install --no-install-recommends -y dialog apt-utils software-properties-common git wget curl bzip2 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf ~/.cache/

RUN groupadd -g ${GROUP_ID} appuser && \
    useradd -m -u ${USER_ID} -g appuser appuser


RUN curl -L https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh > miniconda.sh && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

RUN conda install -y -c conda-forge mamba && \
    mamba create -q -y -c conda-forge -c bioconda -n snakemake  python=3.8 snakemake=7.15  && \
    conda clean --all -y

RUN sh /config/create_paths.sh

RUN cd /code/src && make install && cd /code

USER appuser
ENV PATH /opt/conda/envs/snakemake/bin:$PATH
RUN echo "source activate snakemake" > ~/.bashrc
ENV  PATH="$PATH:/code/src/bin:/usr/local/bin"
