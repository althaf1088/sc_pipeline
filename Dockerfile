FROM python:3.6

RUN apt-get update

RUN groupadd scuser && useradd -ms /bin/bash -g scuser scuser
USER scuser
WORKDIR /home/scuser

ENV PATH="/home/scuser/.local/bin:$PATH"

COPY --chown=scuser:scuser . ./

RUN pip install --user -r requirements.txt

EXPOSE 8000

CMD ["gunicorn", "-b", "0.0.0.0:8000",  "run:app" ]